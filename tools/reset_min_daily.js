// tools/reset_min_daily.js
// Usage: node reset_min_daily.js --uid <USER_UID> --school <SCHOOL_ID>
// Requires: npm install firebase-admin
// Authentication: set GOOGLE_APPLICATION_CREDENTIALS to a service account JSON

const admin = require('firebase-admin');
const { argv } = require('process');

function parseArgs() {
  const out = {};
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--uid') out.uid = argv[++i];
    else if (a === '--school') out.school = argv[++i];
    else if (a === '--dry') out.dry = true;
  }
  return out;
}

async function main() {
  const args = parseArgs();
  if (!args.uid || !args.school) {
    console.error('Usage: node reset_min_daily.js --uid <USER_UID> --school <SCHOOL_ID> [--dry]');
    process.exit(2);
  }

  if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    console.warn('GOOGLE_APPLICATION_CREDENTIALS not set; trying ./serviceAccount.json');
    process.env.GOOGLE_APPLICATION_CREDENTIALS = './serviceAccount.json';
  }

  try {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
    });
  } catch (e) {
    console.error('Failed to initialize firebase-admin:', e.message || e);
    process.exit(1);
  }

  const db = admin.firestore();
  const col = db
    .collection('users')
    .doc(args.uid)
    .collection('schools')
    .doc(args.school)
    .collection('classroomSubjects');

  console.log('Querying classroomSubjects...');
  const snap = await col.get();
  console.log('Found', snap.size, 'documents');

  const batch = db.batch();
  let changed = 0;
  snap.forEach(doc => {
    const data = doc.data();
    const minDaily = (data.minDailyHours || 0);
    if (minDaily !== 0) {
      console.log('Will update', doc.id, 'minDailyHours:', minDaily, '-> 0');
      changed++;
      if (!args.dry) batch.update(doc.ref, { minDailyHours: 0 });
    }
  });

  if (changed === 0) {
    console.log('No documents to update.');
    process.exit(0);
  }

  if (args.dry) {
    console.log('(dry run) Not committing changes.');
    process.exit(0);
  }

  console.log('Committing batch update for', changed, 'documents...');
  await batch.commit();
  console.log('Done.');
}

main().catch(err => {
  console.error('Error:', err);
  process.exit(1);
});
