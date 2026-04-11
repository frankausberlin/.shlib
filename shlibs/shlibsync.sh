#!/usr/bin/env bash
# shlibsync.sh - Source this file to get the shliblibsync() function
# Usage: shliblibsync

_shlibsync_show_diff() {
    if command -v delta &>/dev/null; then
        git diff --color=always "$@" | delta
    else
        git diff --stat "$@" 2>/dev/null
        echo ""
        git diff --color-words "$@" 2>/dev/null
    fi
}

shliblibsync() {
    local SCRIPT_DIR REPO_ROOT BRANCH REMOTE LOCAL_HASH REMOTE_HASH
    local has_changes answer commit_msg UNPUSHED

    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null)"

    if [[ -z "${REPO_ROOT:-}" ]]; then
        echo "Error: not inside a git repository." >&2
        return 1
    fi

    cd "$REPO_ROOT"

    BRANCH="$(git branch --show-current)"
    REMOTE="origin"

    echo "=== shlibsync ==="
    echo "Repo:   $REPO_ROOT"
    echo "Branch: $BRANCH"
    echo ""

    # ── Fetch ──────────────────────────────────────────────────────────
    echo "Fetching from $REMOTE..."
    git fetch "$REMOTE" 2>&1 | sed 's/^/  /'

    # ── Check remote updates ──────────────────────────────────────────
    LOCAL_HASH="$(git rev-parse HEAD)"
    REMOTE_HASH="$(git rev-parse "${REMOTE}/${BRANCH}" 2>/dev/null || echo "")"

    if [[ -n "$REMOTE_HASH" && "$LOCAL_HASH" != "$REMOTE_HASH" ]]; then
        echo ""
        echo "--- Remote has updates ---"
        git log --oneline HEAD.."${REMOTE}/${BRANCH}" 2>/dev/null | sed 's/^/  /'
        echo ""
        _shlibsync_show_diff HEAD "${REMOTE}/${BRANCH}"
        echo ""
        read -rp "Pull remote updates? [y/N] " answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            git pull "$REMOTE" "$BRANCH"
            echo "Pulled."
        else
            echo "Skipped pull."
        fi
    fi

    # ── Check local changes ───────────────────────────────────────────
    has_changes=false
    git diff --quiet 2>/dev/null            || has_changes=true   # unstaged
    git diff --cached --quiet 2>/dev/null   || has_changes=true   # staged
    if [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
        has_changes=true                                          # untracked
    fi

    if ! $has_changes; then
        # Check for unpushed commits
        if git rev-parse --abbrev-ref "@{upstream}" &>/dev/null; then
            UNPUSHED="$(git log --oneline "@{upstream}..HEAD" 2>/dev/null || true)"
            if [[ -n "$UNPUSHED" ]]; then
                echo ""
                echo "--- Unpushed commits ---"
                echo "$UNPUSHED" | sed 's/^/  /'
                echo ""
                read -rp "Push now? [y/N] " answer
                if [[ "$answer" =~ ^[Yy]$ ]]; then
                    git push "$REMOTE" "$BRANCH"
                    echo "Pushed."
                fi
            fi
        fi
        echo ""
        echo "No local changes. Repo is clean."
        return 0
    fi

    echo ""
    echo "--- Local changes ---"
    _shlibsync_show_diff

    echo ""
    read -rp "Commit and push these changes? [y/N] " answer
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        return 0
    fi

    read -rp "Commit message: " commit_msg
    if [[ -z "$commit_msg" ]]; then
        echo "Empty commit message — aborted."
        return 1
    fi

    git add -A
    git commit -m "$commit_msg"
    git push "$REMOTE" "$BRANCH"

    echo ""
    echo "Committed and pushed."
}
