#!/bin/bash

## Fonction permettant de choisir un dossier ou fichier au sein de l'arborescence
# d'un répertoire donné.
# En fonction de la présence de $XAUTHORITY et des programmes zenity & dialog,
# une des 3 implémentations (zenity sous X11, dialog en console, SELECT de bash
# en console) sera déclarée.

## ● DÉPENDANCES : **nécessite qu'extglob soit armé **
shopt -s extglob



## Fonction demandant de choisir un dossier ou un fichier au sein de $2,
# proposant $1 comme choix par défaut, et ayant pour titre $3.
# Elle ne rends la main que lorsqu'un choix a été réalisé ou l'opération abandonnée.
#_ La sélection doit être au sein de $2 après résolution des liens symboliques.
#
#● 4 PARAMÈTRES :
#	$1 == cible par défaut.
#	$2 == dossier au sein duquel la sélection doit être contenue.
#		En cas de liens symbolique choisi, son chemin réel doit être au sein de $2
#	$3 == titre à afficher (BdDial ou texte en ligne-de-comm)
#	$4 == type de sélection (FACULTATIF) :
#				0 → sélection d'un dossier (valeur par défaut)
#				1 → "		"	   fichier
#				2 → "		"	   dossier ou fichier
#
#● SORTIE :
#• retourne 0 si choix effectué, ≠ 0 si abandon.
#• si $? == 0,
# arme le chemin **RELATIF** à $2 de la sélection sera dans $destination, qui vaudra :
#		_ "."		si la destination choisie est le dossier $2,
#		_ le sous-répertoire choisi, SLASH TERMINAL INCLU,
#		  ou le fichier choisi.
#
#● VARIABLE MODIFIÉE :
#		$destination
if [[ -n $XAUTHORITY && -n $(which zenity) ]]
then
  BdDialChoixDossier()
  {
	#Quels types de retour sont autorisés :
	local autoriseDossier=0
		[[ $4 = 0 || $4 = 2 ]] && autoriseDossier=1
	local autoriseFichier=0
		[[ $4 = 1 || $4 = 2 ]] && autoriseFichier=1

	local titre=$3

	#dossier devant contenir la sélection au sein de son arborescence – SANS slash terminal
	# normalisé par la suppression des slash surnuméraires et terminaux.
	local ancetreSelection=${2//+('/')/'/'}
	ancetreSelection=${ancetreSelection%'/'}

	local selectionInitiale=${1//+('/')/'/'}
	## la sélection initiale doit être un descendant de $ancetreSelection :
	# par le chemin donné en paramètre,
	# ET par le chemin canonique.
	[[ $selectionInitiale =~ $ancetreSelection?(/*) ]] \
	&& [[ $(readlink -f "$selectionInitiale") =~ $(readlink -f "$ancetreSelection")?(/*) ]] \
	|| {
		# la sélection initiale est ramenée à l'ancêtre autorisé
		selectionInitiale=$ancetreSelection
	}

	#paramètres additionnels de zenity
	local params=
		[[ $4 = 0 || -z $4 ]] && params=--directory

	local result=

	while :
	do
		result=$( WINDOWID=  zenity --title="$titre" --file-selection $params\
					--filename="$selectionInitiale" 2>/dev/null )

		#si le code de retour est ≠ 0, c'est qu'on a annulé la sélection
		[[ $? = 0 ]] || return 1

		#on refuse une destination hors du dossier passé en $2
		# (y compris après résolution des liens symboliques)
		# la vérification inclus $2 ET sa descendance
		if [[ $result != $ancetreSelection  &&  $result != $ancetreSelection/* ]] \
			|| [[ $(realpath -- "$result") != $ancetreSelection  \
					&& $(realpath -- "$result") != $ancetreSelection/* ]]
		then
			titre="! EMPLACEMENT LIMITÉ À LA DESCENDANCE DE «$ancetreSelection/» ! – $3"
			continue
		fi

		#Le résultat doit être du type attendu (fichier &/ou dossier)
		#
		[[ $autoriseDossier = 0  &&  -d $result ]] && {
			$titre="!!! LE CHOIX DOIT ÊTRE UN FICHIER – $3"
			continue
		}
		[[ $autoriseFichier = 0  && -f $result ]] && {
			$titre="!!! LE CHOIX DOIT ÊTRE UN DOSSIER – $3"
			continue
		}

		break
	done

	# ajustement du résultat
	if [[ -d $result ]]
	then
		# ... pour dossier
		if [[ $result = $ancetreSelection ]]
		then
			destination=.
		else
			#zenity ne met PAS de slash terminal, mais le résultat DOIT en avoir
			destination=${result#"$ancetreSelection"}/
		fi
	else
		# ... pour fichier
		destination=${result#"$ancetreSelection"}
	fi

	return 0
  }


elif which dialog >/dev/null
#Pas sous X11 ou sans zenity, mais «dialog» est disponible
then

  BdDialChoixDossier()
  {
	#coordonnées de la fenêtre de sélection
	local Xt Yt

	local titre=$3
	local hline

	#mode de sélection fourni à dialog
	local paramSelection
	local autoriseDossier=0
	local autoriseFichier=0

	#dossier au sein duquel doit se trouver le résultat – SANS slash terminal
	local ancetreSelection=${2//+('/')/'/'}
	ancetreSelection=${ancetreSelection%'/'}

	local selectionInitiale=${1//+('/')/'/'}
	## la sélection initiale doit être un descendant de $ancetreSelection :
	# par le chemin donné en paramètre,
	# ET par le chemin canonique.
	[[ $selectionInitiale =~ $ancetreSelection?(/*) ]] \
	&& [[ $(readlink -f "$selectionInitiale") =~ $(readlink -f "$ancetreSelection")?(/*) ]] \
	|| {
		# la sélection initiale est ramenée à l'ancêtre autorisé
		selectionInitiale=$ancetreSelection
	}

	local result

	#mode de fonctionnement :
	if [[ $4 = 0 ]]
	then
		# ... dossier (1 panneau affiché)
		hline='Sélectionner le dossier dans le panneau supérieur'
		paramSelection=--dselect
		autoriseDossier=1
	elif [[ $4 = 1 ]]
	then
		# ... fichier (2 panneaux)
		hline='Sélectionner le fichier dans le panneau supérieur droit'
		paramSelection=--fselect
		autoriseFichier=1
	else
		# ... fichier ou dossier
		hline='Sélectionner le fichier ou dossier dans le panneau supérieur droit'
		paramSelection=--fselect
		autoriseDossier=1
		autoriseFichier=1
	fi

	while :
	do
		#obtient la taille actuelle du terminal
		Xt=$(tput cols)
		Yt=$(tput lines)

		#validation des 2 variables : symboles de début et fin de ligne utilisés
		# pour être sûr qu'il n'y ait que des chiffres
		{ [[ $Xt =~ ^[0-9]+$ ]] && (( Xt -= 6 )); } || Xt=0
		{ [[ $Yt =~ ^[0-9]+$ ]] && (( Yt -= 16 )); } || Yt=0

		#l'ordre des redirections au sein de la substitution de commande
		# est important !
		# le fd n°3 devient une copie du n°1, puis le n°1 une copie du n°4
		{
			result=$( 3>&1 1>&4 dialog --keep-tite --title "$titre" \
				--backtitle 'Échap ↑ ↓ Tab, ENTRÉE → Accepter choix, ESPACE → autocompléter, SLASH → chdir' \
				--hline "$hline" \
				$paramSelection "$selectionInitiale" \
				$Yt $Xt   --output-fd 3 )
		} 4>&1

		# dialog renvoit un code d'erreur ≠ 0 si le choix a été abandonné
		# (cf page man)
		[[ $? = 0 ]] || return 1

		#on refuse une destination hors du dossier passé en $2
		# (y compris après résolution des liens symboliques)
		# la vérification inclus $2 ET sa descendance
		if [[ $result != $ancetreSelection  &&  $result != $ancetreSelection/* ]] \
			|| [[ $(realpath -- "$result") != $ancetreSelection  \
					&& $(realpath -- "$result") != $ancetreSelection/* ]]
		then
			titre="! EMPLACEMENT LIMITÉ À LA DESCENDANCE DE «$ancetreSelection/» ! – $3"
			continue
		fi

		#Le résultat doit être du type attendu (fichier &/ou dossier)
		#
		[[ $autoriseDossier = 0  &&  -d $result ]] && {
			titre="! LE CHOIX ÊTRE UN FICHIER ! – $3"
			continue
		}
		[[ $autoriseFichier = 0  && -f $result ]] && {
			titre="! LE CHOIX DOIT ÊTRE UN DOSSIER ! – $3"
			continue
		}

		break
	done

	#contrairement à zenity, dialog met un slash terminal aux répertoires
	if [[ $result == $ancetreSelection/ ]]
	then
		destination=.
	else
		destination=${result#"$ancetreSelection"}
	fi

	return 0
  }

else
#ni X11, ni zenity, ni dialog : on demande d'entrer le répertoire à la main

##TODO : ces 2 lignes sont POUR LE DÉBOGUAGE !
:
fi
#TODO :
_ versions Zenity & dialog OK,
_ répercuter modifications signature sur le code de la dernière fonction, tester :
	« si $4 == 0, on s'assure que $1 est un dossier, et on ajoute un slash terminal. »
XXX tester si la $destination fournie par la dernière version correspond à la
description, et annoter le code cas "1" du «c.a.s.e $REPLY» :
	« si $1 est sélectionné, $destination vaut bien «.» »
_ utilisation de LINES & COLUMNS par la commande interne «select» à activer (cf man) !

 BdDialChoixDossier()
  {
	#codes de couleur
	local -r cN=$(tput sgr0)
	local -r cO=$(tput setaf 3)
	local -r cJ=$(tput setaf 11)
	local -r cR=$(tput setaf 1)
	local -r cG=$(tput bold)

	local IFS=$'\n'

	#la sauvegarde du répertoire de travail est nécessaire car on
	# chdir avant d'afficher la liste des sous-dossiers
	local -r oldPWD=$PwD

	#dossier au sein duquel doit se trouver le résultat – SANS slash terminal
	local ancetreSelection=${2//+('/')/'/'}
	ancetreSelection=${ancetreSelection%'/'}

	local selectionInitiale=${1//+('/')/'/'}
	## la sélection initiale doit être un descendant de $ancetreSelection :
	# par le chemin donné en paramètre,
	# ET par le chemin canonique.
	[[ $selectionInitiale =~ $ancetreSelection?(/*) ]] \
	&& [[ $(readlink -f "$selectionInitiale") =~ $(readlink -f "$ancetreSelection")?(/*) ]] \
	|| {
		# la sélection initiale est ramenée à l'ancêtre autorisé
		selectionInitiale=$ancetreSelection
	}


	#faut-il afficher les dossiers cachés ?
	# $hidden sert de drapeau et d'indice aux sein des 2 tableaux,
	# $optionMotif[] indique le paramètre à passer à compgen ( -X : motif
	#	des fichiers à exclure),
	# $verbeHidden le verbe à afficher dans le choix de changement d'affichage
	local hidden=0
	local optionMotif=( '-X.*' '' )
	local verbeHidden=(
			"${cJ}Afficher les dossiers cachés$cN"
			"${cJ}Ne pas afficher les dossiers cachés$cN" )

	#le choix doit être dans l'arborescence de $1
	# → option «remonter» conditionnellement activée
	local autoriserRemonter=0
	local verbeRemonter=(
			"${cO}Le choix est cantonné à l'arborescence de «$ancetreSelection». Pas de remontée autorisée.$cN"
			"${cJ}Remonter$cN" )

	cd "$selectionInitiale" || {
		echo "${cR}Erreur : dossier «$selectionInitiale» inaccessible. Abandon.$cN" >&2
		return 1
	}

	until [[ $destination =~ $ancetreSelection/* ]]
	do
		#affiche le titre
		echo "$cG$cO●● $3 ●●$cN"

		echo "dossier actuel «$cJ$cG$PWD$cN» :"

		#récupère la liste des dossiers sélectionnables sous $dirActu
		liste=( $( compgen -d ${optionMotif[ $hidden ]} ) )

		select rep in \
			${cJ}Sélectionner$cN \
			${cJ}Annuler$cN \
			"${verbeRemonter[ $autoriserRemonter ]}" \
			"${verbeHidden[ $hidden ]}" \
			"${liste[@]}"
		do
		  case "$REPLY" in
			1) #Sélectionner
				destination=$PWD/
				cd "$oldPWD"; return 0
				;;

			2) #Annuler
				cd "$oldPWD"; return 1
				;;

			3) #Remonter vers répertoire parent
				if [ $autoriserRemonter = 0 ]
				then
					echo "${cR}Non ! Le choix est limité à l'arborescence de «$cG$ancetreSelection$cR».$cN" >&2
					echo
				else
					cd ..
					[ "$PWD/" = "$1" ] && autoriserRemonter=0
				fi
				break
				;;

			4) #basculer l'affichage des dossiers cachés
				hidden=$(( ! hidden ))
				break
				;;

			#nécessite shopt -s extglob
			+([0-9]))
			#choix valides – on affiche le contenu
				if [ -n "$rep" ]
				then
					cd "$rep" || {
						echo "${cR}Impossible de passer dans «$cG$rep$cR»$cN" >&2
						break
					}
					autoriserRemonter=1
					break
				fi
				;& #l'exécution continue en cas d'erreur !

			*) #choix invalides !
				echo "${cR}choix invalide ! Entrer le n° de l'action à entreprendre ou du répertoire où se rendre$cN" >&2
				echo
				break
		  esac
		done

	done
  }

#....●●●●●●fi

BdDialChoixDossier "/home/self//Zique//" "/home/self///" "titre de test" 0
echo "$? / $destination"

