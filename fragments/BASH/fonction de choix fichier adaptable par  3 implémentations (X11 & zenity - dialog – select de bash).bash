#!/bin/bash

## Fonction permettant de choisir un dossier ou fichier au sein de l'arborescence
# d'un répertoire donné.
# En fonction de la présence de $XAUTHORITY et des programmes zenity & dialog,
# une des 3 implémentations (zenity sous X11, dialog en console, SELECT de bash
# en console) sera déclarée.
#
# ATTENTION À LA DUPLICATION DE CODE :
# Si ces 3 fonctions devaient être implémentées dans un même fichier,
# du code en début et en fin de fonction serait à factoriser !


## ● DÉPENDANCES : ** nécessite qu'extglob soit armé **
shopt -s extglob


## Fonction demandant de choisir un dossier ou un fichier au sein de $2,
# proposant $1 comme choix par défaut, et ayant pour titre $3.
# Elle ne rends la main que lorsqu'un choix a été réalisé ou l'opération abandonnée.
#_ La sélection doit être au sein de $2 après résolution des liens symboliques.
#
#● 4 PARAMÈTRES :
#	$1 == cible par défaut.
#	$2 == dossier au sein duquel la sélection doit être contenue ou égale.
#		En cas de liens symbolique choisi, son chemin réel doit être au sein de $2
#	$3 == titre à afficher (BdDial ou texte en ligne-de-comm)
#	$4 == type de sélection (FACULTATIF) :
#				0 → sélection d'un dossier (valeur par défaut)
#				1 → "		"	   fichier
#				2 → "		"	   dossier ou fichier
#
#● SORTIE :
#• 0 si choix effectué, ≠ 0 si abandon.
#• si $? == 0 :
#	la variable globale ** $destination ** est armée au chemin de la sélection
#	**RELATIF** à $2, qui vaudra :
#		_ "."		si la destination choisie est le dossier $2,
#		_ le sous-répertoire choisi, SLASH TERMINAL INCLU,
#		_ ou le fichier choisi.
#
#● VARIABLE MODIFIÉE :
#		$destination

