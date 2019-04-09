#!/bin/bash

## drapeau de parallélisation ET de sortie graphique/texte :
# sous X11		→	BdDial, questions multiples par différents processus
# mode texte	→	1 question affichée à la fois
Qseq=
[[ -n $XAUTHORITY ]] && which zenity > /dev/null 2>&1 || Qseq=1



# "normal", "rouge", "jaune", "rouge" & "pourpre (code 256 coul)"
readonly cN=$(tput sgr0)
readonly cJ=$(tput setaf 11)
readonly cR=$(tput setaf 1)
readonly cP=$'\e[38;5;197m'

#gras et non-gras
readonly cG=$(tput smso)
readonly cNG=$(tput rmso)




#Cette fonction pose une question demandant une réponse par oui ou non. Le texte
# de la question peut contenir des marqueurs de début & de fin des zones à
#mettre en avant : €[ et €]. Ces deux combinaisons seront remplacées par les
# codes appropriés au mode d'affichage.
#● 2 PARAMÈTRES :
#	$1	=	titre de la fenêtre
#	$2	=	texte de la question
#● RETOUR :
#	0 → oui, 1 → non, autre valeur → erreur pendant l'opération
if [ -z $Qseq ]
then
	simpleQuestion()
	{
		local titre texte

		[ $# = 2 ] ||\
		{
			echo "${cR}simpleQuestion() : il faut DEUX paramètres !$cN" >&2
			return 255
		}

		titre=${1//€?}

		texte=${2//€[/<span weight=\"bold\">}
		texte=${texte//€]/</span>}

		WINDOWID=''  zenity --question \
			--title "${titre//&/&amp;}" --text "${texte//&/&amp;}" 2> /dev/null
		return $?
	}
else
	simpleQuestion()
	{
		local r titre texte

		[ $# = 2 ] ||\
		{
			echo "${cR}simpleQuestion() : il faut DEUX paramètres !$cN"
			return 255
		}

		titre=${1//€[/$cG}
		titre=${titre//€]/$cNG}

		texte=${2//€[/$cP}
		texte=${texte//€]/$cJ}

		while :
		do
			echo -e "$cJ$titre : $cN$texte\n\t${cP}O${cJ}ui / ${cP}N${cJ}on ?$cN"
			read r
			case $r in
				[oO])	return 0 ;;
				[nN])	return 1 ;;
				*)
					echo "${cR}Quoi ? Essaie encore !$cN"
			esac
		done
	}
fi



## test
simpleQuestion 'titre de la fenêtre' \
			'texte de la question. Avec une €[zone surlignée€]'
rep=$?
echo "La valeur brute renvoyée était « $cP$rep$cN »".

