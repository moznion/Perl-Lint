use strict;
use warnings;
use Perl::Lint::Policy::Subroutines::RequireArgUnpacking;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Subroutines::RequireArgUnpacking';

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
--- dscr: basic passes
--- failures: 0
--- params:
--- input
sub forward;

sub foo {
   my ($self, $bar) = @_;
   print $bar;
   return;
}

sub fu {
   my $self = shift;
   my $bar = shift;
   print $bar;
   return;
}

===
--- dscr: prototype passes
--- failures: 0
--- params:
--- input
sub foo() {
   print $bar;
   return;
}

===
--- dscr: scheduled subs
--- failures: 0
--- params:
--- input
BEGIN {
  print 1;
  print 2;
  print 3;
}

INIT {
  print 1;
  print 2;
  print 3;
}

CHECK {
  print 1;
  print 2;
  print 3;
}

END {
  print 1;
  print 2;
  print 3;
}

===
--- dscr: passes - no arguments
--- failures: 0
--- params:
--- input
sub few { }
sub phu { 1; }
sub phoo { return; }

===
--- dscr: failure - not idiomatic enough
--- failures: 2
--- params:
--- input
sub quux {
    my $self = shift @_;
    print $self;
}

sub cwux {
    my ($self) = ($_[0]);
    print $self;
}

===
--- dscr: basic failures
--- failures: 2
--- params:
--- input
sub bar {
  print $_[0];
  print $_[1];
  print $_[2];
  print $_[3];
}

sub barr {
  print $_[1];
}

===
--- dscr: failure in an anonymous sub
--- failures: 1
--- params:
--- input
my $x = bar {
  print $_[0];
  print $_[1];
  print $_[2];
  print $_[3];
}

===
--- dscr: basic failures, set config higher
--- failures: 1
--- params: {require_arg_unpacking => {short_subroutine_statements => 1}}
--- input
sub bar {
  print $_[0];
  print $_[1];
  print $_[2];
  print $_[3];
}

sub barr {
  print $_[1];
}

===
--- dscr: mixed failures
--- failures: 2
--- params:
--- input
sub baz {
  my $self = shift;
  print $_[0];
  print $_[1];
  print $_[2];
  print $_[3];
}

sub baaz {
  my ($self) = @_;
  print $_[0];
  print $_[1];
  print $_[2];
  print $_[3];
}

===
--- dscr: nested anon sub
--- failures: 0
--- params:
--- input
sub baz {
    print "here\n";
    return sub {
        my ($self) = @_;
        print $self->{bar};
    };
}

===
--- dscr: nested name sub
--- failures: 0
--- params:
--- input
sub baz {
    print "here\n";
    sub bar {
        my ($self) = @_;
        print $self->{bar};
    }
    $x->bar();
}

===
--- dscr: array slice (POE convention), default behavior
--- failures: 1
--- params:
--- input
sub foo {
    my ( $kernel, $heap, $input ) = @_[ KERNEL, HEAP, ARG0 ];
}

===
--- dscr: array slice (POE convention) with indices allowed
--- failures: 0
--- params: {require_arg_unpacking => {allow_subscripts => '1' }}
--- input
sub foo {
    my ( $kernel, $heap, $input ) = @_[ KERNEL, HEAP, ARG0 ];
}

sub bar {
    my $kernel = $_[ KERNEL ];
    my $heap   = $_[ HEAP   ];
    my $input  = $_[ ARG0   ];
}

===
--- dscr: exclude foreach rt#39601
--- failures: 0
--- params:
--- input
sub my_sub {

    my @a = ( [ 1, 2 ], [ 3, 4 ] );
    print @$_[0] foreach @a;

    my @b = ( [ 1, 2 ], [ 3, 4 ] );
    print @$_[0] for @b;

}

===
--- dscr: and still catch unrolling args in a postfix for
--- failures: 1
--- params:
--- input
sub my_sub {

    my @a = ( [ 1, 2 ], [ 3, 4 ] );
    print $_[0] for @a;
}

