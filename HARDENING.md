<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-remark-lint/v5.16.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-remark-lint/v5.16.0** was hardened automatically. 11 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

entrypoint.sh downloads a remote install script and pipes it directly to `sh` without first saving it to a file for inspection. This allows a compromised or malicious upstream server to execute arbitrary code on the runner. Offending line: `wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b /tmp "${REVIEWDOG_VERSION}"`

Locations:

- `entrypoint.sh:13`

### script-injection (severity: high)

Rule (b): entrypoint.sh expands `${INPUT_REMARK_ARGS}` unquoted on line 41 (`remark . ${INPUT_REMARK_ARGS}`). This variable is set from `inputs.remark_args` (a user-controlled composite-action input) via the `env:` block in action.yml. An attacker-controlled value containing shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) will be parsed by the shell, enabling command injection. The `# shellcheck disable=SC2086` comment explicitly suppresses the shellcheck warning about this unquoted expansion.

Locations:

- `entrypoint.sh:41`

### script-injection (severity: high)

Rule (b): entrypoint.sh expands `${INPUT_REVIEWDOG_FLAGS}` unquoted on line 49 (the last argument to `/tmp/reviewdog`). This variable is set from `inputs.reviewdog_flags` (a user-controlled composite-action input) via the `env:` block in action.yml. An unquoted expansion allows shell metacharacter injection from attacker-supplied flag values.

Locations:

- `entrypoint.sh:49`

### missing-permissions (severity: medium)

The workflow file has no top-level `permissions:` key and no job-level `permissions:` key on any job. Without explicit permissions, the GITHUB_TOKEN is granted its default (often broad) permissions, violating the principle of least privilege.

Locations:

- `.github/workflows/depup.yml:1`

### missing-permissions (severity: medium)

The workflow file has no top-level `permissions:` key and no job-level `permissions:` key on any job. Without explicit permissions, the GITHUB_TOKEN is granted its default (often broad) permissions, violating the principle of least privilege.

Locations:

- `.github/workflows/release.yml:1`

### missing-permissions (severity: medium)

The workflow file has no top-level `permissions:` key and no job-level `permissions:` key on any job. Without explicit permissions, the GITHUB_TOKEN is granted its default (often broad) permissions, violating the principle of least privilege.

Locations:

- `.github/workflows/reviewdog.yml:1`

### missing-permissions (severity: medium)

The workflow file has no top-level `permissions:` key and no job-level `permissions:` key on any job. Without explicit permissions, the GITHUB_TOKEN is granted its default (often broad) permissions, violating the principle of least privilege.

Locations:

- `.github/workflows/test.yml:1`

### unpinned-uses (severity: high)

All `uses:` references in this workflow use mutable tag refs instead of immutable 40-character SHA commit hashes, making the workflow vulnerable to supply-chain attacks if any referenced action is compromised or its tag is moved. Unpinned references: `actions/checkout@v4` (line 12), `reviewdog/action-depup@v1` (line 13), `peter-evans/create-pull-request@v6` (line 19).

Locations:

- `.github/workflows/depup.yml:12`
- `.github/workflows/depup.yml:13`
- `.github/workflows/depup.yml:19`

### unpinned-uses (severity: high)

All `uses:` references in this workflow use mutable tag refs instead of immutable 40-character SHA commit hashes. Unpinned references: `actions/checkout@v4` (line 13), `haya14busa/action-bumpr@v1` (lines 20 and 44), `haya14busa/action-update-semver@v1` (line 25), `haya14busa/action-cond@v1` (line 31).

Locations:

- `.github/workflows/release.yml:13`
- `.github/workflows/release.yml:20`
- `.github/workflows/release.yml:25`
- `.github/workflows/release.yml:31`
- `.github/workflows/release.yml:44`

### unpinned-uses (severity: high)

All `uses:` references in this workflow use mutable tag refs instead of immutable 40-character SHA commit hashes. Unpinned references: `actions/checkout@v4` (lines 11, 22, 32), `haya14busa/action-cond@v1` (line 12), `reviewdog/action-shellcheck@v1` (line 17), `reviewdog/action-misspell@v1` (line 27), `reviewdog/action-alex@v1` (line 36).

Locations:

- `.github/workflows/reviewdog.yml:11`
- `.github/workflows/reviewdog.yml:12`
- `.github/workflows/reviewdog.yml:17`
- `.github/workflows/reviewdog.yml:22`
- `.github/workflows/reviewdog.yml:27`
- `.github/workflows/reviewdog.yml:32`
- `.github/workflows/reviewdog.yml:36`

### unpinned-uses (severity: high)

All `uses:` references in this workflow use mutable tag refs instead of immutable 40-character SHA commit hashes. Unpinned references: `actions/checkout@v4` (lines 11, 21, 31).

Locations:

- `.github/workflows/test.yml:11`
- `.github/workflows/test.yml:21`
- `.github/workflows/test.yml:31`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection, missing-permissions, unpinned-uses

**Notes:**

Fixed all 11 findings across 5 files:

1. entrypoint.sh (unsafe-shell): Changed wget pipe-to-sh to download script to /tmp/install-reviewdog.sh first, execute separately, then clean up.

2. entrypoint.sh (script-injection, INPUT_REMARK_ARGS line 41): Replaced unquoted `${INPUT_REMARK_ARGS}` with a bash array built via `read -ra remark_args <<< "${INPUT_REMARK_ARGS}"` and used `"${remark_args[@]}"` in the remark command.

3. entrypoint.sh (script-injection, INPUT_REVIEWDOG_FLAGS line 49): Replaced unquoted `${INPUT_REVIEWDOG_FLAGS}` with a bash array built via `read -ra reviewdog_flags <<< "${INPUT_REVIEWDOG_FLAGS}"` and used `"${reviewdog_flags[@]}"` in the reviewdog command.

4. depup.yml: Added `permissions: contents: write, pull-requests: write`; pinned actions/checkout@v4→SHA, reviewdog/action-depup@v1→SHA, peter-evans/create-pull-request@v6→SHA.

5. release.yml: Added `permissions: contents: write`; pinned actions/checkout@v4→SHA, haya14busa/action-bumpr@v1→SHA, haya14busa/action-update-semver@v1→SHA, haya14busa/action-cond@v1→SHA.

6. reviewdog.yml: Added `permissions: contents: read, checks: write, pull-requests: write`; pinned actions/checkout@v4→SHA, haya14busa/action-cond@v1→SHA, reviewdog/action-shellcheck@v1→SHA, reviewdog/action-misspell@v1→SHA, reviewdog/action-alex@v1→SHA.

7. test.yml: Added `permissions: contents: read, checks: write, pull-requests: write`; pinned actions/checkout@v4→SHA (local `uses: ./` references are not pinnable).

