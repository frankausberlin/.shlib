This repo contains two folders: `exports` and `shlibs`. 

The `exports` folder is meant to contain files with environment variable names as their filenames and the content of those files as the value of the environment variable. It only contains a gitignore, which excludes all files in it. 

The `shlibs` folder is meant to contain shell scripts with functions that can be sourced into your shell.

# Installation

To use this repo, clone it to your home directory ~/.shlib and insert the snippet below into your shell's startup file (e.g. .bashrc, .zshrc, etc.).

```sh
# Clone the repo (use your own username)
git clone https://github.com/your_username/shlib.git ~/.shlib

# insert the following snippet into your shell's startup file

# Import all files in the exports directory as environment variables with its content as the value
export SHLIB_EXPORTS_DIR="$HOME/.shlib/exports"
for f in "$SHLIB_EXPORTS_DIR"/*; do [ -f "$f" ] && export "$(basename "$f")"="$(cat "$f")"; done

# Import functions from scripts in the shlibs directory
export SHLIB_EXPORTS_DIR="$HOME/.shlib/exports"
[ -d "$SHLIB_EXPORTS_DIR" ] && for f in "$SHLIB_EXPORTS_DIR"/*; do [ -f "$f" ] && export "$(basename "$f")"="$(cat "$f")"; done
```

# Crowing

* If you have developed new scripts, just commit and push and they are in the repo. This gives you a versioned collection of functions and scripts that you can use in your shell.

* Your environment variables from the exports folder are not saved in the repo (tokens, keys, etc.)because they are excluded in the .gitignore file.
```shell
# Ignore everything in this directory
*
# Except this file
!.gitignore
```