if [[ -n $XAUTHORITY && -n $(which zenity) ]]
then

	#codes de couleur
	declare -r cR=$(tput setaf 1)
	declare -r cN=$(tput sgr0)

  BdDialChoixDossier()
  {
	# $2 doit être un dossier
	[[ -d $2 ]] || {
		echo "${cR}Le paramètre «$2» n'est pas un dossier accessible$cN"
		return 2
	}

	#vérification de la cohérence entre $4 et $1
	case "$4" in
		1)
			[[ -f $1 ]] || {
				echo "${cR}«$1» n'est pas un fichier !$cN"
				return 1
			}
			;;
		2)
			[[ -e $1 ]] || {
				echo "${cR}Le paramètre «$1» est inaccessible$cN"
				return 1
			}
			;;
		*)
			[[ -d $1 ]] || {
				echo "${cR}«$1» n'est pas un dossier !$cN"
				return 1
			}
			;;
	esac


	#Quels types de sélection sont autorisés :
	case "$4" in
		0)
			local autoriseDossier=1
			;;
		1)
			local autoriseFichier=1
			;;
		2)
			local autoriseDossier=1
			local autoriseFichier=1
			;;
		*)
			local autoriseDossier=1
	esac

	local titre=$3


	#la sélection DOIT appartenir à l'arborescence de ce dossier.
	# normalisé par la suppression des slash surnuméraires
	local ancetreSelection=${2//+('/')/'/'}

	# chemin canonique de ce dossier ancêtre
	local ancetreRealpath=$( realpath -- "$ancetreSelection")


	local selectionInitiale=${1//+('/')/'/'}

	## test de l'appartenance ce la sélection initiale à $ancetreSelection
	# après résolution des liens symboliques.
	# À défaut, la sélection initiale est ramenée à l'ancêtre autorisé.
	[[ $(realpath -- "$selectionInitiale") != $ancetreRealpath?(|/*) ]] \
	&& {
		selectionInitiale=$ancetreSelection
	}


	#paramètres additionnels de zenity : armé s'il faut sélectionner un dossier
	# (par défaut).
	local params
	[[ $4 = 0 || -z $4 ]] && params=--directory

	local result

	while :
	do
		result=$( WINDOWID=  zenity --title="$titre" --file-selection $params\
					--filename="$selectionInitiale" 2>/dev/null )

		#si le code de retour est ≠ 0, c'est qu'on a annulé la sélection
		[[ $? = 0 ]] || return 1

		#on refuse une sélection hors du dossier ancêtre passé en $2
		# après résolution des liens symboliques
		[[ $(realpath -- "$result") != ${ancetreRealpath%/}?(|/*) ]] \
		&& {
			titre="SÉLECTION LIMITÉE À LA DESCENDANCE DE «$ancetreSelection» HORS LIENS SYMB. – $3"
			continue
		}

		#Le résultat doit être du type attendu (fichier &/ou dossier)
		#
		[[ -z $autoriseDossier  &&  -d $result ]] && {
			$titre="LE CHOIX DOIT ÊTRE UN FICHIER ! – $3"
			continue
		}
		[[ -z $autoriseFichier  && -f $result ]] && {
			$titre="LE CHOIX DOIT ÊTRE UN DOSSIER ! – $3"
			continue
		}

		break
	done

	# ajustement du résultat
	#
	if [[ -d $result ]]
	then
		# ... pour dossier
		if [[ $(realpath -- "$result") = $ancetreRealpath ]]
		then
			destination=.
		else
			#zenity ne met PAS de slash terminal, mais le résultat DOIT en avoir.
			#la combinaison de ces 2 instructions prends en compte le cas
			# particulier de $ancetreRealpath=/
			destination=${result#"$ancetreSelection"}/
			destination=${destination#/}
		fi
	else
		# ... pour fichier
		destination=${result#"$ancetreSelection"}
		destination=${destination#/}
	fi

	return 0
  }



elif which dialog >/dev/null
#Pas sous X11 ou sans zenity, mais «dialog» est disponible
then


  BdDialChoixDossier()
  {
	# $2 doit être un dossier
	[[ -d $2 ]] || {
		echo "${cR}Le paramètre «$2» n'est pas un dossier accessible$cN"
		return 2
	}

	#vérification de la cohérence entre $4 et $1
	case "$4" in
		1)
			[[ -f $1 ]] || {
				echo "${cR}«$1» n'est pas un fichier !$cN"
				return 1
			}
			;;
		2)
			[[ -e $1 ]] || {
				echo "${cR}Le paramètre «$1» est inaccessible$cN"
				return 1
			}
			;;
		*)
			[[ -d $1 ]] || {
				echo "${cR}«$1» n'est pas un dossier !$cN"
				return 1
			}
			;;
	esac


	#coordonnées de la fenêtre de sélection
	local Xt Yt

	local titre=$3
	local hline

	#mode de sélection fourni à dialog :
	local paramSelection

	case "$4" in
	  1)
		# ... fichier (2 panneaux)
		hline='Sélectionner le fichier dans le panneau supérieur droit'
		paramSelection=--fselect
		local autoriseFichier=1
		;;
	  2)
		# ... fichier ou dossier
		hline='Sélectionner le fichier ou dossier dans le panneau supérieur droit'
		paramSelection=--fselect
		local autoriseDossier=1
		local autoriseFichier=1
		;;
	  *)
		# ... dossier (1 panneau affiché)
		hline='Sélectionner le dossier dans le panneau supérieur'
		paramSelection=--dselect
		local autoriseDossier=1
		;;
	esac


	#la sélection DOIT appartenir à l'arborescence de ce dossier.
	# normalisé par la suppression des slash surnuméraires
	local ancetreSelection=${2//+('/')/'/'}

	# chemin canonique de ce dossier ancêtre
	local ancetreRealpath=$( realpath -- "$ancetreSelection")


	local selectionInitiale=${1//+('/')/'/'}

	## test de l'appartenance ce la sélection initiale à $ancetreSelection
	# après résolution des liens symboliques.
	# à défaut, la sélection initiale est ramenée à l'ancêtre autorisé
	[[ $(realpath -- "$selectionInitiale") != $ancetreRealpath?(|/*) ]] \
	&& {
		selectionInitiale=$ancetreSelection
	}

	local result

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

		#on refuse une sélection hors du dossier ancêtre passé en $2
		# après résolution des liens symboliques
		[[ $(realpath -- "$result") != ${ancetreRealpath%/}?(|/*) ]] \
		&& {
			titre="! EMPLACEMENT LIMITÉ À LA DESCENDANCE DE «$ancetreSelection» ! – $3"
			continue
		}

		#Le résultat doit être du type attendu (fichier &/ou dossier)
		#
		[[ -z $autoriseDossier  &&  -d $result ]] && {
			titre="! LE CHOIX ÊTRE UN FICHIER ! – $3"
			continue
		}
		[[ -z $autoriseFichier  &&  -f $result ]] && {
			titre="! LE CHOIX DOIT ÊTRE UN DOSSIER ! – $3"
			continue
		}

		break
	done

	if [[ $(realpath -- "$result") == $ancetreRealpath ]]
	then
		destination=.
	else
		#contrairement à zenity, dialog met un slash terminal aux répertoires,
		# il n'y a pas besoin de l'ajouter
		destination=${result#"$ancetreSelection"}
		destination=${destination#/}
	fi

	return 0
  }



else
#ni X11, ni zenity, ni dialog : on demande d'entrer le répertoire à la main

	#codes de couleur
	declare -r cN=$(tput sgr0)
	declare -r cO=$(tput setaf 3)
	declare -r cJ=$(tput setaf 11)
	declare -r cR=$(tput setaf 1)
	declare -r cG=$(tput bold)

 BdDialChoixDossier()
  {
	# $2 doit être un dossier
	[[ -d $2 ]] || {
		echo "${cR}Le paramètre «$2» n'est pas un dossier accessible$cN"
		return 2
	}

	#vérification de la cohérence entre $4 et $1
	case "$4" in
		1)
			[[ -f $1 ]] || {
				echo "${cR}«$1» n'est pas un fichier !$cN"
				return 1
			}
			;;
		2)
			[[ -e $1 ]] || {
				echo "${cR}Le paramètre «$1» est inaccessible$cN"
				return 1
			}
			;;
		*)
			[[ -d $1 ]] || {
				echo "${cR}«$1» n'est pas un dossier !$cN"
				return 1
			}
			;;
	esac


	#utilisé comme séparateur au sein des listes de nom !
	local IFS=$'\n'

	#peut-on armer $COLUMNS au sein de la f° ?
	[[ -n $(which tput) && -n $TERM ]]
	local -r armerNbCols=$?


	# option indiquant le type d'objet sélectionnable
	case "$4" in
		0)	#répertoires seulement
			local optionSelection=-d ;;
		1) # fichier seulement
			local optionSelection=-f ;;
		2)
			local optionSelection='' ;;
		*)
			local optionSelection=-d ;;
	esac
echo "●optionSelection : $optionSelection"


	#la sélection DOIT appartenir à l'arborescence de ce dossier.
	# normalisé par la suppression des slash surnuméraires
	local ancetreSelection=${2//+('/')/'/'}

	# chemin canonique de ce dossier ancêtre
	local ancetreRealpath=$( realpath -- "$ancetreSelection")


	local selectionActuelle=${1//+('/')/'/'}

	## test de l'appartenance ce la sélection initiale à $ancetreSelection
	# après résolution des liens symboliques.
	# À défaut, la sélection initiale est ramenée à l'ancêtre autorisé.
	[[ $(realpath -- "$selectionActuelle") != $ancetreRealpath?(|/*) ]] \
	&& {
		selectionInitiale=$ancetreSelection
	}


	#dossier initial pour le cas où la sélection initiale est un fichier
	local dossierParent
	if [[ $selectionActuelle = $ancetreSelection ]]
	then
		dossierParent=$ancetreSelection
	else
		dossierParent=$(dirname -- "$selectionActuelle")
	fi
echo "●● $dossierParent / $selectionActuelle"


	#faut-il afficher les dossiers & fichiers cachés ?
	#
	# $hidden sert à la fois de drapeau, et d'indice aux sein de ces 2 tableaux,
	# $optionModif[] et $verbeHidden[] :
	# _ $optionModif[$hidden] indique le paramètre à passer à compgen
	#   ( -X : motif des fichiers à exclure),
	# _ $verbeHidden[$hidden]  le libellé de l'action affichée dans la liste
	local hidden=0

	local -r optionMotif=( '-X.*' '' )

	local -r verbeHidden=(
			"${cJ}Afficher les dossiers cachés$cN"
			"${cJ}Ne pas afficher les dossiers cachés$cN" )


	#Peut-on passer dans le dossier parent
	# (le choix doit rester au sein de l'arborescence de $2) ?
	#
	# → option «remonter» conditionnellement activée.
	# $autoriserRemonter sert d'indice au sein de $verbeRemonter[]
	[[ $selectionActuelle != $ancetreSelection ]]
	local autoriserRemonter=$?

	local -r verbeRemonter=(
			"${cO}Le choix est cantonné à l'arborescence de «$cG$ancetreSelection$cN$cO». Pas de remontée autorisée.$cN"
			"${cJ}Remonter$cN" )


	#la sauvegarde du répertoire de travail est nécessaire car on
	# chdir avant d'afficher la liste des sous-dossiers
	local -r oldPWD=$PwD

	cd -- "$dossierParent" || {
		echo "${cR}Erreur : dossier «$cG$dossierParent$cR» inaccessible. Abandon.$cN" >&2
		return 1
	}


#TODO :
#_ versions Zenity & dialog OK,
#● zenity ne peut pas sélectionner « fichier OU dossier » !
#
#• pour dernière implémnetation :
# _ répercuter modifications signature sur le code de la dernière fonction.
# _ afficher conditionnellement les choix «sélectionner» et «aller dans »
#   suivant la possibilité de sélectionner un fichier &/ou un dossier
# _ tester si la $destination fournie par la dernière version correspond à la
#	description : «.», dossier avec slash, chemin relatif à $2.
#● màj.sh : répondre NON à « copier .../BASH/bouts de code/ » le copie quand même !?
	until [[ $destination =~ $ancetreSelection/* ]]
	do
		#affiche le titre, la sélection actuelle, le dossier actuel
		echo "$cG$cO●● $3 ●●$cN"
		echo
		echo "Sélection en cours : «$cJ$cG$(basename "$selectionActuelle")$cN»"
		echo "dossier actuel «$cJ$cG$PWD$cN»"
		echo

		#récupère la liste des objets sélectionnables sous $dirActu
		liste=( $( compgen  "$optionSelection"  "${optionMotif[ $hidden ]}" ) )

		#met à jour la taille d'écran disponible pour "select"
		[[ $armerNbCols = 0 ]] && {
			COLUMNS=$(tput cols)
			LINES=$(tput lines)
		}

		select rep in \
			${cJ}Sélectionner$cN \
			${cJ}Annuler$cN \
			"${verbeRemonter[ $autoriserRemonter ]}" \
			"${verbeHidden[ $hidden ]}" \
			"${liste[@]}"
		do
		  case "$REPLY" in
			1) #Sélectionner
				destination=$selectionActuelle
				[[ -d $destination ]] && destination+=/
				cd -- "$oldPWD"; return 0
				;;

			2) #Annuler
				cd -- "$oldPWD"; return 1
				;;

			3) #Remonter vers répertoire parent
				if [ $autoriserRemonter = 0 ]
				then
					echo "${cR}Non ! Le choix est limité à l'arborescence de «$cG$ancetreSelection$cR».$cN" >&2
					echo
				else
					cd ..
					[[ $PWD = $ancetreSelection ]] && autoriserRemonter=0
				fi

				selectionActuelle=$PWD ← pour un dossier ; mais pour un fichier ?
				dossierParent= ????
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
					cd "$rep" || { ← ou dossier parent pr sélection fichiers !
						echo "${cR}Impossible de passer dans «$cG$rep$cN$cR»$cN" >&2
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

fi


echo ---
BdDialChoixDossier "/home/self/C" "/" "dans /"
echo "rés $? / sélection : $destination (dans /)"
echo ---
BdDialChoixDossier "/home/self/C" "/" "dans /"
echo "rés $? / sélection : $destination (dans /)"
echo ---
BdDialChoixDossier "/home/self/C" "/home/self/" "dans /home/self/"
echo "rés $? / sélection : $destination dans (/home/self/)"
echo ---
BdDialChoixDossier "/home/self/Zique" "/home/self" "dans /home/self"
echo "rés $? / sélection : $destination dans (/home/self)"
echo ---
BdDialChoixDossier "/home/self//C//" "/home/self///" "dans /home/self///"
echo "rés $? / sélection : $destination (dans /home/self///)"

echo ---
BdDialChoixDossier "/" "/" "fichier dans /" 1
echo "rés $? / sélection : $destination (dans /)"
echo ---
BdDialChoixDossier "/home/self/notes VIM" "/home/self/" "fichier dans dans /home/self/" 1
echo "rés $? / sélection : $destination (dans /home/self/)"
echo ---
BdDialChoixDossier "/home/self/Zique" "/home/self/" "fichier dans dans /home/self//" 1
echo "rés $? / sélection : $destination (dans /home/self)"

