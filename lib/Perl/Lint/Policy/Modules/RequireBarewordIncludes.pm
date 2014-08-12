package Perl::Lint::Policy::Modules::RequireBarewordIncludes;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => '"%s" statement with library name as string',
    EXPL => 'Use a bareword instead',
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    my $next_token;
    for (my $i = 0, my $next_token, my $next_token_type; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        $next_token = $tokens->[$i+1];
        $next_token_type = $next_token->{type};
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
                description => sprintf(DESC, $token_data),
                explanation => EXPL,
                policy => __PACKAGE__,
            };
        }
    }

    return \@violations;
}

1;

