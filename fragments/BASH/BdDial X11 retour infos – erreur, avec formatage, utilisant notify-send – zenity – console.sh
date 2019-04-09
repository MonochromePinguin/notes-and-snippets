#!/bin/sh
## Fonction de retour d'information soit via une notification (notify-send),
# soit via une boîte d'information (notify-send),
# soit une ligne de texte colorée (en console)
#en fonction de $XAUTHORITY et de la présence des exécutables.

# Le titre comme le corps du texte peuvent contenir des marqueurs de début
# & de fin des zones à mettre en avant : €[ et €]. Ces deux combinaisons seront
# remplacées par les codes appropriés au mode d'affichage.
#● 3 PARAMÈTRES :
#	$1	=	titre de la fenêtre
#	$2	=	texte de la question
#	$3	=	booléen, 0 ou 1, indiquant le type d'info :
#				0 → info
#				1 → erreur



# "normal", "vert", "rouge"
readonly cN=$(tput sgr0)
readonly cV=$(tput setaf 10)
readonly cR=$(tput setaf 1)

#gras et non-gras
readonly cG=$(tput smso)
readonly cNG=$(tput rmso)


if [ ! -z "$XAUTHORITY" ] && which notify-send > /dev/null
then
	# • 2 paramètres :
	#	$1 == titre
	#	$2 == texte
	#	$3 == booléen d'état :  0 → info
	#							1 → erreur
	infos()
	{
		local titre texte

		titre=$(echo "$1" | sed 's/&/&amp;/g; s/€[][]//g')
		texte=$( echo "$2" | sed 's/&/&amp;/g; s-€\[-<span weight="bold">-g; s-€\]-</span>-g')

		[ -n $3  -a  $3 = 0 ] \
			&& icone=info \
			|| icone=error

		notify-send -u low -t 5000 -i "$icone" "$titre" "$texte"
	}

elif [ ! -z "$XAUTHORITY" ] && which zenity > /dev/null
then
	infos()
	{
		local titre texte

		titre=$(echo "$1" | sed 's/&/&amp;/g; s-€\[-<span weight="bold">-g; s-€\]-</span>-g')
		texte=$( echo "$2" | sed 's/&/&amp;/g; s-€\[-<span weight="bold">-g; s-€\]-</span>-g')

		[ -n "$3"  -a  "$3" = 0 ] \
			&& drapeau=info \
			|| drapeau=error

		WINDOWID='' zenity --$drapeau --title "$titre" --text "$texte" 2> /dev/null
	}
else
	infos()
	{

		[ -n "$3"  -a  "$3" = 0 ] \
			&& coul=$cV \
			|| coul=$cR
		titre=$(echo "$1" | sed "s/€\[/$coul/g; s/€\]/$coul/g")
		texte=$( echo "$2" | sed "s/€\[/$coul/g; s/€\]/$coul/g")

		echo "$titre : $cN$texte$cN"
	}
fi



## tests à exécuter avec ou sans XAUTHORITY
#
infos "titre" "texte de €[succès€] en €[gras ou vert€]" 0
infos "titre" "texte d'€[échec€], en €[gras ou rouge€]" 1

