# dotfiles

## Usage

When you add new dotfiles in this repository, add them to `[dotfiles]` in `mise.toml` and run:

```
$ mise trust  # first time only
$ mise dot apply
```

### homebrew

```
# install
$ brew bundle --no-lock

# dump
$ brew bundle dump -f && sed -i '' '/^vscode/d' Brewfile
```

