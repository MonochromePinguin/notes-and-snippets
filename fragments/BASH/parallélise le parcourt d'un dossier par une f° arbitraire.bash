#!/bin/bash
#Test d'une f° destinée à màj.sauvegardes.sh

readonly cN=$(tput sgr0)
readonly cR=$(tput setaf 1)




paralleliseParcourt()
#Cette fonction permet de répartir le parcourt du dossier $2 entre $4 instances
#parallèles d'une même fonction $1. Cette fonction DOIT être de la famille des
# parcourtXXX() – prenant 2 paramètres, n°1 == dossier ou fichier source,
# n°2 == dossier de destination.
#	Elle fonctionne en lisant le contenu du dossier dans un tableau, découpe
#ce tableau en 𝑛 portions de taille plus-ou-moins égales, puis démarre 𝑛 sous-
#interpréteurs parallèles dont chacun bouclera dans sa section du tableau en
#appelant pour chaque entrée la f° $1.
#● 4 PARAMÈTRES :
#	$1		nom de la fonction à exécuter – ce DOIT être une des parcourtXXX()
#	$2 et $3 paramètres de la f° – dans le cas des f° de la famille
#				parcourtXXX(), $2 == source, $3 == dest°
#	$4		nombre d'instances parallèles de $1
#● 1 VARIABLE ACCÉDÉE :
#	$fonc = nom de la fonction exécutée – la $fonc attribuée à chq
#sous-interpréteur se verra concaténé un n° correspondant à ce dernier
{
	[[ $# = 4 ]] \
	|| {
		echo -e "${cR}BUG – decoupeParcourtDossier() : il faut QUATRE paramètres !\n\tTERMINAISON DU PROCESSUS.$cN" >&2
		exit 1
	}

	local x
	local part reste
	#«declare» ds une f° est local par défaut
	local nbParts=$4

echo "● nb Parts : $nbParts"

	#développe le contenu du dossier $2 (ou le fichier $2) dans liste[]
	[[ -d $2 ]]  &&  local liste=( "${2%/}"/* )  ||  local liste=( "$2" )

	local tListe=${#liste[@]}
echo "● contenu du tbl : ${liste[@]/#''/$'\n\t'}"

	#il ne sert à rien d'avoir plus d'instances que de fichiers à traiter
	(( nbParts > $tListe )) && nbParts=$tListe
echo "● nb Parts corrigé : $nbParts"

	# offset de démarrage de chaque part
	declare -i offset=0

	#calcule la taille de chaque portion de $liste[] et le reste à distribuer
	# le plus également possible entre les 𝑛 sous-shells
	#
	part=$(( tListe / nbParts ))
	reste=$(( tListe % nbParts ))
echo -e "● 1er calcul :\n\tpart=$part\n\treste=$reste"

	#effectue la découpe
	#
	for (( x=0;  x < nbParts;  x++ ))
	do
		ofsDeb=$offset
		# 3e terme de la somme :
		#	si $reste > 0, renvoit 1 ET décrémente $reste – sinon renvoit 0
		offset+=$(( part  +  ( reste > 0 ? ( reste--, 1) : 0 ) ))

		#le parcourt de chaque portion a lieu dans un sous-shell //e
		#
		(
			fonc="$fonc – partie $(( x+1 ))"
echo "● l'instance n°$x s'occupe des indices $ofsDeb à $((offset-1))"

			for (( x = $ofsDeb;  x < $offset;  x++ ))
			do
				#$source et $destination pourront être altérés avant d'être
				# passés en param' à la f° $1
				src=${liste[$x]}
				dest=$3

				#Du fait du comportement des f° parcourtXXX(), qui copient $src
				# dans $dest, il faut s'assurer de passer le bon paramètre $dest
				# quand ${liste[$x]} est un dossier, donc éventuellement
				# adapter le nom à FAT
				[[ -d $src ]] \
				&& {
					[[ ${src: -1} = '/' ]] || src+='/'

					n=$( basename -- "$src" )
					[[ -n $FAT ]] && traduitNomVersFAT n
					dest+=$n/
				}

echo "•$fonc : appel de «$1» s/ l'indice $x :"
				#f°()	source		destination		paramètre servant de test
				$1 "$src"  "$dest"				$x
			done
		) &
	done
}


afficheNom()
{
	echo -e "	$fonc :\n		«$1»\n		vers «$2» (indice $3)"
}


fonc='f°'

#paralleliseParcourt 'afficheNom' '/tmp/le test/' '/tmp/' 8
#paralleliseParcourt 'afficheNom' '/tmp/le test' '/tmp/' 8
#paralleliseParcourt 'afficheNom' '/tmp/le test/fichier de test' '/tmp/' 8
#paralleliseParcourt 'afficheNom' '/tmp/le test/' '/tmp/' 3
paralleliseParcourt 'afficheNom' '/home/self/' '/tmp/' 4


