---
name: gh-issue-worker
description: "Process prose GitHub issues created by the user in strict sequence (one by one), generate copy/paste-ready artifacts, and enforce export rules: TSV for tabular content and Markdown text for non-tabular content."
---

# gh-issue-worker

Use this workflow when the user creates task issues in GitHub and wants Claude to process them one after another and produce artifacts defined by each issue.

## Workflow summary

1. Discover the issue queue for the user.
2. Pick the next issue (oldest first unless user says otherwise).
3. Complete that issue fully and produce artifacts.
4. Report completion on the issue.
5. Only then move to the next issue.

Do not batch multiple issues at once.

## Prose issue template (recommended)

Use this structure when creating issues for Claude:

```text
Title: <artifact goal>

Context
- Why this artifact is needed
- Source material links

Deliverables
- file: <name.md>  | purpose: <what to paste where>
- file: <name.tsv> | columns: <col1, col2, ...>

Constraints
- TSV for tabular content
- Markdown text for non-tabular content
- Any explicit style/length rules

Definition of done
- Concrete checks that confirm completion
```

If deliverable type is ambiguous, clarify on the issue before execution.

## 1) Discover issue queue

Run in target repo:

```bash
gh issue list \
  --repo <owner/repo> \
  --state open \
  --author <creator-username> \
  --limit 100 \
  --json number,title,url,labels,createdAt
```

Deterministic order (default):

```bash
gh issue list \
  --repo <owner/repo> \
  --state open \
  --author <creator-username> \
  --limit 100 \
  --json number,title,createdAt \
| jq -r 'sort_by(.createdAt)[] | "#\(.number) \(.title)"'
```

Optional label filter:

```bash
gh issue list \
  --repo <owner/repo> \
  --state open \
  --author <creator-username> \
  --label "claude" \
  --limit 100
```

## 2) Single-issue execution loop (MANDATORY)

For each selected issue:

1. Read full issue and comments:
   ```bash
   gh issue view <number> --repo <owner/repo> --comments
   ```
2. Translate prose into a concrete task brief:
   - Goal
   - Required artifacts
   - Acceptance checks
3. Create artifacts in `exports/<issue-number>/`.
4. Validate artifact format rules (section 3).
5. If repository code changes are requested, create branch/commit/PR.
6. Comment on issue with:
   - What was produced
   - Artifact paths
   - PR link (if any)
7. Mark done (close issue or apply done label per repo convention).
8. Then proceed to the next issue.

Never start issue N+1 before issue N is fully completed.

## 3) Output routing rules (MANDATORY)

Choose output format by content type:

1. Tabular content (rows/columns, form grids, financial tables):
   - Output as `.tsv` only.
   - Do not represent tabular data as markdown tables.
2. Non-tabular content (narrative, instructions, prose answers):
   - Output as Markdown text `.md`.
3. Mixed deliverables:
   - Split by type into separate files (`.md` and `.tsv`).
4. Scope guard:
   - Only create files explicitly requested or implied by the issue.
   - If an issue is ambiguous, ask for clarification in the issue before producing artifacts.

## 4) TSV constraints

For every `.tsv` artifact:

- Use TAB as delimiter (`\t`).
- Use LF newline (`\n`).
- Keep a stable column count for all rows.
- Do not use markdown syntax.
- Normalize line breaks to `\n` only.
- Replace internal multi-line cell content with ` ; `.
- Preserve empty cells with delimiters.
- Put raw URLs directly in cells (no markdown links).

Quick-check:

```bash
awk -F '\t' '{print NF}' <file>.tsv | sort -u
```

Result should be a single number.

## 5) Artifact layout

Deliver artifacts in this structure:

```text
exports/
  <issue-number>/
    SUMMARY.md
    <artifact-name>.md
    <artifact-name>.tsv
```

Rules:
- Keep names explicit and copy/paste-friendly.
- Use one file per artifact type/purpose.
- Include `SUMMARY.md` with what was produced and where to use it.
