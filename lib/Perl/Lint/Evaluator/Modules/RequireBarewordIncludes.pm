package Perl::Lint::Evaluator::Modules::RequireBarewordIncludes;
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
        my $_next_token = $next_token;
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        my $next_token_type = $_next_token->{type};
        if (
            $next_token_type &&
            (
                $token_type == USE_DECL     ||
                $token_type == REQUIRE_DECL ||
                ($token_type == BUILTIN_FUNC && $token_data eq 'no')
            ) &&
            (
                $next_token_type == STRING     ||
                $next_token_type == RAW_STRING ||
                $next_token_type == REG_QUOTE  ||
                $next_token_type == REG_DOUBLE_QUOTE
            )
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

