<?php

/**
 * Returns a whole page to show something in case of critical error
 * @param string $title title of the warning page
 * @param array $messages array of string to add into the body of the warning page
 * @return string the raw, HTML-formated page to show
 */
function generateEmergencyPage(string $title, array $messages) : string
{
    $ret = <<< EOP
<!DOCTYPE html>
<html lang="fr">
  <head>
	<title>Festizik – Quelque chose de pas normal s'est passé</title>
	<meta charset="UTF-8">

	<meta name="viewport" content="width=device-width, initial-scale=1">

    <!--to deactivate the old "compatibility with that old IE" mode of edge -->
	<meta http-equiv="X-UA-Compatible" content="IE=edge">

	<style>
	    main { text-align: center }
	    .error {
	        color: red;
	        font-style: italic bold;
	        border: 1px solid darkred;
	        border-radius: 1rem;
	        margin: 5vw;
	        padding: 1rem;
	     }
    </style>
  </head>

  <body>
    <header>
        <h1>{$title}</h1>
        <h2>Les messages d'erreur suivants ont été renvoyés&nbsp;:</h2>
    </header>

    <main>
EOP;

    foreach ($messages as $msg) {
        $ret .= '<p class="error">' . $msg . "</p>\n" ;
    }

    $ret .= <<< EOP
    </main>

  </body>
</html>
EOP;

    return $ret;
}
