#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PROCESS_SUBMODULES=false
AUTO_COMMIT=false

for arg in "$@"; do
  case "$arg" in
    --submodules)
      PROCESS_SUBMODULES=true
      ;;
    --commit)
      AUTO_COMMIT=true
      ;;
    *)
      echo "Unknown argument: $arg"
      echo "Usage: $0 [--submodules] [--commit]"
      exit 1
      ;;
  esac
done

export AUTO_COMMIT

cleanup_repo() {
  local repo_label="$1"

  echo ""
  echo "[$repo_label] Scanning for tracked files that are ignored by .gitignore..."

  local delete_list_file
  delete_list_file="$(mktemp -t ignored_tracked.XXXXXX)"

  # List all tracked files that are ignored by .gitignore
  # git check-ignore returns exit code 1 when no matches are found,
  # so we ignore its exit status and decide based on output content.
  # Use -z to safely handle spaces.
  git ls-files -z | git check-ignore -z --stdin > "$delete_list_file" || true

  if [[ ! -s "$delete_list_file" ]]; then
    echo "[$repo_label] No tracked ignored files found."
    rm -f "$delete_list_file"
    return 0
  fi

  echo "[$repo_label] Removing tracked ignored files from index (keeping local files)..."
  xargs -0 git rm -r --cached -- < "$delete_list_file"

  local removed_count
  removed_count=$(tr -cd '\0' < "$delete_list_file" | wc -c | tr -d ' ')

  echo "[$repo_label] Removed $removed_count tracked ignored paths from index."

  if [[ "$AUTO_COMMIT" == true ]]; then
    if ! git diff --cached --quiet; then
      git commit -m "Remove tracked ignored files" || true
      echo "[$repo_label] Commit created (or no changes to commit)."
    fi
  else
    echo "[$repo_label] Run 'git status' to review changes."
  fi

  rm -f "$delete_list_file"
}

cd "$REPO_ROOT"

cleanup_repo "root"

if [[ "$PROCESS_SUBMODULES" == true ]]; then
  if [[ -f ".gitmodules" ]]; then
    echo ""
    echo "Processing submodules..."
    git submodule foreach --recursive 'bash -lc "set -euo pipefail; repo_label=\"$name\"; \
      delete_list_file=\"$(mktemp -t ignored_tracked.XXXXXX)\"; \
      git ls-files -z | git check-ignore -z --stdin > \"$delete_list_file\" || true; \
      if [[ ! -s \"$delete_list_file\" ]]; then \
        echo \"[$repo_label] No tracked ignored files found.\"; \
        rm -f \"$delete_list_file\"; \
        exit 0; \
      fi; \
      echo \"[$repo_label] Removing tracked ignored files from index (keeping local files)...\"; \
      xargs -0 git rm -r --cached -- < \"$delete_list_file\"; \
      removed_count=\"$(tr -cd \\\"\\0\\\" < \"$delete_list_file\" | wc -c | tr -d \\\" \\\")\"; \
      echo \"[$repo_label] Removed $removed_count tracked ignored paths from index.\"; \
      rm -f \"$delete_list_file\"; \
      if [[ \"$AUTO_COMMIT\" == true ]]; then \
        if ! git diff --cached --quiet; then \
          git commit -m \"Remove tracked ignored files\" || true; \
          echo \"[$repo_label] Commit created (or no changes to commit).\"; \
        fi; \
      else \
        echo \"[$repo_label] Run 'git status' to review changes.\"; \
      fi"'
  else
    echo "No .gitmodules file found; skipping submodules."
  fi
fi
