use strict;
use warnings;
use Perl::Lint::Policy::RegularExpressions::ProhibitUselessTopic;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'RegularExpressions::ProhibitUselessTopic';

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
--- dscr: Non-topic explicitness
--- failures: 0
--- params:
--- input
my $foo = 'Whatever';

$foo =~ /foo/;
$foo =~ m/foo/;
$foo =~ s/foo/bar/;
$foo =~ tr/a-mn-z/n-za-m/;

===
--- dscr: Topical exclusion
--- failures: 0
--- params:
--- input
/foo/;
m/foo/;
s/foo/bar/;
tr/a-mn-z/n-za-m/;

===
--- dscr: Useless topic
--- failures: 10
--- params:
--- input
$_ =~ /foo/;
$_ =~ m/foo/;
$_ =~ s/foo/bar/;
$_ =~ tr/a-mn-z/n-za-m/;
$_ =~ y/a-mn-z/n-za-m/;

# Plus some without spacing

$_=~/foo/;
$_=~m/foo/;
$_=~s/foo/bar/;
$_=~tr/a-mn-z/n-za-m/;
$_=~y/a-mn-z/n-za-m/;

===
--- dscr: Useless topic in a negative match
--- failures: 5
--- params:
--- input
$_ !~ /foo/;
$_ !~ m/foo/;
$_ !~ s/foo/bar/;
$_ !~ tr/a-mn-z/n-za-m/;
$_ !~ y/a-mn-z/n-za-m/;

===
--- dscr: Match against qr object
--- failures: 2
--- params:
--- input
$_ =~ qr/bar/;
$_ !~ qr/bar/;

===
--- dscr: Not useless matching against a variable
--- failures: 0
--- params:
--- input
my $non_useless_topic_regex = qr/foo.+bar/;
$_ =~ $non_useless_topic_regex;

===
--- dscr: More complex constructions
--- failures: 8
--- params:
--- input
my $x = scalar( grep { $_ =~ m/^INFO: .*$/ } @foo );
$x = 3 if $_ !~ s/foo/bar/;
$_ =~ s/\s+$// foreach ($name, $zip, $phone);
our @paths = grep { $_ =~ /./ } <DATA>; # get non-blank lines from the end
next if $_ =~ m/^\s*#/;
$condition_count += ($_ =~ tr/,/,/) foreach values %requirements;
my ( $v ) = grep { $_ =~ /^\s*our\s+\$VERSION\s*=\s*['"]\d/ } <$fh>;
assert( ! grep { $_ =~ m/\|/ } @$suggestions, 'no suggestion contains a pipe character (reserved for future field separator)' );

===
--- dscr: Potential false positives, but none should fail.
--- failures: 0
--- params:
--- input
$x =~ /foo/;
$_ += /foo/;
print s/x/y/;
foo(tr/x/y/);
+tr/x/y/;
# $_ =~ /foo/
'foo' =~ $_;
$_ =~ $some_qr_var;
ok( ( grep { $_ =~ $regwarn } ( $title->warnings() ) ), 'expected warning text reported' );
my ( $line, $dummy ) = grep { $_ =~ $stat->{regex} } @contents;
if ($_ !~ $pat) { foo(); }
=head1 $_ =~ /foo/

