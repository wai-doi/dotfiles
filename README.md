# dotfiles
## Usage
When you add new dotfiles in this repository, execute `./setup.sh` to create Symbolic links at your home directory.
```
% ./setup.sh
```

### homebrew
```
# install
% brew bundle --no-lock

# dump
% brew bundle dump -f && sed -i '' '/^vscode/d' Brewfile
```

