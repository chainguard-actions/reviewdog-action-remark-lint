<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-remark-lint/v5.21.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-remark-lint/v5.21.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

entrypoint.sh line 13 downloads a script and pipes it straight into a shell: `wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/fd59714416d6d9a1c0692d872e38e7f8448df4fc/install.sh | sh -s -- -b /tmp "${REVIEWDOG_VERSION}"`. The URL is pinned to a commit, but the downloaded content runs without first being saved to a file and checked. Save install.sh to a file, verify it (for example with a checksum), then run it as a separate step.

Locations:

- `entrypoint.sh:13`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell

**Notes:**

entrypoint.sh now downloads the reviewdog install.sh to a temp file, which is still fetched from the same commit-pinned URL. Before running it, the script checks that the file is not empty and starts with a shebang line. It then runs the file with `sh "$file" -b /tmp "$REVIEWDOG_VERSION"`. I removed the `-s --` that only made sense in the pipe form. The temp file is deleted afterwards. I couldn't add a sha256 checksum because I had no way to fetch the file and compute its hash. The pinned commit is the main guarantee that the content won't change.

