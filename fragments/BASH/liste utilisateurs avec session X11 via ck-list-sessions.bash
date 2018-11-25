#!/bin/bash
#La dernière commande d'un tuyau EXÉCUTÉ EN AVANT-PLAN ne sera pas exécutée
# dans un processus-fils
shopt -s lastpipe


#Si ≠ 0, indique qu'il y a des notifications à envoyer, et combien
nbNotif=0
#Stocke les env.var nécessaires à l'envoi des notifications
# ($DISPLAY et $DBUS_SESSION_BUS_ADDRESS)
declare -a listeEnvVar
# stocke les utilisateurs correspondants
declare -a listeUID


function trouveUsers()
#détermine les utilisateurs concernés.
#le code initial boguait dès qu'il y avait plus d'un utilisateur ≠ root connecté,
# et n'acceptait de toutes manières qu'un seul utilisateur !
#● EN SORTIE : $nbNotif, $listeEnvVar et $listeUID sont initialisés.
{
	#Liste des utilisateurs ayant une session X11
	# (on leur enverra tous les notifications), et leurs n° de display
	declare -a listeUser listeDisplay # tableaux == variables locales par défaut

	local u d i
	i=0

	command -v ck-list-sessions &> /dev/null || return
	#pas de notifications à envoyer si l'outil nécessaire n'est pas accessible ...
	command -v notify-send &> /dev/null || return

	#ceci produit une liste de paires utilisateur/display (1 ln pour chaque, un espace au milieu),
	# séparées par un saut-de-ligne :
	# Ma version précédente était légèrement plus lente, et reste notée ds la note «SED contre BASH» ...
	ck-list-sessions | sed -rn "/^Session[0123456789]+/ { s/.*//; x; /[0-9]+ :[0-9]+(\\.[0-9]+){0,1}/ p; n }; /unix-user/ { s/.*= '([0-9]+)'/\\1/; G; s/[\\n 	]+/ /g; h; b }; /x11-display / { s/.*= '(:[0-9]+(.[0-9]+){0,1})'/\\1/; t X11ok; s/.*//; h; b; :X11ok; H; g; s/[\\n 	]+/ /g; h; b }; /is-local = FALSE/ { s/.*//; h; b }; \$ { x; /[0-9]+ :[0-9]+(.[0-9]+){0,1}/ p }"\
	| while read u d
	do
		listeUser[i]=$u
		listeDisplay[i]=$d
		((i++))
	done

	#si la liste est vide ...
	[ $i == '0' ] && return

	local pidX ppid n
	local _pid _user _envVar _display

	# • ceci liste ttes les instances d'Xorg, et trouve dans un des
	# processus de même parent (le gestionnaire de connection démarre X11
	# ET la session de bureau) les env.var DBUS_SESSION_BUS_ADDRESS et DISPLAY ;
	# • puis on compare chq paire utilisateur + display (stockés ds listeUser/listeDisplay)
	# avec les paires UID programme + env.var. DISPLAY programme trouvées ;
	# • qd çà correspond, on stocke dans un dernier tableau la paire d' env.var. trouvée
	# pour la réutiliser lors de l'envoi des notifications.
	pidof X | while read pidX
	#ATTENTION : le binaire s'appelle «Xorg», mais le programme se renomme «X» !
	do
		ppid=$( cat /proc/$pidX/stat  2> /dev/null | cut -d ' ' -f4 )
		[ -z "$ppid" ] && return

		#retourne une paire PID/UID à chaque itération
		ps -opid,uid --ppid "$ppid" | tail -n +2 | while read _pid _user
		do
			#on cherche la correspondance avec chacune des paires ds les tbl listeUser/listeDisplay
			for (( n=0; n < i; n++ ))
			do
				#pas le bon UID !
				[ "${listeUser[$n]}" != "$_user" ] && continue
				#extraire de l'environnement du processus les env.var d'intérêt
				_envVar="$( egrep -z 'DBUS_SESSION_BUS_ADDRESS|DISPLAY' /proc/$_pid/environ | tr '\000' ' ' )"
				#s'assure que l'env.var DBUSxxxx est présente
				egrep -q 'DBUS_SESSION_BUS_ADDRESS=[^ ]+' <<< $_envVar || continue

				#obtenir le $DISPLAY et vérifier qu'il correspond à ${listeDisplay[$n]}
				_display=$( sed -rn 's/.*DISPLAY=([:.0123456789]+).*/\1/p' <<< $_envVar )
				[ "${listeDisplay[$n]}" != "$_display" ] && continue


				#PID et $DISPLAY correspondent : on stocke _envVar dans le tableau listeEnvVar
				#après ajout du n° d'écran au n° de display dans l'env.var
				listeEnvVar[nbNotif]=$( sed -r 's/(DISPLAY=:[0123456789]+) /\1.0 /' <<< $_envVar )
				# ... ainsi que l'utilisateur correspondant
				listeUID[nbNotif]=$( id -un $_user )
				((nbNotif++))
			done
		done
	done

	#s'il n'y a pas de notif' à faire afficher, se débarrasse des vars inutiles
	[ $nbNotif -gt 0 ] || {
		unset nbNotif listeEnvVar listeUID
	}
}

