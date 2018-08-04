<?php
    session_start();

    //official logout
    if ( isset( $_GET['logout'] ) ) {
        session_unset();
        session_destroy();
    }

    #WORK CRITERIA : once connected, we shoul'nt be able to connect
    # to login page ...
    if ( isset( $_SESSION['user'] ) ) {
      header('Location: /');
      exit;
    }


    if ( isset( $_POST['loginName'] ) ) {
        $_SESSION['user'] = $_POST['loginName'];

        //session is time-limited to 𝑛 seconds, see inc/sessionfunctions.php
        $_SESSION['birthTime'] =
        $_SESSION['lastActivity'] = time();

        header('Location: /index.php');
        exit;
    }

******************************************************
