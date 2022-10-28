DOTPATH    := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
CANDIDATES := $(wildcard .??*)
EXCLUSIONS := .DS_Store .git .gitmodules .travis.yml
DOTFILES   := $(filter-out $(EXCLUSIONS), $(CANDIDATES))

install:
	@echo 'install'
	@$(foreach val, $(DOTFILES), echo $(abspath $(val));)

clean:
	@echo 'clean'
