#!/bin/sh
## Récupère les code de retour, sortie standard et sortie d'erreur
# d'une commande via une fifo et des redirections.
#
# avec BASH 4.4, on ne peut pas capturer à la fois stdOut et stdErr sans passer
# par un fichier temporaire ou une fifo.
#
# le code de retour est obtenu classiquement via $?,
# et la sortie d'erreur via une fifo.
# cette fifo est liée à un DF 𝑛 via « exec 𝑛<> $nomFifo »
# «trap» et quelques test sont utilisés pour supprimer la fifo de manière sûre.


readonly cR=$(tput setaf 1)
readonly cN=$(tput sgr0)


# fonction arbitraire de test, remplace la f° à exécuter
#
testFunction() {
	echo 'sortie standard de la f°'
	echo "sortie d'erreur de la f°" >&2
	return 5
}


#variables utilisées
#
stdOut=
stdErr=
retVal=


#créer la fifo utilisée pour stocker la sortie d'erreur
#
## suppression de la fifo en toutes circonstances à l'arrêt du shell :
#		trap "[[ -n $fifo -a -f $fifo ]] && rm -- '$fifo'" EXIT
## attache la fifo au DF n°3 :	exec 3<> "$fifo"
# la rend anonyme :				unlink -- "$fifo"
{
	fifo=/tmp/$(mktemp --dry-run testXXXXX.fifo) \
	&& trap "[[ -n $fifo -a -f $fifo ]] && rm -- '$fifo'" EXIT \
	&& mkfifo -- "$fifo" \
	&& exec 3<> "$fifo" \
	&& unlink -- "$fifo"
} || {
	echo "${cR}ne peut créer la fifo.$cN"
	exit 1
}


#################
## code d'intérêt - bloquant si + de 64Ko d'erreur !
#################
stdOut=$( testFunction 2>&3 )
retVal=$?
IFS=   read stdErr <&3

echo "●sortie standard : «$stdOut»"
echo "●sortie d'erreur : «$stdErr»"
echo "●valeur de retour : «$retVal»"
