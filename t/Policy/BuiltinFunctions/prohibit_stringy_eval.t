use strict;
use warnings;
use Perl::Lint::Policy::BuiltinFunctions::ProhibitStringyEval;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'BuiltinFunctions::ProhibitStringyEval';

filters {
    params => [qw/eval/],
};

for my $block (blocks) {
    my $violations = fetch_violations($class_name, $block->input, $block->params);
    is scalar @$violations, $block->failures, $block->dscr;
}

done_testing;

__DATA__

===
--- dscr: Basic passing
--- failures: 0
--- params:
--- input
eval { some_code() };
eval( {some_code() } );
eval();
{eval}; # for Devel::Cover

===
--- dscr: Basic failure
--- failures: 5
--- params:
--- input
eval "$some_code";
eval( "$some_code" );
eval( 'sub {'.$some_code.'}' );
eval q{$some_code};
eval qq{$some_code};

===
--- dscr: Things that might look like an eval, but aren't
--- failures: 0
--- params:
--- input
$hash1{eval} = 1;
%hash2 = (eval => 1);

===
--- dscr: Eval of include statement without allow_includes set
--- failures: 20
--- params:
--- input
eval 'use Foo';
eval 'require Foo';
eval 'use Foo 1.2';
eval 'require Foo 1.2';
eval 'use Foo qw< blah >';
eval 'require Foo qw< blah >';
eval 'use Foo 1.2 qw< blah >';
eval 'require Foo 1.2 qw< blah >';

eval 'use Foo; 1;';
eval 'require Foo; 1;';
eval 'use Foo 1.2; 1;';
eval 'require Foo 1.2; 1;';
eval 'use Foo qw< blah >; 1;';
eval 'require Foo qw< blah >; 1;';
eval 'use Foo 1.2 qw< blah >; 1;';
eval 'require Foo 1.2 qw< blah >; 1;';

eval "use $thingy;";
eval "require $thingy;";
eval "use $thingy; 1;";
eval "require $thingy; 1;";

===
--- dscr: Eval of include statement without allow_includes set q/ quote string
--- failures: 20
--- params:
--- input
eval q{use Foo};
eval q{require Foo};
eval q{use Foo 1.2};
eval q{require Foo 1.2};
eval q{use Foo qw< blah >};
eval q{require Foo qw< blah >};
eval q{use Foo 1.2 qw< blah >};
eval q{require Foo 1.2 qw< blah >};

eval q{use Foo; 1;};
eval q{require Foo; 1;};
eval q{use Foo 1.2; 1;};
eval q{require Foo 1.2; 1;};
eval q{use Foo qw< blah >; 1;};
eval q{require Foo qw< blah >; 1;};
eval q{use Foo 1.2 qw< blah >; 1;};
eval q{require Foo 1.2 qw< blah >; 1;};

eval qq{use $thingy;};
eval qq{require $thingy;};
eval qq{use $thingy; 1;};
eval qq{require $thingy; 1;};

===
--- dscr: Eval of include statement with allow_includes set
--- failures: 0
--- params: {prohibit_stringy_eval => {allow_includes => 1}}
--- input
eval 'use Foo';
eval 'require Foo';
eval 'use Foo 1.2';
eval 'require Foo 1.2';
eval 'use Foo qw< blah >';
eval 'require Foo qw< blah >';
eval 'use Foo 1.2 qw< blah >';
eval 'require Foo 1.2 qw< blah >';

eval 'use Foo; 1;';
eval 'require Foo; 1;';
eval 'use Foo 1.2; 1;';
eval 'require Foo 1.2; 1;';
eval 'use Foo qw< blah >; 1;';
eval 'require Foo qw< blah >; 1;';
eval 'use Foo 1.2 qw< blah >; 1;';
eval 'require Foo 1.2 qw< blah >; 1;';

eval "use $thingy;";
eval "require $thingy;";
eval "use $thingy; 1;";
eval "require $thingy; 1;";

===
--- dscr: Eval of include statement with allow_includes set w/ quote string
--- failures: 0
--- params: {prohibit_stringy_eval => {allow_includes => 1}}
--- input
eval q{use Foo};
eval q{require Foo};
eval q{use Foo 1.2};
eval q{require Foo 1.2};
eval q{use Foo qw< blah >};
eval q{require Foo qw< blah >};
eval q{use Foo 1.2 qw< blah >};
eval q{require Foo 1.2 qw< blah >};

eval q{use Foo; 1;};
eval q{require Foo; 1;};
eval q{use Foo 1.2; 1;};
eval q{require Foo 1.2; 1;};
eval q{use Foo qw< blah >; 1;};
eval q{require Foo qw< blah >; 1;};
eval q{use Foo 1.2 qw< blah >; 1;};
eval q{require Foo 1.2 qw< blah >; 1;};

eval qq{use $thingy;};
eval qq{require $thingy;};
eval qq{use $thingy; 1;};
eval qq{require $thingy; 1;};

===
--- dscr: Eval of include statement with allow_includes set but extra stuff afterwards
--- failures: 6
--- params: {prohibit_stringy_eval => {allow_includes => 1}}
--- input
eval 'use Foo; blah;';
eval 'require Foo; 2; 1;';
eval 'use $thingy;';

eval q{use Foo; blah;};
eval q{require Foo; 2; 1;};
eval q{use $thingy;};

===
--- dscr: Eval of "no" include statement with allow_includes set
--- failures: 1
--- params: {prohibit_stringy_eval => {allow_includes => 1}}
--- input
eval 'no Foo';

===
--- dscr: Eval a comment (RT #60179)
--- failures: 1
--- params: {prohibit_stringy_eval => {allow_includes => 1}}
--- input
# Note that absent the desired fix, the following is a fatal error.

eval("#" . substr($^X, 0, 0));

