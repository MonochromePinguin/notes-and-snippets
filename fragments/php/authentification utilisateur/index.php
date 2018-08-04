<?php
    require_once 'inc/sessionFunctions.php';

    //start session, deny access to unlogged users
    // and prevent some kinds of cookies hijacking ... see the function itself.
    validateSession(true);

************* CODER ICI *************
