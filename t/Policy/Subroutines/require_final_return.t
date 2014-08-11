use strict;
use warnings;
use Perl::Lint::Policy::Subroutines::RequireFinalReturn;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Subroutines::RequireFinalReturn';

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
sub foo { }
sub bar;
sub baz { return; }
sub quux { return {some => [qw(complicated data)], q{ } => /structure/}; }

===
--- dscr: complex passes
--- failures: 0
--- params:
--- input
sub foo { if ($bool) { return; } else { return; } }
sub bar { unless ($bool) { return; } else { return; } }
sub baz { if ($bool) { return; } elsif ($bool2) { return; } else { return; } }
sub quuz { unless ($bool) { return; } elsif ($bool2) { return; } else { return; } }

===
--- dscr: ternary returns
--- failures: 0
--- params:
--- input
sub foo { 1 ? return : 2 ? return : return; }

===
--- dscr: returning ternaries
--- failures: 0
--- params:
--- input
sub foo { return 1 ? 1 : 2 ? 2 : 3; }

===
--- dscr: implicit returns fail
--- failures: 2
--- params:
--- input
sub foo { 1 }
sub foo { 'Club sandwich'; }

===
--- dscr: return in a constant loop
--- failures: 1
--- params:
--- input
sub foo {
    while (1==1) {
        return;
    }
}

===
--- dscr: not all code paths returns
--- failures: 3
--- params:
--- input
sub foo { if ($bool) { } else { } }
sub foo { if ($bool) { $foo = 'bar'; } else { return; } }
sub foo { unless ($bool) { $foo = 'bar'; } else { return; } }

===
--- dscr: special blocks exemption
--- failures: 0
--- params:
--- input
BEGIN {
  print 'this should not need a return';
}
INIT {
  print 'nor this';
}
CHECK {
  print 'nor this';
}
END {
  print 'nor this';
}

===
--- dscr: goto is equivalent to return
--- failures: 0
--- params:
--- input
sub foo { goto &bar; }
END_PERL

===
--- dscr: next and last are not equivalent to return (and are invalid Perl)
--- failures: 2
--- params:
--- input
sub foo { next; }
sub bar { last; }

===
--- dscr: abnormal termination is allowed
--- failures: 0
--- params:
--- input
sub foo   { die; }
sub bar   { croak; }
sub baz   { confess; }
sub bar_C { Carp::croak; }
sub baz_C { Carp::confess; }
sub quux  { exec; }
sub quux2 { exit; }
sub quux3 { throw 'nuts'; }

===
--- dscr: Final return is present, but conditional
--- failures: 5
--- params:
--- input
sub foo   { die if $condition }
sub bar   { croak unless $condition }
sub baz   { exec for @condition }
sub baz   { exit for @condition }
sub quux  { throw 'nuts'if not $condition }

===
--- dscr: Compound final return is present, but conditional
--- failures: 1
--- params:
--- input
sub foo {
    if( $condition ) {
        return if $today_is_tuesday;
    }
    else {
        exit unless $today_is_wednesday;
    }
}

===
--- dscr: Custom terminals
--- failures: 0
--- params: {require_final_return => {terminal_funcs => 'bailout abort quit'}}
--- input
sub foo  { if ($condition) { return 1; }else{ abort } }
sub bar  { if ($condition) { bailout }else{ return 1 } }
sub baz  { quit }

===
--- dscr: ForLoop is a QuoteLike::Words
--- failures: 0
--- params:
--- input
sub foo {
    for my $thingy qw<blah> {}

    return;
}

# NOTE given-when is not recommended to use, so skip
# ===
# --- dscr: RT 43309 - given/when followed by return
# --- failures: 0
# --- params:
# --- input
# sub foo {
#     given ($bar) {}
#     return;
# }

# NOTE given-when is not recommended to use, so skip
# ===
# --- dscr: given/when with return on all branches
# --- failures: 0
# --- params:
# --- input
# sub foo {
#     my ( $val ) = @_;
#     given ( $val ) {
#         when ( 'end' ) {
#             return 'End.';
#         }
#         default {
#             return 'Not end.';
#         }
#     }
# }

# NOTE given-when is not recommended to use, so skip
# ===
# --- dscr: given/suffix when with return on all branches
# --- failures: 0
# --- params:
# --- input
# sub foo {
#     my ( $val ) = @_;
#     given ( $val ) {
#         return 'End.' when 'end';
#         default {
#             return 'Not end.';
#         }
#     }
# }

# NOTE given-when is not recommended to use, so skip
# ===
# --- dscr: given/when without return on all branches fails
# --- failures: 1
# --- params:
# --- input
# sub foo {
#     my ( $val ) = @_;
#     given ( $val ) {
#         when ( 'end' ) {
#             return 'End.';
#         }
#         default {
#             print "Not end.\n";
#         }
#     }
# }

# NOTE given-when is not recommended to use, so skip
# ===
# --- dscr: given/when with return on all branches but without default fails
# --- failures: 1
# --- params:
# --- input
# sub foo {
#     my ( $val ) = @_;
#     given ( $val ) {
#         when ( 'end' ) {
#             return 'End.';
#         }
#     }
# }
