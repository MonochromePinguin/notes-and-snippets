<?php
namespace monochrome;

/* awaited structure :
[
    [
        'label' => '...',
         'url' => '...',
         ?'nav' => [
             [...],
             [...]
         ]
    ]
]
*/


class listGenerator {

    const SPACING = '    ';

    /**
     * @param $input array
     * @return ?string
     * generate a multilevel menu of links and titles from an array of associative arrays.
     * See file top for the awaited structure.
     */
    //TODO: do NOT use a concatenation each time we return something ...
    public static function generateList(array $input, int $level = 0): string {
        $prefix = str_repeat(static::SPACING, $level);
        $prefix2 = $prefix . static::SPACING;

        //resulting string
        $result = $prefix . "<ul>\n";

        foreach($input as $entry) {
            
            $result .= $prefix2 . "<li>\n";

            if (isset($entry['label'])) {
            
                if (isset($entry['url'])) {
                    // ["label"] and ["url"] are set -> an anchor
                    $result .= $prefix2 . static::SPACING . '<a href="' . htmlspecialchars($entry['url']) . '">' . $entry['label'] . '</a>' . PHP_EOL;
                } else {
                    // ["label"] only is set -> this is a title
                    $result .= $prefix2 . static::SPACING . '<p>' . htmlspecialchars($entry['label']) . '</p>' . PHP_EOL;
                }
                
            } else {
                // unspecified label ...
                $result .= $prefix2 . static::SPACING . '<p>submenu</p>' . PHP_EOL;
            }

            if (isset($entry['nav'])) {
                $result .= static::generateList($entry['nav'], $level + 2);
            }

            $result .= $prefix2 . '</li>' . PHP_EOL;
        }

        return $result . $prefix . '</ul>' . PHP_EOL;
    }

}
