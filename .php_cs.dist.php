<?php

$rules = [
    '@PSR2' => true,
    '@Symfony' => true,
];

$finder = (new PhpCsFixer\Finder())
    ->in([
        __DIR__.'/app',
        __DIR__.'/config',
        __DIR__.'/database',
        __DIR__.'/routes',
        __DIR__.'/tests',
    ]);

$config = new PhpCsFixer\Config();

return $config
    ->setRules($rules)
    ->setFinder($finder);
