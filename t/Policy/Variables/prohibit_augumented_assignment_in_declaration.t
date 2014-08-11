use strict;
use warnings;
use utf8;
use Perl::Lint;
use Perl::Lint::Policy::Variables::ProhibitAugmentedAssignmentInDeclaration;
use t::Policy::Util qw/fetch_violations/;
use Test::More;

my $class_name = 'Variables::ProhibitAugmentedAssignmentInDeclaration';

subtest 'Normal assignment ok' => sub {
    my $src = <<'...';
my $foo = 0;
my @bar = ( 'x', 'y', 'z' );
...
    my $violations = fetch_violations($class_name, $src);

    is_deeply $violations, [];
};

subtest 'Normal assignment with operators ok' => sub {
    my $src = <<'...';
my $foo = 0+0;
my $baz = { my $x = 1 };
my ( $a, $b ) = ( 0, 0 );
...
    my $violations = fetch_violations($class_name, $src);

    is_deeply $violations, [];
};

subtest 'real life regression' => sub {
    my $src = <<'...';
my $exception_class = ($exception_class_for{$class} ||= $class->exception_class);
my $exception_class = $exception_class_for{$class} ||= $class->exception_class;
my $feature = ${*$ftp}{net_ftp_feature} ||= do { my @feat; @feat = map { /^\s+(.*\S)/ } $ftp->message if $ftp->_FEAT; \@feat; };
my $tests = $self->{tests} ||= {};
my $attr = $_[0]->{A}->{$attrName} ||= new XML::XQL::DirAttr (Parent => $self, Name => $attrName);
...
    my $violations = fetch_violations($class_name, $src);

    is_deeply $violations, [];
};

subtest 'scalar augumented assignment' => sub {
    my $src = <<'...';
my $foo **=  0;
my $foo  +=  0;
my $foo  -=  0;
my $foo  .=  0;
my $foo  *=  0;
my $foo  /=  0;
my $foo  %=  0;
# my $foo  x=  0;
my $foo  &=  0;
my $foo  |=  0;
my $foo  ^=  0;
my $foo  <<= 0;
my $foo  >>= 0;
my $foo  &&= 0;
my $foo  ||= 0;
my $foo  //= 0;

local $foo **=  0;
local $foo  +=  0;
local $foo  -=  0;
local $foo  .=  0;
local $foo  *=  0;
local $foo  /=  0;
local $foo  %=  0;
# local $foo  x=  0;
local $foo  &=  0;
local $foo  |=  0;
local $foo  ^=  0;
local $foo  <<= 0;
local $foo  >>= 0;
local $foo  &&= 0;
local $foo  ||= 0;
local $foo  //= 0;

our $foo **=  0;
our $foo  +=  0;
our $foo  -=  0;
our $foo  .=  0;
our $foo  *=  0;
our $foo  /=  0;
our $foo  %=  0;
# our $foo  x=  0;
our $foo  &=  0;
our $foo  |=  0;
our $foo  ^=  0;
our $foo  <<= 0;
our $foo  >>= 0;
our $foo  &&= 0;
our $foo  ||= 0;
our $foo  //= 0;

state $foo **=  0;
state $foo  +=  0;
state $foo  -=  0;
state $foo  .=  0;
state $foo  *=  0;
state $foo  /=  0;
state $foo  %=  0;
# state $foo  x=  0;
state $foo  &=  0;
state $foo  |=  0;
state $foo  ^=  0;
state $foo  <<= 0;
state $foo  >>= 0;
state $foo  &&= 0;
state $foo  ||= 0;
state $foo  //= 0;
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 60;
    # TODO x= assignment
};

subtest 'real life examples' => sub {
    my $src = <<'...';
local $Carp::CarpLevel += $level;
local $Carp::CarpLevel += ($lvl + 1);
*$func = sub {  local $Carp::CarpLevel += 2 if grep { $_ eq $func } @EXPORT_OK;
my $name .= $param->value('Name') ;
my $curr += ord( lc($char) ) - ord('a') + 1;
my $port ||= $port_memoized || $ENV{APACHE_TEST_PORT} || $self->{vars}{port} || DEFAULT_PORT;
my $output .= '<?' . $_[0]->getNodeName;
my $data .= &stripzerobytes(inet_aton($self->address()));
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 8;
};

done_testing;

