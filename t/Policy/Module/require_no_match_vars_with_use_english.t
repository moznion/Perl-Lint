use strict;
use warnings;
use Perl::Lint::Policy::Modules::RequireNoMatchVarsWithUseEnglish;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Modules::RequireNoMatchVarsWithUseEnglish';

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
--- dscr: Passing with no "use English".
--- failures: 0
--- params:
--- input
use strict;
use warnings;

my $doodle_doodle_dee = 'wubba wubba wubba';

===
--- dscr: Passing single quotes.
--- failures: 0
--- params:
--- input
use English '-no_match_vars';

===
--- dscr: Passing double quotes
--- failures: 0
--- params:
--- input
use English "-no_match_vars";

===
--- dscr: Passing literal quotes.
--- failures: 0
--- params:
--- input
use English q/-no_match_vars/;
use English q{-no_match_vars};
use English q(-no_match_vars);
use English q[-no_match_vars];
use English q<-no_match_vars>;
use English q!-no_match_vars!;
use English q#-no_match_vars#;
use English q'-no_match_vars';
use English q"-no_match_vars";

===
--- dscr: Passing literal quotes with whitespace before delimiter.
--- failures: 0
--- params:
--- input
use English q              /-no_match_vars/;
use English q              {-no_match_vars};
use English q              (-no_match_vars);
use English q              [-no_match_vars];
use English q              <-no_match_vars>;
use English q              !-no_match_vars!;
use English q              '-no_match_vars';
use English q              "-no_match_vars";

===
--- dscr: Passing interpolating quotes.
--- failures: 0
--- params:
--- input
use English qq/-no_match_vars/;
use English qq{-no_match_vars};
use English qq(-no_match_vars);
use English qq[-no_match_vars];
use English qq<-no_match_vars>;
use English qq!-no_match_vars!;
use English qq#-no_match_vars#;
use English qq'-no_match_vars';
use English qq"-no_match_vars";

===
--- dscr: Passing interpolating quotes with whitespace before delimiter.
--- failures: 0
--- params:
--- input
use English qq             /-no_match_vars/;
use English qq             {-no_match_vars};
use English qq             (-no_match_vars);
use English qq             [-no_match_vars];
use English qq             <-no_match_vars>;
use English qq             !-no_match_vars!;
use English qq             '-no_match_vars';
use English qq             "-no_match_vars";

===
--- dscr: Passing quotelike words.
--- failures: 0
--- params:
--- input
use English qw/  -no_match_vars  /;
use English qw{  -no_match_vars  };
use English qw(  -no_match_vars  );
use English qw[  -no_match_vars  ];
use English qw<  -no_match_vars  >;
use English qw!  -no_match_vars  !;
use English qw#  -no_match_vars  #;
use English qw'  -no_match_vars  ';
use English qw"  -no_match_vars  ";

===
--- dscr: Passing quotelike words with whitespace before delimiter.
--- failures: 0
--- params:
--- input
use English qw            /  -no_match_vars  /;
use English qw            {  -no_match_vars  };
use English qw            (  -no_match_vars  );
use English qw            [  -no_match_vars  ];
use English qw            <  -no_match_vars  >;
use English qw            !  -no_match_vars  !;
use English qw            '  -no_match_vars  ';
use English qw            "  -no_match_vars  ";

===
--- dscr: Passing quotelike words with things in addition to -no_match_vars.
--- failures: 0
--- params:
--- input
use English qw/ $ERRNO -no_match_vars $EVAL_ERROR /;

===
--- dscr: Passing parenthesized list.
--- failures: 0
--- params:
--- input
use English ( '-no_match_vars' );

===
--- dscr: Passing parenthesized list with things in addition to -no_match_vars.
--- failures: 0
--- params:
--- input
use English ( '$ERRNO', "-no_match_vars", "$EVAL_ERROR" );

===
--- dscr: Passing unparenthesized list with things in addition to -no_match_vars.
--- failures: 0
--- params:
--- input
use English '$ERRNO', "-no_match_vars", "$EVAL_ERROR";

===
--- dscr: Passing version.
--- failures: 0
--- params:
--- input
use English 1.02 '-no_match_vars';

===
--- dscr: Passing v-string version.
--- failures: 0
--- params:
--- input
use English v1.02 '-no_match_vars';

===
--- dscr: Passing parenthesized list and version.
--- failures: 0
--- params:
--- input
use English 1.02 ('-no_match_vars');

===
--- dscr: Basic failure.
--- failures: 1
--- params:
--- input
use English;

===
--- dscr: Failure with version.
--- failures: 1
--- params:
--- input
use English 1.02;

===
--- dscr: Failure with v-string.
--- failures: 1
--- params:
--- input
use English v1.02;

===
--- dscr: Failure with random garbage.
--- failures: 2
--- params:
--- input
use English 'oink oink';
use English qw< blah blah blah >;

===
--- dscr: Failure with typo that Ovid noticed.
--- failures: 1
--- params:
--- input
use English qw(-no_mactch_vars);

