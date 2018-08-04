<?php

namespace monochrome;


/**
 * Class Autoload
 * Permet de déclarer une fonction d'autochargement de fichiers PHP
 */

class Autoload
{
    /**
    * @param string $rép nom du sous-dossier où chercher les fichiers de classe à charger. slash final facultatif.
    */
    static private $dir;

    static function on( string $rép = 'class' )
    {

        // echo 'paramètre de ::on : ' . $rép . '<br>';

        # permet de spécifier un paramètre avec ou sans slash terminal
        self::$dir = rtrim( $rép, '/' ) . '/';
        
        //echo 'valeur assignée à $rép : ' . self::$dir . '<br><br>';
        
        #spl_autoload_register() peut prendre une méthode en paramètre :
        # il faut alors la fournir sous forme de tableau [ classe, fonct° ]
        if ( ! spl_autoload_register( [ __CLASS__, 'autoload' ] ) )
            throw new Exception( 'Erreur d\'entregistrement de la fonction d\'autochargement', 1);
    }


    /**
    * fonction utilisée en paramètre de spl_autoload_register
    * @param string $classe nom de la classe à charger (sous forme de fichier séparé)
    */

    static  private function autoload( string $classe )
    {
        // echo 'paramètre de autoload : ' . $classe . '<br>';
        /// echo 'Fichier requis : ' . self::$dir . $classe . '.php' . '<br><br>';

        #charge le fichier dans un sous-dossier de $rép
        require( self::$dir . str_replace('\\', '/', $classe ) . '.php' );
    }

}

