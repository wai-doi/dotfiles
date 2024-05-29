# dotfiles
## Usage
When you add new dotfiles in this repository, execute `./setup.sh` to create Sybmolic links at your home directory.
```
% ./setup.sh
```

### homebrew
```
# install
% brew bundle --no-lock

# dump
% brew bundle dump -f
```

### gem-src

Install [gem-src](https://github.com/amatsuda/gem-src)

```
% git clone https://github.com/amatsuda/gem-src.git "$(rbenv root)/plugins/gem-src"
```
