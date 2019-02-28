#!/bin/bash
## codes de contrôle : couleur du texte
## voir « /usr/share/doc/divers/Xwindow, XTerm, glX/Codes de Contrôle »
# pour plus d'infos

# "normal", "rouge", "jaune", "orange" & "kaki"
readonly cN=$(tput sgr0)		#pourla console linux : $'\e[0m'
readonly cJ=$(tput setaf 11)	# SSI 16coul.			$'\033[93m'
readonly cO=$'\033[33m'
readonly cR=$(tput setaf 1)		#						$'\033[31m'
readonly cK=$'\033[32m'

#codes 256 couleurs (pourpre, jaune pâle)
readonly cP=$'\e[38;5;197m'
readonly cJB=$'\e[38;5;192m'

#gras et non-gras
readonly cG=$(tput smso)
readonly cNG=$(tput rmso)

