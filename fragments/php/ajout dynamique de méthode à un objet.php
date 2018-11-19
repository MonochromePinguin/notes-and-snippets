<?php

class Test {
    public $name;

    public function __construct(string $n) {
        $this->name = $n;   
    }
}

$t = new Test('zerty');


$t->f = function(){
    echo 'blaaaa' . PHP_EOL;
};


echo $t->name . PHP_EOL;
call_user_func($t->f);
