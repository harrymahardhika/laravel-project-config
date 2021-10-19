<?php

$rules = [
    '@PSR2' => true,
    '@Symfony' => true,
    'php_unit_method_casing' => ['case' => 'snake_case'],
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
