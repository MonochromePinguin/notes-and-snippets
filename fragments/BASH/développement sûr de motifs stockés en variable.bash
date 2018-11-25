#!/bin/bash
# Ce test visait à trouver une méthode permettant d'obtenir tt les fichiers
#correspondant à un motif tiré d'une variable – ici, un tableau, mais dans le
#script auquel le code est destiné (màj.sauvegardes.sh), les données tirées
# d'une BdD SQLite.
#	Le motif étant stocké dans une variable, le seul moyen de le soumettre au
#développement des chemins (afin de remplir un tableau) est d'utiliser «eval».
#Ce qui demande de la réflexion sur les protections pour prendre en compte
#toutes les possibilités de nom légales et les conflits éventuels avec les
#caractères spéciaux & jokers de bash ...

#	Le compromis auquel je suis parvenu est que le motif doit contenir le nom
#de fichier tel quel, sauf certains caractères conflictuels devant être
#protégés pour obtenir leur valeur littérale :
#		*?[](){}|\
#ce sont les caractères qui, non protégés, sont utilisés comme jokers,
#protection, ou au sein des extglob.
#	Les autres caractères pouvant pertuber bash une fois le motif passé à la
#moulinette d'eval sont protégés par le script avant utilisation :
#	espace, tab, point-virgule, esperluette, apostrophe, guillemet, chevronS.

pushd . >/dev/null
cd /tmp/test


IFS=$'\x1D'
shopt -s nullglob extglob


readonly motifs=(
	'abcde'
	'a?cde'
	'a*de'
	'a[bB]cde'
	'a [bB] [cC] d*e'
	' a b c d e '
	'?a b c d e '
	'*a b c d e*' '{a,A,1}bcde'
	"~/Minecraft/archives \(mods & MCP\)/1*"
	'/home/self/notes SQL'
	"/home/self/notes @(s|S)*"
	'/home/self/notes *'
	"l'allali !"
	'a;b;c??;e;'
	'a;b;c;d;e;f;'
	'* \[crochets\]'
	'* \\\[*crochets\\\]'
	'*\[*\]'
	'*
*
*'
	'*
*'
	'/usr/src/patches – anciens fglrx/'
	'/usr/src/patches/*'
)



#liste des caratères à protéger au sein de $nom – retLn est traité à part
readonly proteger=" 	&;<>\"'"
#et génération du prog SED correspondant
optsSED=
for ((i=0; i < ${#proteger}; i++ ))
do
	c=${proteger:$i:1}
	optsSED+="s/$c/\\\\$c/g;"
done

for (( i=0;  i < ${#motifs[@]};  i++ ))
do
	m="${motifs[$i]}"
	echo "●$m●"

	m=$( sed "$optsSED" <<< "$m" )
	m=${m//$'\n'/\'$'\n'\'}
	echo "SED→•$m•"

	eval "listeNoms=( $m )"
	(( $? == 0 )) || continue

	nb=${#listeNoms[@]}

	#un seul développement, fichier inexistant : pas un motif
	#aucun développement : motif sans correspondance
	{ (( nb == 1 )) && [ ! -e "$listeNoms" ];} \
	|| (( nb == 0 )) \
	&& {
		echo '• PAS DE FICHIER'
		echo
		continue
	}

	echo "	enlistage : $nb entrées"
	for ((j = 0; j < nb; j++ ))
	do
		echo "		•${listeNoms[$j]}•"
	done

	echo
done

popd > /dev/null
