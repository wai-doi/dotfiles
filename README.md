# dotfiles

## Setup

Install [Homebrew](https://brew.sh) and [add an SSH key to GitHub](https://docs.github.com/en/authentication/connecting-to-github-with-ssh), then run:

```
$ git clone git@github.com:wai-doi/dotfiles.git ~/dotfiles
$ cd ~/dotfiles
$ brew install mise
$ mise trust
$ mise dot apply
```

## Usage

When you add new dotfiles in this repository, add them to `[dotfiles]` in `mise.toml` and run:

```
$ mise dot apply
```

### homebrew

```
# install
$ brew bundle --no-lock

# dump
$ brew bundle dump -f && sed -i '' '/^vscode/d' Brewfile
```

