use strict;
use warnings;
use Perl::Lint::Policy::Modules::RequireEndWithOne;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'Modules::RequireEndWithOne';

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
--- dscr: no code, no need for a one
--- failures: 0
--- params:
--- input
=pod

=head1 NO CODE IN HERE

=cut

===
--- dscr: basic pass
--- failures: 0
--- params:
--- input
1;

===
--- dscr: pass with __END__
--- failures: 0
--- params:
--- input
1;
__END__

===
--- dscr: pass with __DATA__
--- failures: 0
--- params:
--- input
1;
__DATA__

===
--- dscr: pass with comments at the end
--- failures: 0
--- params:
--- input
1;
# The end

===
--- dscr: pass with comment on the same line
--- failures: 0
--- params:
--- input
1; # final true value

===
--- dscr: pass with extra space
--- failures: 0
--- params:
--- input
1  ;   #With extra space.

===
--- dscr: pass with more spacing
--- failures: 0
--- params:
--- input
  1  ;   #With extra space.

===
--- dscr: pass with 1 on last line, but not last statement
--- failures: 0
--- params:
--- input
$foo = 2; 1;   #On same line..

===
--- dscr: fails with 0
--- failures: 1
--- params:
--- input
0;

===
--- dscr: fail with closing sub
--- failures: 1
--- params:
--- input
1;
sub foo {}

===
--- dscr: fail with END block
--- failures: 1
--- params:
--- input
1;

END {}

===
--- dscr: fail with a non-zero true value
--- failures: 1
--- params:
--- input
'Larry';

===
--- dscr: programs are exempt
--- failures: 0
--- params:
--- input
#!/usr/bin/perl
my $foo = 42;

===
--- dscr: DESTROY sub hides the 1;
--- failures: 0
--- params:
--- input
DESTROY { warn 'DEAD'; }

1;

