wi#!/bin/bash
# définition d'une fonction affichant soit une Boîte d'information, soit une
# ligne de texte colorée en fonction de $XAUTHORITY et de la présence de zenity.

#
# Le titre comme le corps du texte peuvent contenir des marqueurs de début
# & de fin des zones à mettre en avant : €[ et €]. Ces deux combinaisons seront
# remplacées par les codes appropriés au mode d'affichage.
#● 2 PARAMÈTRES :
#	$1	=	titre de la fenêtre
#	$2	=	texte de la question

# "normal", "rouge"
readonly cN=$(tput sgr0)
readonly cR=$(tput setaf 1)

#gras et non-gras
readonly cG=$(tput smso)
readonly cNG=$(tput rmso)

if [[ -n $XAUTHORITY ]] && which zenity > /dev/null 2>&1
then
    erreur()
    {
        local titre texte

        titre=${1//€?}

        texte=${2//'€['/'<span weight="bold">'}
        texte=${texte//'€]'/'</span>'}

        WINDOWID=''  zenity --error \
            --title "${titre//&/&amp;}" --text "${texte//&/&amp;}" 2> /dev/null
        exit 1
    }
else
    erreur()
    {
        titre=${1//'€['/$cG}
        titre=${titre//'€]'/$cNG}

        texte=${2//'€['/$cR}
        texte=${texte//'€]'/$cN}

        echo "$titre : $cN$texte$cN"
        exit 1
    }
fi


erreur 'normal €[en gras€] normal' 'bla bla bla €[blaaaa !€] bla.'

