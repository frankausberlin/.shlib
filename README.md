This repo contains two folders: `exports` and `shlibs`. 

The `exports` folder is meant to contain files with environment variable names as their filenames and the content of those files as the value of the environment variable. It only contains a gitignore, which excludes all files in it. 

The `shlibs` folder is meant to contain shell scripts with functions that can be sourced into your shell. It also only contains a gitignore, which excludes all files in it.

# Installation

To use this repo, clone it to your home directory ~/.shlib and insert the snippet below into your shell's startup file (e.g. .bashrc, .zshrc, etc.).

```sh
# Clone the repo (use your own username)
git clone https://github.com/your_username/shlib.git ~/.shlib

# insert the following snippet into your shell's startup file

# Import all files in the exports directory as environment variables with its content as the value
export SHLIB_EXPORTS_DIR="$HOME/.shlib/exports"
[ -d "$SHLIB_EXPORTS_DIR" ] && for f in "$SHLIB_EXPORTS_DIR"/*(N); do [ -f "$f" ] && export "$(basename "$f")"="$(cat "$f")"; done

export SHLIB_LIB_DIR="$HOME/.shlib/shlibs"
[ -d "$SHLIB_LIB_DIR" ] && for s in "$SHLIB_LIB_DIR"/*(N); do [ -f "$s" ] && source "$s"; done
```

* Your environment variables from the exports folder and your script files are not saved in the repo because they are excluded in the .gitignore file. (the folders are only in the repo to save an mkdir)
```shell
# Ignore everything in this directory
*
# Except this file
!.gitignore
```


# Usage

* After you have inserted the script snippets to read the folders into your starup file, you can store the scripts and exports in the respective folders and they will be loaded automatically.

* You can also use symbolic links: `ln -s /path/to/original/file /path/to/symlink`

* Another use case: after cloning, delete the .git folder and the .gitignore files in exports and shlibs. then make it a private repo and commit/push it. Now you have a versioned collection of scripts and exports that you can use in your shell.



