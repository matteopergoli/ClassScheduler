// lib/domain/scheduler/scheduler_isolate.dart
//
// Dart Isolate wiring per §8.6.2.
// The SA loop runs in a background Isolate so the UI stays at 60 fps.
//
// Message protocol:
//   UI → Isolate:  _IsolateInput (spawn argument)
//   Isolate → UI:  ProgressUpdate (periodic) | ScheduleResult (final)
//   UI → Isolate:  'cancel' string (via cancelSendPort)
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
  bool _cancelled = false;

  /// Spawn the isolate, run the engine, return the final [ScheduleResult].
  /// Throws if the isolate crashes unexpectedly.
  Future<ScheduleResult> run(SchedulerInput input) async {
    _cancelled = false;

    final receivePort = ReceivePort();
    final cancelReceivePort = ReceivePort();

    final isolate = await Isolate.spawn(
      _isolateEntry,
      _IsolateInput(
        sendPort:       receivePort.sendPort,
        cancelSendPort: cancelReceivePort.sendPort,
        input:          input,
      ),
      debugName: 'ClassSchedulerEngine',
    );

    // Store cancel port so caller can send cancel
    // (cancelReceivePort is the port the *isolate* listens on;
    //  _cancelPort is the port the *isolate* exposed so we can send to it)
    // We pass cancelReceivePort.sendPort INTO the isolate so it can listen.
    // The UI sends cancel via a separate channel set up below.

    final uiCancelSend = ReceivePort(); // UI-side cancel port
    _cancelPort = uiCancelSend.sendPort; // stored for cancel()

    final completer = Completer<ScheduleResult>();

    receivePort.listen((msg) {
      if (msg is ProgressUpdate) {
        // print('[SchedulerIsolateRunner] received progress ${msg.fraction} it=${msg.iterationsCompleted}');
        if (!_progressController.isClosed) {
          _progressController.add(msg);
        }
      } else if (msg is ScheduleResult) {
        if (!completer.isCompleted) completer.complete(msg);
        receivePort.close();
        uiCancelSend.close();
        isolate.kill(priority: Isolate.immediate);
      } else if (msg is SendPort) {
        // Isolate sends its cancel listener port back so we can send to it
        _cancelPort = msg;
      }
    });

    return completer.future;
  }

  /// Send a cancel signal to the running isolate.
  void cancel() {
    _cancelled = true;
    _cancelPort?.send('cancel');
  }

  void dispose() {
    _progressController.close();
  }
}

// ── Isolate message types ─────────────────────────────────────────────────

class _IsolateInput {
  final SendPort       sendPort;
  final SendPort       cancelSendPort;
  final SchedulerInput input;

  const _IsolateInput({
    required this.sendPort,
    required this.cancelSendPort,
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
