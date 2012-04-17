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
alias open="xdg-open"
alias pygettext-singularity="pygettext --output-dir=data code/*.py code/graphics/*.py code/screens/*.py"

cdl()     { cd "$@" && ll ; }
md()      { mkdir "$@" ; cd "${@: -1}" ; }
which()   { builtin type -P "$@" ; }
sudo()    { cmd=$(type -P "$1") ; shift ; command sudo "$cmd" "$@" ; }
sprunge() { echo "$(curl -sSF 'sprunge=<${1--}' http://sprunge.us)${2+?$2}${3+#n-$3}"; }


