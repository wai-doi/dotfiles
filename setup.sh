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
  ".git_template/hooks/pre-push"
  ".peco/config.json"
  ".gemrc"
  ".gitconfig"
  ".gitignore_global"
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

echo "Dotfiles setup complete!"
