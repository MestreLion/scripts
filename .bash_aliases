#!/bin/bash

alias ls="ls --color=auto --group-directories-first -1"
alias ll="ls -l"
alias la="ll -A"
alias cd..="cd .."
alias cd...="cd ../.."
alias cd....="cd ../../.."
alias cd.....="cd ../../../.."
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias path="echo \$PATH"
alias fstab="gksudo gedit /etc/fstab &"
alias which="type -P"

cdl() { cd "$@" && ll ; }
