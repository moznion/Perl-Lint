use strict;
local $foo = $bar if $baz;
local ($foo) = $bar if $baz;
local $foo = $bar unless $baz;
local ($foo) = $bar unless $baz;
local $foo = $bar until $baz;
local ($foo) = $bar until $baz;
local ($foo, $bar) = 1 foreach @baz;
local ($foo, $bar) = 1 for @baz;

