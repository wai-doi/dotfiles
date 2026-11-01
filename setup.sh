#!/bin/bash

ln_with_mkdir() {
  target="$HOME/$1"
  mkdir -p "$(dirname "$target")"
  ln -snfv "$PWD/$1" "$target"
}

dotfiles=(
  ".bundle/config"
  ".config/mise/config.toml"
  ".config/starship.toml"
  ".config/cmux/cmux.json"
  ".config/ghostty/config"
  ".config/git/config"
  ".config/git/ignore"
  ".config/git/hooks"
  ".config/lazygit/config.yml"
  ".config/micro/settings.json"
  ".config/yazi/yazi.toml"
  ".config/yazi/keymap.toml"
  ".config/yazi/plugins"
  ".peco/config.json"
  ".gemrc"
  ".psqlrc"
  ".irbrc"
  ".pryrc"
  ".tigrc"
  ".vimrc"
  ".zshrc"
  "iterm_settings/com.googlecode.iterm2.plist"
)

for entry in "${dotfiles[@]}"; do
  for file in $(find "$entry" -type f); do
    ln_with_mkdir "$file"
  done
done

# Create local zsh env file if missing (not tracked by git)
if [ ! -f "$HOME/.zshrc.local" ]; then
  touch "$HOME/.zshrc.local"
  echo "Created $HOME/.zshrc.local"
fi

echo "Dotfiles setup complete!"
