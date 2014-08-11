use strict;
use warnings;
use Perl::Lint::Policy::ValuesAndExpressions::RequireInterpolationOfMetachars;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ValuesAndExpressions::RequireInterpolationOfMetachars';

filters {
    params => [qw/eval/], # TODO wrong!
};

for my $block (blocks) {
    my $violations = fetch_violations($class_name, $block->input, $block->params);
    is scalar @$violations, $block->failures, $block->dscr;
}

done_testing;

__DATA__

===
--- dscr: Basic passing.
--- failures: 0
--- params:
--- input
print "this is not $literal";
print qq{this is not $literal};
print "this is not literal\n";
print qq{this is not literal\n};

===
--- dscr: Basic failure.
--- failures: 5
--- params:
--- input
print 'this is not $literal';
print q{this is not $literal};
print 'this is not literal\n';
print q{this is not literal\n};
print 'this is not @literal';

===
--- dscr: Failure of simple scalar variables.
--- failures: 1
--- params:
--- input
print '$blah';

===
--- dscr: Failure of simple array variables.
--- failures: 1
--- params:
--- input
print '@blah';

===
--- dscr: Failure of common punctuation variables.
--- failures: 4
--- params:
--- input
print '$_';
print '@_';
print '$@';
print '$!';

===
--- dscr: Failure of @+ & @-.
--- failures: 2
--- params:
--- input
print '@+';
print '@-';

===
--- dscr: Failure of @^H.
--- failures: 1
--- params:
--- input
print '@^H';

===
--- dscr: Readonly constant from Modules::ProhibitAutomaticExportation.
--- failures: 1
--- params:
--- input
Readonly::Scalar my $EXPL => q{Use '@EXPORT_OK' or '%EXPORT_TAGS' instead};

===
--- dscr: OK to escape backslashes.
--- failures: 0
--- params:
--- input
print 'it is ok to escape a backslash: \\t'
print q{it is ok to escape a backslash: \\t}
print 'you can do it multiple times: \\\\\\t'
print q{you can do it multiple times: \\\\\\t}

