# Git Workflow Guide - BI Technical Assessment

**Version**: 1.0  
**Last Updated**: 2024-12-28

---

## 📋 Overview

All candidates use a **Fork + PR workflow** to submit solutions. This guide explains branch naming, commit messages, and PR creation.

---

## 🔄 Workflow Steps

### 1. Fork Repository (One-time setup)

**In GitHub UI**:

1. Navigate to <https://github.com/ahernandezGH/bi-technical-assessment>
2. Click "Fork" button (top right)
3. Select "Create a new fork"
4. Click "Create fork"

**Result**: You own `https://github.com/[YOUR_USERNAME]/bi-technical-assessment`

### 2. Clone Your Fork Locally

```bash
# Clone
git clone https://github.com/[YOUR_USERNAME]/bi-technical-assessment.git
cd bi-technical-assessment

# Verify origin points to YOUR fork
git remote -v
# origin: https://github.com/[YOUR_USERNAME]/...
```

### 3. Add Upstream Remote (Optional but Recommended)

```bash
# Add upstream to stay in sync with original repo
git remote add upstream https://github.com/ahernandezGH/bi-technical-assessment.git

# Verify
git remote -v
# origin: your fork
# upstream: original repo
```

### 4. Create Working Branch

**Branch naming pattern**:

```text
solution-[candidate]-issue[00X]
```

**Examples**:

```bash
git checkout -b solution-juanperez-issue001
git checkout -b solution-mariagarcia-issue003
git checkout -b solution-pedro_rodriguez-issue007
```

**Guidelines**:

- Use lowercase
- Replace spaces with hyphens or underscores
- No special characters except hyphens/underscores
- Keep it short and descriptive

### 5. Work on Your Solution

```bash
# Create folder structure
mkdir -p Solutions/[YourName]/Issue001

# Create files
# - QA_ValidarIntegridadEstudiantes.sql
# - PROC_ValidarIntegridadPreInsert.sql
# - SOLUTION.md

# Stage changes
git add Solutions/[YourName]/Issue001/

# Commit
git commit -m "Solution - [YourName] - Issue [001]"
```

### 6. Push to Your Fork

```bash
git push origin solution-juanperez-issue001

# Output:
# remote: Create a pull request for 'solution-juanperez-issue001' on GitHub by visiting:
# remote: https://github.com/[YOUR_USERNAME]/bi-technical-assessment/pull/new/solution-juanperez-issue001
```

### 7. Create Pull Request

**In GitHub UI**:

1. Go to YOUR fork
2. Click "Compare & pull request" button
3. **CRITICAL**: Set PR title to exactly:

   ```text
   Solution - [YourName] - Issue [001]
   ```

4. In description, add (optional):

   ```markdown
   ## Solution Overview
   - Approach: [Brief explanation]
   - Time spent: ~4 hours
   - Notes: [Any implementation notes]
   ```

5. Click "Create pull request"

**⚠️ IMPORTANT**: PR title triggers auto-grading workflow!

### 8. Monitor Auto-Grading

**In your PR**:

1. Click "Actions" tab or scroll down to "Checks"
2. Watch "Validate Solution" workflow run
3. Wait for comment with score
4. If PASS (≥70 pts): ✅ Congratulations!
5. If FAIL (<70 pts): Fix and push corrections

### 9. Fix and Resubmit (if needed)

If score < 70:

```bash
# Make corrections
# Edit scripts to fix syntax/docs errors

# Add and commit
git add .
git commit -m "Fix: Correct SQL syntax and add more documentation"

# Push (SAME BRANCH)
git push origin solution-juanperez-issue001

# Workflow automatically re-runs
# Check PR for updated score comment
```

**Note**: Workflow triggers on every push to the PR branch. Score will be updated.

---

## 📝 Commit Message Conventions

### Pattern

```text
[TYPE]: [DESCRIPTION]
```

Where TYPE is one of:

- `feat` - New feature/solution
- `fix` - Bug fix or correction
- `docs` - Documentation only
- `style` - Code formatting (no logic change)
- `refactor` - Code reorganization
- `perf` - Performance improvement
- `test` - Test code/validation
- `chore` - Maintenance tasks

### Examples

```bash
git commit -m "feat: Add QA validation query for orphan students"
git commit -m "fix: Correct procedure syntax and add error handling"
git commit -m "docs: Add solution explanation and validation results"
git commit -m "refactor: Extract CTE for better readability"
git commit -m "test: Validate output with 15 expected orphans"
```

### Format Details

