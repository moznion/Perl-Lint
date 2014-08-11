use strict;
use warnings;
use Perl::Lint::Policy::ValuesAndExpressions::ProhibitLongChainsOfMethodCalls;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ValuesAndExpressions::ProhibitLongChainsOfMethodCalls';

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
--- dscr: Basic passing
--- failures: 0
--- params:
--- input
$x->y;
$x->y();
$x->y(@foo);
$x->y(\%foo, *bar);

$x->y->z;
$x->y()->z();
$x->y(@foo)->z(@bar);
$x->y(\%foo, *bar)->z($baz, $qux);

$x->y->z->w;
$x->y()->z()->w();
$x->y(@foo)->z(@bar)->w(%baz);
$x->y(\%foo, *bar)->z($baz, $qux)->w(\@xyzzy, $plugh);

===
--- dscr: Basic failure
--- failures: 4
--- params:
--- input
$x->y->z->w->u;
$x->y()->z()->w()->u();
$x->y(@foo)->z(@bar)->w(%baz)->u($qux);
$x->y(\%foo, *bar)->z($baz, $qux)->w(\@xyzzy, $plugh)->u(@joe, @blow);

===
--- dscr: Reduced maximum chain length
--- failures: 4
--- params: {prohibit_long_chains_of_method_calls => {max_chain_length => 2}}
--- input
$x->y->z->w;
$x->y()->z()->w();
$x->y(@foo)->z(@bar)->w(%baz);
$x->y(\%foo, *bar)->z($baz, $qux)->w(\@xyzzy, $plugh);

===
--- dscr: Increased maximum chain length
--- failures: 0
--- params: {prohibit_long_chains_of_method_calls => {max_chain_length => 4}}
--- input
$x->y->z->w->u;
$x->y()->z()->w()->u();
$x->y(@foo)->z(@bar)->w(%baz)->u($qux);
$x->y(\%foo, *bar)->z($baz, $qux)->w(\@xyzzy, $plugh)->u(@joe, @blow);

===
--- dscr: Ignore array and hash ref chains
--- failures: 0
--- params:
--- input
$blargh = $x->{y}->{z}->{w}->{u};
$blargh = $x->[1]->[2]->[3]->[4];
$blargh = $x->{y}->[2]->{w}->[4];
$blargh = $x->[1]->{z}->[3]->{u};

===
--- dscr: RT #30040
--- failures: 0
--- params:
--- input
$c->response->content_type( 'text/html; charset=utf-8' )
    unless $c->response->content_type;

