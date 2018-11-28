#!/bin/bash
## Récupère la sortie d'erreur d'une commande tout en affichant sa sortie standard
# le tout via des redirections

readonly cR=$(tput setaf 1)
readonly cN=$(tput sgr0)


## fonction arbitraire de test, remplace la f° à exécuter
#
fonctionTest() {
	echo 'sortie standard de la f°'
	echo "sortie d'erreur de la f°" >&2
	return 5
}


## variables utilisées
#
stdErr=
retVal=


## code d'intérêt :
#_ stderr de «fonctionTest» est redirigé vers l'ancien stdout,
#  et stdout vers le DF n°3
#_ une substitution de commande stocke dans $stdErr la sortie d'erreur
#  récupérée via stdOut
#_ le DF n°3 de la liste de commandes est redirigé vers stdin
#_ enfin, le DF n°3 est fermé
#
{ stdErr=$( fonctionTest 2>&1 1>&3 ); } 3>&1
#récupére le code de sortie de la liste de commandes
retVal=$?
# ferme le DF n°3
3>&-



echo "● sortie d'erreur : «$stdErr»"
echo "● valeur de retour : «$retVal»"



echo
echo '---- variante avec «exec» : '



## variante utilisant «exec» pour rediriger les DF :
#
exec 3>&1
stdErr=$( fonctionTest 2>&1 1>&3 )
exec 1>&3
3>&-

echo "● sortie d'erreur : «$stdErr»"
echo "● valeur de retour : «$retVal»"

