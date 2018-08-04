<?php

DEFINE('MAX_SESSION_LIFESPAN', 10 * 60);
DEFINE('MAX_INACTIVITY_DELAY', 5 * 60);

#needed fields in $_SESSION:
#	 lastActivity	→ for inactivity delay's logout
#	 birthTime	→ for periodic renewal against cookie hijacking


//start session, deny access to unlogged users,
// and prevent some kinds of cookies hijacking...
function validateSession(bool $AcceptUnloggedUser = false) {
    session_start();

    if (! $AcceptUnloggedUser) {
        if (
              //REDIRECT TO THE RIGHT PAGE IF NOT LOGGED IN!
              empty( $_SESSION['user'] )
              //ask to login anew if inactivity delay is over
              || ( time() - $_SESSION['lastActivity'] > MAX_INACTIVITY_DELAY )
        ) {
            session_unset();
            session_destroy();

            header('Location: /login.php');
            exit;
        }
    } else {
        #this part is only for the case where AcceptUnloggedUser is true ...
        if ( empty( $_SESSION['birthTime'] ) )
            $_SESSION['birthTime'] = time();
    }

    //update timestamp of last "activity" (in fact, page load)
    $_SESSION['lastActivity'] = time();

    //regenerate session ID to mitigate session fixation attacks
    if (time() - $_SESSION['birthTime'] >  MAX_SESSION_LIFESPAN) {
        session_regenerate_id(true);
        $_SESSION['birthTime'] = $_SESSION['lastActivity'];
    }
}