===
--- dscr: OK to escape quotes.
--- failures: 0
--- params:
--- input
print 'you can also escape a quote: \''
print q{you can also escape a quote: \'}
print 'you can escape a quote preceded by backslashes: \\\\\''
print q{you can escape a quote preceded by backslashes: \\\\\'}

===
--- dscr: Valid escapes should not hide invalid ones.
--- failures: 4
--- params:
--- input
print 'it is ok to escape a backslash: \\t but not a tee: \t'
print q{it is ok to escape a backslash: \\t but not a tee: \t}
print 'you can also escape a quote: \' but not a tee: \t'
print q{you can also escape a quote: \' but not a tee: \t}

===
--- dscr: Sigil characters not looking like sigils.
--- failures: 0
--- params:
--- input
$sigil_at_end_of_word = 'list@ scalar$';
$sigil_at_end_of_word = 'scalar$ list@';
$sigil_at_end_of_word = q(list@ scalar$);
$sigil_at_end_of_word = q(scalar$ list@);
%options = (  'foo=s@' => \@foo);  #Like with Getopt::Long
%options = ( q{foo=s@} => \@foo);  #Like with Getopt::Long
$sigil_as_delimiter = q$blah$;
$sigil_as_delimiter = q    $blah$;
$sigil_as_delimiter = q@blah@;
$sigil_as_delimiter = q    @blah@;

===
--- dscr: Do complain about RCS variables, if not turned on.
--- failures: 7
--- params:
--- input
$VERSION = q<$Revision$>;
($VERSION) = q<$Revision$> =~ m/(\d+)/mx;
our $VERSION = substr(q/$Revision$/, 10);
our ($VERSION) = q<$Revision$> =~ m/(\d+)/mx;
our ($VERSION) = (q<$Revision$> =~ m/(\d+)/mx);
our (undef, $AUTHOR, undef, undef, $VERSION) = split m/\s+/, q<$Author$ $Revision$>;

# Yes, silly example, but still need to check it.
if ( ($VERSION) = q<$Revision$> =~ m/(\d+)/mx ) {}

===
--- dscr: Don't complain about RCS variables, if turned on.
--- failures: 0
--- params: {require_interpolation_of_matchers => {rcs_keywords => 'Revision Author'}}
--- input
$VERSION = q<$Revision$>;
($VERSION) = q<$Revision$> =~ m/(\d+)/mx;
our $VERSION = substr(q/$Revision$/, 10);
our ($VERSION) = q<$Revision$> =~ m/(\d+)/mx;
our ($VERSION) = (q<$Revision$> =~ m/(\d+)/mx);
our (undef, $AUTHOR, undef, undef, $VERSION) = split m/\s+/, q<$Author$ $Revision$>;

# Yes, silly example, but still need to check it.
if ( ($VERSION) = q<$Revision$> =~ m/(\d+)/mx ) {}

===
--- dscr: Don't complain about '${}' and '@{}' because they're invalid syntax. See RT #38528/commit r3077 for original problem/solution.
--- failures: 0
--- params:
--- input
use Blah '${}' => \&scalar_deref;
use Blah '@{}' => \&array_deref;
use Blah '%{}' => \&hash_deref;
use Blah '&{}' => \&code_deref;
use Blah '*{}' => \&glob_deref;
use Blah ('${}' => \&scalar_deref);
use Blah ('@{}' => \&array_deref);
use Blah ('%{}' => \&hash_deref);
use Blah ('&{}' => \&code_deref);
use Blah ('*{}' => \&glob_deref);
use Blah 1.0 ('${}' => \&scalar_deref);
use Blah 1.0 ('@{}' => \&array_deref);

===
--- dscr: use vars arguments.
--- failures: 0
--- params:
--- input
use vars '$FOO';
use vars '$FOO', '@BAR';
use vars ('$FOO');
use vars ('$FOO', '@BAR');
use vars (('$FOO'));
use vars (('$FOO', '@BAR'));
use vars ((('$FOO')));
use vars ((('$FOO', '@BAR')));
use vars qw< $FOO @BAR >;
use vars qw< $FOO @BAR >, '$BAZ';

===
--- dscr: Include statement failure.
--- failures: 1
--- params:
--- input
use Generic::Module '$FOO';

===
--- dscr: Things that look like email addresses.
--- failures: 0
--- params:
--- input
$simple  = 'me@foo.bar';
$complex = q{don-quixote@man-from.lamancha.org};

===
--- dscr: More things that look like email addresses.
--- failures: 0
--- params:
--- input
$simple  = 'Email: me@foo.bar';
$complex = q{"don-quixote@man-from.lamancha.org" is my address};
send_email_to ('foo@bar.com', ...);

# TODO Policy is not smart enough to handle this yet.
# TODO Impl
# ===
# --- dscr: Email addresses with embedded violations.
# --- failures: 2
# --- params:
# --- input
# $simple  = 'Email: $name@$company.$domain';
# send_email_to('$some_var: foo@bar.com', ...);

===
--- dscr: Confirm we flag all defined backslashed interpolations. RT #61970
--- failures: 26
--- params:
--- input
'\t';          # tab             (HT, TAB)
'\n';          # newline         (NL)
'\r';          # return          (CR)
'\f';          # form feed       (FF)
'\b';          # backspace       (BS)
'\a';          # alarm (bell)    (BEL)
'\e';          # escape          (ESC)
'\033';        # octal char      (example: ESC)
'\x1b';        # hex char        (example: ESC)
'\x{263a}';    # wide hex char   (example: SMILEY)
'\c[';         # control char    (example: ESC)
'\N{name}';    # named Unicode character
'\N{U+263D}';  # Unicode character (example: FIRST QUARTER MOON)
'\l';          # lowercase next char
'\u';          # uppercase next char
'\L';          # lowercase till \E
'\U';          # uppercase till \E
'\E';          # end case modification
'\Q';          # quote non-word characters till \E
'\1';          # See note 1, below
'\2';          # See note 1, below
'\3';          # See note 1, below
'\4';          # See note 1, below
'\5';          # See note 1, below
'\6';          # See note 1, below
'\7';          # See note 1, below

Note 1: These are not documented in perop that I can find, but the code in
        toke.c makes them equivalent to \0 for interpolated strings (though
        not, of course, for regular expressions or the substitution portion
        of s///).

===
--- dscr: Confirm we ignore all non-special backslashed word characters. RT #61970
--- failures: 0
--- params:
--- input
'\8';
'\9';
'\A';
'\B';
'\C';
'\D';
'\F';
'\G';
'\H';
'\I';
'\J';
'\K';
'\M';
'\O';
'\P';
'\R';
'\S';
'\T';
'\V';
'\W';
'\X';
'\Y';
'\Z';
'\d';
'\g';
'\h';
'\i';
'\j';
'\k';
'\m';
'\o';
'\p';
'\q';
'\s';
'\v';
'\w';
'\y';
'\z';

