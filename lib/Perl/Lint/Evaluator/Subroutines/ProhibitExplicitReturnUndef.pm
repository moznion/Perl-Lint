package Perl::Lint::Evaluator::Subroutines::ProhibitExplicitReturnUndef;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Evaluator";

# TODO msg!
use constant {
    DESC => '',
    EXPL => '',
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};

        if ($token_type == RETURN) {
            my $next_token = $tokens->[++$i];
            if ($next_token->{type} == DEFAULT && $next_token->{data} eq 'undef') {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
                    };
                    next;
            }
        }
    }

    return \@violations;
}

1;

