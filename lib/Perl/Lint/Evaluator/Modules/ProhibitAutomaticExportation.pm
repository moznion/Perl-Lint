package Perl::Lint::Evaluator::Modules::ProhibitAutomaticExportation;
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
    my $next_token;
    for (my $i = 0; my $token = $next_token || $tokens->[$i]; $i++) {
        $next_token = $tokens->[$i+1];
        my $token_type = $token->{type};
        my $token_data = $token->{data};
        if (
            ($token_type == GLOBAL_ARRAY_VAR && $token_data eq '@EXPORT') ||
            ($token_type == NAMESPACE && $token_data eq 'EXPORT' && $next_token->{type} == ASSIGN)
        ) {
            push @violations, {
                filename => $file,
                line     => $token->{line},
                description => DESC,
                explanation => EXPL,
            };
        }
    }

    return \@violations;
}

1;