===
--- dscr: Allow the usual delegation idioms.
--- failures: 0
--- params:
--- input
sub foo {
    my $self = shift;
    return $self->SUPER::foo(@_);
}

sub bar {
    my $self = shift;
    return $self->NEXT::bar(@_);
}

===
--- dscr: Don't allow delegation to unknown places.
--- failures: 2
--- params:
--- input
sub foo {
    my $self = shift;
    # No, Class::C3 doesn't really work this way.
    return $self->Class::C3::foo(@_);
}

sub bar {
    my $self = shift;
    return $self->_unpacker(@_);
}

===
--- dscr: Allow delegation to places we have been told about.
--- failures: 0
--- params: {require_arg_unpacking => {allow_delegation_to => 'Class::C3:: _unpacker'}}
--- input
sub foo {
    my $self = shift;
    # No, Class::C3 doesn't really work this way.
    return $self->Class::C3::foo(@_);
}

sub bar {
    my $self = shift;
    return $self->_unpacker(@_);
}

===
--- dscr: Recognize $$_[0] as a use of $_, not @_ (rt #37713)
--- failures: 0
--- params:
--- input
sub foo {
    my %hash = ( a => 1, b => 2 );
    my @data = ( [ 10, 'a' ], [ 20, 'b' ], [ 30, 'c' ] );
    # $$_[1] is a funky way to say $_->[1].
    return [ grep { $hash{ $$_[1] } } @data ];
}

===
--- dscr: Allow tests (rt #79138)
--- failures: 0
--- params:
--- input
sub foo {
    my ( $self, $arg ) = @_;

    if ( @_ ) {
        say 'Some arguments';
    }
    unless ( ! @_ ) {
        say 'Some arguments';
    }
    unless ( not @_ ) {
        say 'Some arguments';
    }
    say 'Some arguments'
        if @_;
    say 'Some arguments'
        if ( @_ );
    say 'Some arguments'
        unless ! @_;
    say 'Some arguments'
        unless ( ! @_ );
    say 'Some arguments'
        unless not @_;
    say 'Some arguments'
        unless ( not @_ );
    @_
        and say 'Some arguments';
    ! @_
        or say 'Some arguments';
    not @_
        or say 'Some arguments';

    unless ( @_ ) {
        say 'No arguments';
    }
    if ( ! @_ ) {
        say 'No arguments';
    }
    if ( not @_ ) {
        say 'No arguments';
    }
    say 'No arguments'
        unless @_;
    say 'No arguments'
        unless ( @_ );
    say 'No arguments'
        if ! @_;
    say 'No arguments'
        if ( ! @_ );
    say 'No arguments'
        if not @_;
    say 'No arguments'
        if ( not @_ );
    @_
        or say 'No arguments';
    ! @_
        and say 'No arguments';
    not @_
        and say 'No arguments';

    if ( @_ == 2 ) {
        say 'Two arguments';
    }
    if ( 2 == @_ ) {
        say 'Two arguments';
    }
    @_ == 2
        and say 'Two arguments';
    2 == @_
        and say 'Two arguments';
    say 'Two arguments'
        if @_ == 2;
    say 'Two arguments'
        if ( @_ == 2 );
    unless ( @_ != 2 ) {
        say 'Two arguments';
    }
    unless ( 2 != @_ ) {
        say 'Two arguments';
    }
    say 'Two arguments'
        unless @_ != 2;
    say 'Two arguments'
        unless ( @_ != 2 );

    if ( @_ != 2 ) {
        say 'Not two arguments';
    }
    if ( 2 != @_ ) {
        say 'Not two arguments';
    }
    @_ != 2
        and say 'Not two arguments';
    2 != @_
        and say 'Not two arguments';
    say 'Not two arguments'
        if @_ != 2;
    say 'Not two arguments'
        if ( @_ != 2 );
    unless ( @_ == 2 ) {
        say 'Not two arguments';
    }
    unless ( 2 == @_ ) {
        say 'Not two arguments';
    }
    say 'Not two arguments'
        unless @_ == 2;
    say 'Not two arguments'
        unless ( @_ == 2 );

}
