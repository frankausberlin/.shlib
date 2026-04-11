#!/usr/bin/env bash
# shlibsync.sh - Source this file to get the shlibsync() function
# Usage: shlibsync

_shlibsync_show_diff() {
    if command -v delta &>/dev/null; then
        git diff --color=always "$@" | delta
    else
        git diff --stat "$@" 2>/dev/null
        echo ""
        git diff --color-words "$@" 2>/dev/null
    fi
}

shlibsync() {
    local repo="$HOME/.shlib"

    # Check if the shlib repo directory exists
    if [ ! -d "$repo" ]; then
        echo "Directory ~/.shlib does not exist."
        return 1
    fi

    # 1. Fetch and show remote updates
    echo "==> Fetching from origin..."
    git -C "$repo" fetch origin 2>/dev/null

    # Checks whether the repo has at least one commit and whether an upstream branch is set.
    if git -C "$repo" rev-parse HEAD &>/dev/null && git -C "$repo" rev-parse @{u} &>/dev/null; then
        local local_rev remote_rev
        local_rev=$(git -C "$repo" rev-parse HEAD)
        remote_rev=$(git -C "$repo" rev-parse @{u})
        if [ "$local_rev" != "$remote_rev" ]; then
            echo "==> Remote updates available:"
            git -C "$repo" log --oneline HEAD..@{u}
            echo ""
            read -r -p "Pull remote updates? [y/N] " answer
            if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
                git -C "$repo" pull origin
            fi
        else
            echo "==> No remote updates."
        fi
    fi

    # 2. Check uncommitted changes and offer to commit
    if ! git -C "$repo" diff --quiet 2>/dev/null || ! git -C "$repo" diff --cached --quiet 2>/dev/null; then
        echo ""
        echo "==> Local changes:"
        _shlibsync_show_diff -C "$repo"
        _shlibsync_show_diff -C "$repo" --cached
        echo ""
        read -r -p "Commit and push local changes? [y/N] " answer
        if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
            read -r -p "Commit message: " msg
            [ -z "$msg" ] && msg="update shlibs"
            git -C "$repo" add -A
            git -C "$repo" commit -m "$msg"
            git -C "$repo" push origin
        fi
    else
        echo "==> No local changes."
    fi

    # 3. Offer to push unpushed commits
    local unpushed
    unpushed=$(git -C "$repo" log @{u}..HEAD --oneline 2>/dev/null)
    if [ -n "$unpushed" ]; then
        echo ""
        echo "==> Unpushed commits:"
        echo "$unpushed"
        echo ""
        read -r -p "Push unpushed commits? [y/N] " answer
        if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
            git -C "$repo" push origin
        fi
    fi
}