- Use lowercase
- Use imperative mood ("Add" not "Added")
- Max 72 characters for first line
- Optional: Detailed description below blank line

```text
feat: Add SQL validation procedure

This adds a new procedure to validate referential integrity
before insert operations. Includes TRY/CATCH error handling
and RAISERROR for invalid IDs.

Fixes: #Issue001
Related-to: PROC_ValidarIntegridadPreInsert.sql
```

---

## 🔀 Handling Updates from Upstream

If original repo is updated while you're working:

```bash
# Fetch latest from upstream
git fetch upstream

# Rebase your branch onto upstream/main
git rebase upstream/main

# Force push to your fork (careful!)
git push origin solution-juanperez-issue001 --force-with-lease
```

**⚠️ Only do this BEFORE creating PR. After PR is open, use merge instead**.

---

## 🚀 Common Scenarios

### Scenario 1: Accidentally committed to main

```bash
# If haven't pushed yet:
git reset HEAD~1              # Undo commit
git checkout -b solution-... # Create new branch
git commit -m "..."           # Commit properly

# If already pushed:
# Contact admin to clean up main branch
```

### Scenario 2: Need to update solution before PR creation

```bash
# Edit files
vim Solutions/[YourName]/Issue001/SOLUTION.md

# Stage, commit, push
git add Solutions/[YourName]/Issue001/SOLUTION.md
git commit -m "docs: Improve solution documentation"
git push origin solution-juanperez-issue001
```

### Scenario 3: Multiple corrections needed

```bash
# Iteration 1
git add .
git commit -m "fix: Correct SQL syntax"
git push origin solution-juanperez-issue001
# Wait for auto-grade comment... FAIL

# Iteration 2
git add .
git commit -m "fix: Add 50 more words to documentation"
git push origin solution-juanperez-issue001
# Wait for auto-grade comment... PASS!
```

### Scenario 4: Want to delete your fork

```bash
# In GitHub UI:
# 1. Go to your fork
# 2. Click "Settings"
# 3. Scroll down to "Danger Zone"
# 4. Click "Delete this repository"
# 5. Type repository name to confirm
```

---

## 📋 Checklist

Before pushing:

- [ ] All temporary files deleted (TEMP_*, WIP_*, DEBUG_*, OUTPUT_*)
- [ ] Solution files in correct folder: `Solutions/[YourName]/Issue001/`
- [ ] File names follow conventions (QA_*, PROC_*, SOLUTION.md)
- [ ] All SQL scripts are syntactically valid
- [ ] SOLUTION.md has ≥150 words
- [ ] Git branch named: `solution-[yourname]-issue[00X]`
- [ ] Commits have clear messages (feat:, fix:, docs:)
- [ ] Pushed to your fork (not origin → upstream)
- [ ] PR title is exactly: `Solution - [YourName] - Issue [001]`
- [ ] PR is against `main` branch

---

## 🔍 Debugging Workflow Issues

### Issue: "GitHub Actions not triggered"

**Causes**:

1. PR title doesn't match pattern
2. Merge conflict exists
3. Auto-grade disabled

**Fix**:

```bash
# Check PR title in GitHub UI
# Format should be: Solution - [Name] - Issue [001]

# If wrong, close and create new PR with correct title
```

### Issue: "Validation keeps failing"

**Steps**:

1. Run validator locally

   ```powershell
   .\Tools\Validate-Solution.ps1 -Issue "001" -Candidate "JuanPerez"
   ```

2. Fix errors shown
3. Re-run locally to confirm
4. Push (workflow runs automatically)

### Issue: "Can't push to fork"

**Check**:

```bash
# Verify origin
git remote -v
# Should show YOUR fork, not upstream

# If wrong, change remote
git remote set-url origin https://github.com/[YOUR_USERNAME]/bi-technical-assessment.git
```

---

## 📚 References

- [GitHub Forking Workflow](https://guides.github.com/activities/forking/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Git Rebasing Guide](https://git-scm.com/book/en/v2/Git-Branching-Rebasing)

---

## ✓ Summary

1. **Fork** repo (one-time)
2. **Clone** your fork
3. **Branch** from main: `solution-[name]-issue[00X]`
4. **Work** on solution in `Solutions/[YourName]/Issue00X/`
5. **Commit** with clear messages
6. **Push** to your fork
7. **PR** with exact title: `Solution - [Name] - Issue [00X]`
8. **Monitor** auto-grade (5-8 minutes)
9. **Fix and resubmit** if needed (1 retry allowed)

---

Created: 2024-12-28
