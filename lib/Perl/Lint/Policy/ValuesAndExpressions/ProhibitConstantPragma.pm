package Perl::Lint::Policy::ValuesAndExpressions::ProhibitConstantPragma;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Pragma "constant" used',
    EXPL => [55],
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};

        if ($token_type == USE_DECL) {
            my $next_token = $tokens->[++$i];
            if ($next_token->{type} == USED_NAME && $next_token->{data} eq 'constant') {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
            }
        }
    }

    return \@violations;
}

1;

