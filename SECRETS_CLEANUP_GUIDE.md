# Firebase secrets cleanup – remove `lib/firebase_options.dart` from Git history

This guide removes `lib/firebase_options.dart` from **all** Git history using **git-filter-repo**, so no Firebase keys or config from that file remain in any commit or branch. The rest of the project history stays intact.

---

## Important notes

- **Current state:** Your current `lib/firebase_options.dart` already reads from `.env` (no hardcoded secrets). After cleanup you will re-add this safe version so the app keeps working.
- **History rewrite:** All commit SHAs that ever touched this file will change. Anyone who has cloned the repo must re-clone or follow the “Team members” section.
- **Backup:** Do the steps below on a copy of the repo or ensure you have a full backup and have pushed no critical unpushed work.

---

## 1. Prerequisites

### 1.1 Backup and clean working tree

```powershell
# Ensure you're in the repo root
cd c:\Users\ahmed\projects\qawam

# Optional: create a full backup (e.g. zip or another folder)
# Then ensure working tree is clean
git status
git stash push -u -m "backup before secrets cleanup"   # if you have uncommitted changes
```

### 1.2 Install git-filter-repo (Windows)

**Option A – pip (recommended)**

```powershell
pip install git-filter-repo
# or
pip3 install git-filter-repo
```

**Option B – if pip fails**

- Install Python 3.10+ from python.org (enable “long paths” if offered).
- Ensure `python` and `Scripts` are on PATH, then run the pip command above.

Check:

```powershell
git filter-repo --version
```

---

## 2. Save the safe `firebase_options.dart` (for re-adding later)

The file will be removed from history; you will add this safe version back after the rewrite.

```powershell
copy lib\firebase_options.dart lib\firebase_options.dart.safe
```

Keep `lib\firebase_options.dart.safe` until you have re-added the file and verified the app.

---

## 3. Remove the file from entire Git history

Run from the repo root. This rewrites history and **removes** `lib/firebase_options.dart` from every commit and branch.

```powershell
cd c:\Users\ahmed\projects\qawam

git filter-repo --path lib/firebase_options.dart --invert-paths --force
```

- `--path lib/firebase_options.dart` – target file  
- `--invert-paths` – drop this path everywhere  
- `--force` – required when the repo already has a history (filter-repo safety check)

After this, `lib/firebase_options.dart` will **not** exist in the working tree or in any commit.

---

## 4. Restore the safe file and commit

Re-add the version that uses `.env` only (no hardcoded keys):

```powershell
copy lib\firebase_options.dart.safe lib\firebase_options.dart
git add lib/firebase_options.dart
git commit -m "Add firebase_options.dart (reads from .env, no secrets in repo)"
del lib\firebase_options.dart.safe
```

Your app will keep working because `main.dart` still imports this file and it still reads from `.env`.

---

## 5. Reattach the remote and force-push

`git filter-repo` removes remotes. Re-add and push:

```powershell
git remote add origin https://github.com/YOUR_USERNAME/qawam.git
# Or your actual remote URL – check with: git remote -v  (before running filter-repo, or from memory)

git push --force-with-lease origin --all
git push --force-with-lease origin --tags
```

- Replace `YOUR_USERNAME/qawam` with your real GitHub repo.
- `--force-with-lease` is safer than `--force`: it refuses to push if someone else has pushed in the meantime.
- If you use other branch or tag names, they are included in `--all` and `--tags`.

---

## 6. Verify that secrets are fully removed

Run these **after** the history rewrite (and before or after force-push, from your local repo).

**6.1 No commit should contain the file**

```powershell
git log -p --all -- lib/firebase_options.dart
```

Expected: no output (no commits touch this path in history).

**6.2 Search for Firebase-style keys in history**

```powershell
git log -p --all -S "apiKey:" -- "*.dart"
git log -p --all -S "FIREBASE_" -- "*.dart"
```

If the only hits are in the new “safe” commit, they should be env var names (e.g. `_env('FIREBASE_WEB_API_KEY')`), not literal key strings. Any commit that still contains literal Firebase API key strings would indicate something else (e.g. another file) and should be fixed.

**6.3 Optional – full-text search for a known key**

If you know one exact key that was in the old file:

```powershell
git log -p --all -S "THE_EXACT_KEY_VALUE"
```

Expected: no output after cleanup (key never appears in any commit).

**6.4 Confirm current tree has the file and it’s safe**

```powershell
type lib\firebase_options.dart
```

You should see only `_env('...')` (or similar) and no hardcoded key strings.

---

## 7. What team members must do after the history rewrite

Because history was rewritten, everyone must treat the old clone as outdated:

**Option A – Re-clone (simplest)**

```powershell
cd parent_folder
rename qawam qawam_old
git clone https://github.com/YOUR_USERNAME/qawam.git
cd qawam
# Copy .env from qawam_old if needed, then delete qawam_old when sure
```

**Option B – Reset existing clone**

```powershell
cd c:\path\to\qawam
git fetch origin
git reset --hard origin/main
git clean -fdx
# Restore .env and other local files (e.g. from backup)
```

Replace `main` with your default branch if different (e.g. `master`). They must **not** merge old branches that were based on pre-rewrite history; create new branches from the new `origin/main` after fetching.

---

## 8. Regenerating or rotating Firebase keys

- **Regenerate/rotate:** Treat any Firebase config that was ever in the old `firebase_options.dart` as **exposed**. In Firebase Console (or your project’s config):
  - Restrict/regenerate API keys if the project is sensitive.
  - Enable Application Restriction (e.g. Android package name, iOS bundle ID, HTTP referrer for web) and, if available, API restrictions.
  - Rotate or regenerate any other secrets you stored in that file (e.g. if you had custom secrets).
- **.env:** Your app already uses `.env` for values; ensure `.env` is in `.gitignore` (it is) and never committed. After rotation, update `.env` locally and in CI with the new values.
- You do **not** need to change the structure of `firebase_options.dart`; only the secrets that were once in history need to be rotated/restricted.

---

## 9. Keeping the project fully functional

- The safe `lib/firebase_options.dart` (the one that uses `dotenv.env[...]`) is the only version that should be in the repo from now on.
- **Do not** run `flutterfire configure` and then commit the generated file as-is; that would reintroduce hardcoded keys. If you use FlutterFire CLI, either:
  - Keep using the current pattern (config in `.env`, `firebase_options.dart` only reading from env), or  
  - Put the generated file in `.gitignore` and use a template (e.g. `firebase_options.example.dart`) for documentation.
- `.env` remains the single source of truth for Firebase keys and is already gitignored; the app will work as long as each developer/CI has a correct `.env` (or equivalent) and the committed `firebase_options.dart` that reads from it.

---

## 10. Quick reference – commands in order

```powershell
# 1. Backup safe file
copy lib\firebase_options.dart lib\firebase_options.dart.safe

# 2. Remove file from all history
git filter-repo --path lib/firebase_options.dart --invert-paths --force

# 3. Restore safe file and commit
copy lib\firebase_options.dart.safe lib\firebase_options.dart
git add lib/firebase_options.dart
git commit -m "Add firebase_options.dart (reads from .env, no secrets in repo)"
del lib\firebase_options.dart.safe

# 4. Re-add remote (use your real URL)
git remote add origin https://github.com/YOUR_USERNAME/qawam.git

# 5. Force-push
git push --force-with-lease origin --all
git push --force-with-lease origin --tags

# 6. Verify
git log -p --all -- lib/firebase_options.dart
```

After this, `lib/firebase_options.dart` is removed from all past commits, only the safe version exists in the new history, and the project stays functional with secrets in `.env` only.
