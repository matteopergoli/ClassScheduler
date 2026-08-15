Reset minDailyHours migration

This migration script sets `minDailyHours` to 0 for all documents in
`/users/{uid}/schools/{schoolId}/classroomSubjects` that currently have a
non-zero value.

Prerequisites
- Node.js installed
- A Firebase service account JSON with Firestore access
  (downloaded from Google Cloud Console)

Setup
1. Place the service account JSON into `tools/serviceAccount.json` or set
   the environment variable `GOOGLE_APPLICATION_CREDENTIALS` to its path.
2. In `tools/` run:

```bash
npm init -y
npm install firebase-admin
```

Run
```bash
# dry run (shows which docs would be changed)
node tools/reset_min_daily.js --uid YOUR_USER_UID --school YOUR_SCHOOL_ID --dry

# actual run
node tools/reset_min_daily.js --uid YOUR_USER_UID --school YOUR_SCHOOL_ID
```

Notes
- The script uses `GOOGLE_APPLICATION_CREDENTIALS` or `tools/serviceAccount.json` for credentials.
- It performs a single batched update. If you have many documents, consider
  splitting into smaller batches to avoid Firestore limits.
- I can update this script to accept a list of schools or to search across
  all users/schools, but that requires more privileges and caution.