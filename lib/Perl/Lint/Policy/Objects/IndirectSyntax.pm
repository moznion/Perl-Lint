package Perl::Lint::Policy::Objects::IndirectSyntax;
use strict;
use warnings;
use List::Util 1.38 qw/any/;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Subroutine "%s" called using indirect syntax',
    EXPL => [349],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @forbidden  = ('new');
    my $forbid_arg = $args->{indirect_syntax}->{forbid};
    if ($forbid_arg && ref $forbid_arg eq 'ARRAY') {
        push @forbidden, @{$forbid_arg};
    }

    my @violations;
    my $token_num = scalar @$tokens;
    for (my $i = 0; $i < $token_num; $i++) {
        my $token = $tokens->[$i];
        my $token_data = $token->{data};
        if ($token->{type} == KEY && any { $token_data eq $_ } @forbidden) {
            my $token_type = $tokens->[++$i]->{type};
            if ($token_type == KEY        ||
                $token_type == GLOBAL_VAR ||
                $token_type == VAR        ||
                $token_type == LEFT_BRACE
            ) {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => sprintf(DESC, $token_data),
                    explanation => sprintf(EXPL, $token_data),
                    policy => __PACKAGE__,
                };
            }
        }
    }

    return \@violations;
}

1;

