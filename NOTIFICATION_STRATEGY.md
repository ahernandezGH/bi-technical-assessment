# Email & Notification Strategy

**Document Purpose**: Explain how candidates and evaluators are notified of validation results, and the reasoning behind each design choice.

---

## Current Implementation (Phase 5)

### For Candidates: GitHub Native Notifications

**How it works**:
1. Candidate submits PR with title `Solution - [Name] - Issue [00X]`
2. GitHub Actions workflow runs automatically (3-5 minutes)
3. Workflow posts comment on PR with score/status
4. GitHub notifies candidate of new comment on their PR

**Why this approach**:
- ✅ No external email service needed (no SMTP/SendGrid credentials)
- ✅ Keeps all communication in GitHub (single source of truth)
- ✅ Works immediately after PR creation
- ✅ Candidate can configure email notifications via GitHub settings
- ✅ Audit trail: all comments visible on PR

**Candidate can also validate locally first**:
```powershell
.\Test-Solution-Local.ps1 -Candidate "YourName" -Issue "001"
```
This gives instant feedback BEFORE submitting PR.

---

### For Evaluators: GitHub PR Dashboard + Notifications

**How it works**:
1. Evaluator goes to: https://github.com/ahernandezGH/bi-technical-assessment/pulls
2. Sees all PRs with auto-comment scores/status from github-actions bot
3. GitHub sends notification when new PR is created or commented on
4. Evaluator can reply to comments or contact candidate if needed

**Why this approach**:
- ✅ No manual checking required (workflow posts results automatically)
- ✅ Evaluator sees score/status immediately in PR interface
- ✅ Full audit trail of all evaluations
- ✅ Scales to multiple candidates without extra configuration
- ✅ No email infrastructure costs

---

## Alternative Approaches Evaluated

### Option A: Email to Repository Owner Only ❌

**How it would work**:
- Workflow sends email only to repo owner (ahernandezGH@example.com)
- Candidate doesn't know result until owner replies

**Pros**:
- Owner gets direct notification

**Cons**:
- ❌ Candidate doesn't know if they passed (poor UX)
- ❌ Owner becomes bottleneck for communicating results
- ❌ Requires SMTP server or SendGrid API (cost, credentials)
- ❌ Workflow complexity increases

**Verdict**: Not recommended.

---

### Option B: Email to Candidate + CC Owner ⚠️

**How it would work**:
- Workflow sends email to candidate's email (from GitHub profile)
- Includes CC to owner (ahernandezGH@example.com)
- Both see score/status immediately

**Pros**:
- ✅ Candidate gets instant email feedback
- ✅ Owner also notified

**Cons**:
- ❌ Requires SMTP server or SendGrid/Mailgun API
- ❌ Needs credentials stored in GitHub Secrets (security risk)
- ❌ Email delivery not guaranteed (spam filters, bounces)
- ❌ Cost (if using SendGrid/Mailgun)
- ❌ Added complexity to workflow
- ⚠️ Candidate email may not be in GitHub profile

**Verdict**: Overkill for current scale; can implement in Phase 6+ if needed.

---

### Option C: GitHub Comments + GitHub Notifications (Current) ✅

**How it would work**:
- Workflow posts comment on PR (no external services)
- GitHub's built-in notification system alerts:
  - Candidate (when comment posted on their PR)
  - Owner (if subscribed to PR comments)
- Both can see results on GitHub immediately

**Pros**:
- ✅ Zero external dependencies
- ✅ No credentials/SMTP needed
- ✅ Works for any number of candidates
- ✅ Full audit trail in GitHub
- ✅ Candidate gets instant feedback on PR
- ✅ Evaluator sees score/status without leaving GitHub
- ✅ Simple, reliable, scalable

**Cons**:
- Candidate must check GitHub PR or enable email notifications
- Requires understanding of GitHub notifications

**Verdict**: RECOMMENDED for Phase 5-6. Best balance of UX and complexity.

---

### Option D: GitHub Notifications + Optional External Email (Phase 6+)

**How it would work**:
- Keep current GitHub comment system (Option C)
- Optionally add webhook to send emails to evaluator/candidate
- Evaluator can configure email notifications in repo settings

**When to implement**:
- Phase 6: If evaluators request email summaries
- Phase 7: If scaling to 100+ candidates (need email digest)

**How to implement**:
1. Create GitHub webhook: POST to email service on PR creation
2. Email service sends formatted email to candidate + owner
3. Cost: ~$0.10/email (SendGrid) or self-hosted (free)

**Verdict**: Save for Phase 6+. Not needed for initial rollout.

---

## Implementation Checklist

### Phase 5 (Current) ✅

- [x] Local validator script (`Test-Solution-Local.ps1`)
  - Candidates can test before submitting
  - Same validation logic as GitHub Actions
  
- [x] GitHub Actions auto-comment
  - Posts score/status to PR automatically
  - No manual evaluator action needed
  
- [x] GitHub notifications (native)
  - Candidate can enable email notifications in settings
  - Evaluator sees PRs on dashboard

- [x] Documentation
  - SETUP.md explains PR title format
  - PR shows validation results immediately

### Phase 6 (Optional Enhancement)

- [ ] GitHub webhook for email notifications (if requested)
- [ ] Email digest for evaluators (if >10 PRs/day)
- [ ] Scheduled report (daily/weekly evaluator summary)

### Phase 7+ (Scale-up)

- [ ] Custom notification dashboard
- [ ] Candidate communication platform
- [ ] Interview scheduling integration
- [ ] Results archive/reporting

---

## For Evaluator (ahernandezGH)

### How to see results:

**Option 1 - PR Dashboard (Recommended)**:
1. Go to: https://github.com/ahernandezGH/bi-technical-assessment/pulls
2. Click any open/closed PR
3. Scroll to `github-actions[bot]` comment
4. See score, status, and feedback

**Option 2 - GitHub Notifications**:
1. Go to: https://github.com/settings/notifications
2. Enable notifications for this repo
3. Get email/mobile alert when PR created or commented
4. Check PR for auto-comment results

**Option 3 - GitHub Email Summary** (Optional):
1. Enable `Email notifications` in settings
2. Get weekly digest of all PRs
3. Click PR links to see validation results

---

## For Candidate (First-Time Users)

### How to know if you passed:

**Step 1 - Test locally (BEFORE submitting)**:
```powershell
.\Test-Solution-Local.ps1 -Candidate "YourName" -Issue "001"
```
Result: PASS/FAIL immediately

**Step 2 - Check PR after submission** (3-5 min wait):
1. Go to your PR: `github.com/YOUR-USERNAME/bi-technical-assessment/pulls/XXX`
2. Scroll down
3. Look for comment from `github-actions[bot]`
4. See: Score X/100, Status PASS/FAIL

**Step 3 - (Optional) Enable email notifications**:
1. Go to: https://github.com/settings/notifications
2. Check: "Email notifications"
3. Future PRs will send you email when commented on

---

## Conclusion

**Current approach (GitHub notifications + local validator) is optimal for Phase 5-6** because:

1. **Zero infrastructure**: No SMTP, no SendGrid, no costs
2. **Instant feedback**: Local validator before PR, auto-comment after PR
3. **Transparent**: All results visible in GitHub (audit trail)
4. **Scalable**: Works for 1 candidate or 1000 candidates
5. **User-friendly**: Familiar GitHub interface, no new tools

**Future enhancements** (Phase 6+):
- Email digest for evaluators (if volume increases)
- Webhook integration for custom notifications
- Interview scheduling system integration

---

**Document Version**: 1.0  
**Date**: January 8, 2026  
**Status**: Final recommendation for Phase 5
