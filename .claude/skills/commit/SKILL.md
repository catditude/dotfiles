<command-name>commit</command-name>

# Commit Skill

Create a git commit with Linear issue tracking and push.

## Instructions

1. **Check for Linear issue**: If a Linear issue ID was not provided in the user's message (e.g., "RES-81", "ENG-123"):
   - Fetch in-progress and todo Linear issues using the `list_issues` MCP tool (state: "started", limit: 10). Also fetch todo issues (state: "unstarted", limit: 10).
   - Review the current `git diff` changes and match them against the fetched issue titles/descriptions to identify the most relevant issues.
   - Use AskUserQuestion to ask which Linear issue this commit relates to, populating the options with up to 2 most relevant issues (prioritize in-progress over todo). Use the issue identifier and title as the label (e.g., "RES-81: Add user auth flow"). Always include "None" as a final option for commits that don't relate to any issue.

2. **Check Claude memory files**: Review if any `.claude/` documentation files (CLAUDE.md, rules/*.md) need updates based on the current code changes:
   - Run `git diff --cached` or `git diff` to see the changes
   - If changes affect patterns, conventions, or architecture documented in `.claude/` files, suggest updates
   - If no updates are needed, proceed to commit

3. **Create the commit**:
   - Run `git status` to see untracked and modified files
   - Run `git diff` to review changes
   - Run `git log --oneline -5` to see recent commit style
   - Stage relevant files (prefer specific files over `git add -A`)
   - Create commit with descriptive message following conventional commits format
   - If a Linear issue was provided, add it in the commit footer using "Closes ISSUE-ID" format

4. **Push**:
    - Run `git push`

## Commit Message Format

```
<type>: <short description>

<optional body with more details>

Closes <ISSUE-ID>
```

Types: feat, fix, refactor, docs, test, chore, style, perf

## Example

User: `/commit RES-81`

Result:
```
feat: add user authentication flow

Implement OAuth2 login with Google and GitHub providers.

Closes RES-81
```
