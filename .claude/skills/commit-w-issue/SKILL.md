---
name: commit-w-issue
description: Create git commits with conventional commit format and Linear issue linking. Use when the user wants to commit AND provides a Linear issue ID (e.g., "commit, RES-151", "commit RES-81", "/commit-w-issue RES-42"). This skill requires a Linear issue ID — do not use it for commits without an issue reference.
---

# Commit with Linear Issue

Stage and commit changes, linking to a provided Linear issue.

## Workflow

1. **Gather context** (run in parallel):
   - `git status` — check for changes; if none, inform user and stop
   - `git diff` (staged + unstaged) — review changes for commit message
   - `git log --oneline -5` — match recent commit style

2. **Stage and commit**:
   - Stage specific files related to the changes (avoid `git add -A` unless user requests it)
   - Generate commit message using conventional commits format
   - Add `Closes ISSUE-ID` footer using the provided Linear issue ID
   - Use HEREDOC for commit message to preserve formatting

   - Chain `git push` with the commit command (e.g., `git commit ... && git push`)

## Commit Message Convention

```
<type>: <short description>

<optional body>

Closes <ISSUE-ID>
```

**Example** — `commit, RES-81` produces:
```
feat: add user authentication flow

Implement OAuth2 login with Google and GitHub providers.

Closes RES-81
```

## Edge Cases

- **Pre-commit hook failure**: Fix the issue, re-stage, create a NEW commit (never amend)
- **Nothing to commit**: Inform the user and stop
- **Secrets detected** (.env, credentials.json, etc.): Warn and exclude from staging
