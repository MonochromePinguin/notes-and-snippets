#!/bin/bash
#À partir d'une étendue numérique (représentant les entrées d'un tableau !),
#produit les indices de 𝑛 portions de cette étendue les plus égales possible –
# le reste de la division est réparti entre les différentes parts.
#● APPLICATION : diviser le contenu d'un tableau en 𝑛 parties parcourues
# parallèlement par des sous-interpréteurs ...
#


#Quantité totale
readonly tailleTot=$RANDOM

#Nombre de parts
readonly nbParts=$(( 1 + RANDOM / 3277 ))

readonly part=$(( $tailleTot / nbParts ))
declare -i reste=$(( $tailleTot % nbParts ))

declare -i ofsPrec ofsDeb ofsFin


#variables ne servant qu'à la vérification
declare -i total=0
nb=


echo "ensemble de $tailleTot, divisé en $nbParts (reste $reste) :"

for (( x=0;  x < $nbParts; x++ ))
do
	ofsDeb=$ofsPrec

	# 3" terme de la somme : si x>0, décr x et renvoit 1 – sinon renvoit 0
	ofsPrec+=$(( part + ( reste>0 ? (reste--, 1) : 0 ) ))
	ofsFin=$(( ofsPrec -1 ))

	nb=$(( ofsPrec - ofsDeb ))

	echo "	part n°$((x+1)) : de $ofsDeb à $ofsFin ; $nb entrées"
	total+=$nb
done

echo "total des parts : $total, écart $(( tailleTot - total )),"
echo "reste non-utilisé : $reste"

