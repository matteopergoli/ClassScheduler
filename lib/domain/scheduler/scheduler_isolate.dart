// lib/domain/scheduler/scheduler_isolate.dart
//
// Dart Isolate wiring per §8.6.2.
// The SA loop runs in a background Isolate so the UI stays at 60 fps.
//
// Message protocol:
//   UI → Isolate:  _IsolateInput (spawn argument)
//   Isolate → UI:  ProgressUpdate (periodic) | ScheduleResult (final)
//   UI → Isolate:  'cancel' string (via isolate-provided SendPort)
//
// Usage:
//   final runner = SchedulerIsolateRunner();
//   runner.progressStream.listen((p) => updateBar(p.fraction));
//   final result = await runner.run(input);
//   runner.cancel(); // safe to call anytime

import 'dart:async';
import 'dart:isolate';

import 'scheduler_engine.dart';
import 'scheduler_input.dart';

// ── Public runner (UI side) ────────────────────────────────────────────────

class SchedulerIsolateRunner {
  final _progressController =
      StreamController<ProgressUpdate>.broadcast();

  Stream<ProgressUpdate> get progressStream => _progressController.stream;

  SendPort? _cancelPort;
  bool _cancelRequested = false;
  Isolate? _activeIsolate;
  ReceivePort? _activeReceivePort;
  Completer<ScheduleResult>? _activeCompleter;

  /// Spawn the isolate, run the engine, return the final [ScheduleResult].
  /// Throws if the isolate crashes unexpectedly.
  Future<ScheduleResult> run(SchedulerInput input) async {
    _cancelRequested = false;

    final receivePort = ReceivePort();
    _cancelPort = null;
    _activeReceivePort = receivePort;

    final completer = Completer<ScheduleResult>();
    _activeCompleter = completer;
    late final Isolate isolate;

    void cleanup() {
      _activeReceivePort?.close();
      _activeReceivePort = null;
      _cancelPort = null;
      _activeIsolate = null;
      _activeCompleter = null;
    }

    receivePort.listen((msg) {
      if (msg is ProgressUpdate) {
        // print('[SchedulerIsolateRunner] received progress ${msg.fraction} it=${msg.iterationsCompleted}');
        if (!_progressController.isClosed) {
          _progressController.add(msg);
        }
      } else if (msg is ScheduleResult) {
        if (!completer.isCompleted) completer.complete(msg);
        cleanup();
        isolate.kill(priority: Isolate.immediate);
      } else if (msg is SendPort) {
        // Isolate sends its cancel listener port back so we can send to it
        _cancelPort = msg;
        if (_cancelRequested) {
          _cancelPort?.send('cancel');
        }
      }
    });

    isolate = await Isolate.spawn(
      _isolateEntry,
      _IsolateInput(
        sendPort: receivePort.sendPort,
        input: input,
      ),
      debugName: 'ClassSchedulerEngine',
    );
    _activeIsolate = isolate;

    // Cancel could have been requested while spawning.
    if (_cancelRequested) {
      cancel();
    }

    return completer.future;
  }

  /// Send a cancel signal to the running isolate.
  void cancel() {
    _cancelRequested = true;
    _cancelPort?.send('cancel');
    _activeIsolate?.kill(priority: Isolate.immediate);

    final completer = _activeCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.completeError(StateError('Scheduler generation cancelled'));
    }

    _activeReceivePort?.close();
    _activeReceivePort = null;
    _activeIsolate = null;
    _activeCompleter = null;
    _cancelPort = null;
  }

  void dispose() {
    _progressController.close();
  }
}

// ── Isolate message types ─────────────────────────────────────────────────

class _IsolateInput {
  final SendPort       sendPort;
  final SchedulerInput input;

  const _IsolateInput({
    required this.sendPort,
    required this.input,
  });
}

// ── Isolate entry point (top-level function required by Dart) ─────────────

void _isolateEntry(_IsolateInput msg) {
  // Set up cancel flag
  bool cancelled = false;
  final cancelPort = ReceivePort();
  cancelPort.listen((m) {
    if (m == 'cancel') cancelled = true;
  });

  // Send the cancel listener port back to the UI so it can trigger cancel
  msg.sendPort.send(cancelPort.sendPort);

  // Progress callback — sends ProgressUpdate across the port
  void onProgress(double fraction, int iterations) {
    msg.sendPort.send(ProgressUpdate(fraction, iterations));
  }

  // Run the engine
  final engine = SchedulerEngine(
    input:       msg.input,
    isCancelled: () => cancelled,
    onProgress:  onProgress,
  );

  final result = engine.run();

  // Send final result and close
  msg.sendPort.send(result);
  cancelPort.close();
}
