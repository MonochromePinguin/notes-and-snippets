● le PHP :

function formatError($mssg = 'Erreur non spécifiée.') : string
{
    return "<aside class='error'>\n<h1>Désolé&nbsp!</h1>\n<p>
        Une erreur est survenue.<br>
        Veuillez contacter l'opérateur du site.<br>"
        . ( null != $mssg ?
                "Message d'erreur&nbsp:<br>\n<span class='norm'>"
                . htmlspecialchars(addslashes($mssg)) . '</span>'
              :
                ''
        )
        . "\n</p>\n</aside>\n";
}


● une possibilité de CSS :

.error {
    color: red;
    font-style : italic;
}

.norm {
    color: darkred;
    font-style: normal;
}