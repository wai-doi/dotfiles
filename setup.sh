#!/bin/bash

ln_with_mkdir() {
  target="$HOME/$1"
  mkdir -p "$(dirname "$target")"
  ln -snfv "$PWD/$1" "$target"
}

dotfiles=(
  ".bundle/config"
  ".config/starship.toml"
  ".config/ghostty/config"
  ".config/git/config"
  ".config/git/ignore"
  ".git_template/hooks/pre-push"
  ".peco/config.json"
  ".gemrc"
  ".irbrc"
  ".pryrc"
  ".tigrc"
  ".vimrc"
  ".zshrc"
  "iterm_settings/com.googlecode.iterm2.plist"
)

for file in "${dotfiles[@]}"; do
  ln_with_mkdir "$file"
done

# Create local zsh env file if missing (not tracked by git)
if [ ! -f "$HOME/.zshrc.local" ]; then
  touch "$HOME/.zshrc.local"
  echo "Created $HOME/.zshrc.local"
fi

echo "Dotfiles setup complete!"
