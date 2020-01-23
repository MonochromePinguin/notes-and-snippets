#!/bin/bash
#Le but de ce code est de fournir une f° créant de manière (±) sûre une FIFO,
# même en cas d'appels concurrents par des sous-interpréteurs //es.
# cf la description de la f° ↓

shopt -s nullglob extglob

readonly cN=$'\e[0m'
readonly cR=$'\033[31m'


fonc='Test de création FIFO'


#toutes les FIFO seront créées ici
repFifo=

#suppression automatique du dossier des FIFO en fin de programme
#
trap 'kill -TERM 0;
	[ -n "$repFifo" ] && [ -d "$repFifo" ] && rmdir "$repFifo"' EXIT



nouvelleFifo()
#	Créée une fifo (de nom aléatoire) dans un répertoire temporaire (de nom
# aléatoire) sous /run/user/$UID/, et la connecte en E/S au descripteur de fic
# dont le n° est donné via $1.
#	Toutes les fifos créées par cette f° le sont dans le même dossier, soit
# celui créé par le shell ou sous-shell en cours, soit un dossier hérité du
# processus parent.
#	Elles sont supprimées/unlinkées à peine liées aux descripteurs d'E/S, afin
# qu'elles soient automatiquement détruites à la fin du processus.
#● à la terminaison (normale ou anormale) du sous-interpréteur ou du programme,
# ce répertoire est supprimé (via l'utilisation de «trap EXIT» soit dans l'interpréteur principal soit dans un sous-shell).
#●Pour éviter toute interférence et phénomène de concurrence entre deux processus utilisant un même dossier temporaire (l'un ayant hérité de $repFifo de
# l'autre), l'un se terminant tandis que l'autre créée le tuyau nommé, on
# pourrait assigner un répertoire par $BASHPID, mais pour me faire plaisir j'ai
# choisi d'utiliser un fichier verrou créé pour tester l'existence de $repFifo,
# et supprimé après la ligature du fichier aux fd du shell – la commande exécutée via TRAP étant rmdir et pas « rm -r » ...
#● 1 PARAMÈTRE :
#	$1	=	n° du df auquel relier la fifo
#● RETOUR :
#	renvoit 0 si tout s'est bien passé,
#	ou un code d'erreur + affiche un message d'erreur mentionnant «$fonc».
#	le df n° $1 est connecté en E/S à la FIFO.
#● VARIABLES LUES :
#	$fonc	=	nom de la f° appelante
#	repFifo	=	dossier contenant les fifo, NULL s'il n'a pas encore été créé
{
	local fifo
	local verrou

	#il est ERRONÉ d'appeler cette f° sans son paramètre numérique
	#
	{ [ $# = 1 ]  &&  [[ $1 == +([0-9]) ]]; } \
	|| {
		echo "$cR$fonc : il FAUT appeler nouvelleFifo() avec UN paramètre numérique ! Abandon.$cN" >&2
		return 3
	}

	#Création du dossier
	#
	while :
	do
	  case "$repFifo" in
		#il faut créer le dossier
		'')
			local umaskOld=$( umask )

			umask 077
			repFifo=$( mktemp -d -p /run/user/$UID/ sauvegardes-$BASHPID.XXX )
			umask "$umaskOld"

			[ $? = 0 ] && break

			#En cas d'erreur :
			repFifo=
			echo "$cR$fonc : impossible de créer le dossier temporaire pour les fifo. Abandon.$cN" >&2
			return 1
			;;

		#Le dossier a été créé par l'instance actuelle de BASH ; on ne sais rien
		# d'éventuelles instances ayant hérité de $repFifo, alors on verrouille
		/run/user/$UID/sauvegardes-$BASHPID.*)
			verrou=$repFifo/verrou.$BASHPID
			touch "$verrou" \
			|| {
				echo "$cR$fonc : impossible de poser un verrou lors de la création du dossier des fifo. Abandon.$cN"
				return 1
			}

			break
			;;

		#Le dossier a été créé par un processus parent –
		# on pose un verrou empêchant sa suppression éventuelle
		*)
			verrou=$repFifo/verrou.$BASHPID
			touch "$verrou"
			#si on peut créer le verrou, c'est que le dossier n'a pas été
			# supprimé entre-temps par une autre instance. Sinon on le créée !
			[ $? = 0 ] && break

			#si la création du verrou n'a pas marché, on boucle vers le cas ''
			repFifo=
			verrou=
	  esac
	done


	#Création de la FIFO proprement dite
	#
	fifo=$( mktemp -u -p "$repFifo" fifo-$BASHPID.XXX )	#nom de la FIFO
	{ [[ -n $fifo ]] \
	  &&  mkfifo -m 600 -- "$fifo"; } \
	|| {
		echo "$cR$fonc : impossible de créer la fifo. Abandon.$cN" >&2
		return 2
	}

	#les 2 extrémités de la fifo sont liées au même df – en les ouvrant simultanément, on évite l'interblocage (l'ouverture de l'extrémité d'une fifo ne termine que quand l'autre extrémité est aussi ouverte)
	eval "exec $1<> '$fifo'"

#	#la fifo étant ouverte, on peut la délier du FS, et supprimer l'éventuel
# fichier verrou ; le dossier, lui, sera supprimé via « trap EXIT ».
	rm "$fifo"
	[ -n "$verrou" ] && rm "$verrou"

	return 0
}



nouvelleFifo 3
[ $? = 0 ] || {
	echo 'BUG !'
	exit 1
}

(	while :
	do
		echo "Le nom du dossier est «$repFifo»" >& 3
		sleep 1
	done
)\
& (
	while :
	do
		read -u 3 ln
		echo "lu : $ln"
		sleep 1
	done
)


