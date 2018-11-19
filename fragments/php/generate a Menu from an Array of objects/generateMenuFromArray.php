<?php
namespace monochrome;
?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Document</title>
</head>
<body>

<?php

include_once 'listGenerator.php';

$ourMenu = [
    [
        'label' => 'google',
        'url' => 'http://google.jp/'
    ],
    [
        'label' => 'bing',
        'url' => 'http://bing.ru'
    ],
    [
        'label' => 'blog',
        'nav' => [
            [
                'label' => 'yopmail',
                'url' => 'http://yopmail.net',
            ],
            [
                'label' => 'entrée deux, sans lien',
                ],
            [
                'label' => 'wikipédia',
                'url' => 'http://wikipedia.fr/',
            ],
        ]
    ], //entry
];

echo listGenerator::generateList( $ourMenu );

?>
    
    </body>
</html>

