package Perl::Lint::Policy::Modules::RequireVersionVar;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'No package-scoped "$VERSION" variable found',
    EXPL => [404],
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    my $does_exist_version_ver = 0;
    TOP: for (my $i = 0, my $next_token, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $next_token = $tokens->[$i+1];
        $token_type = $token->{type};
        $token_data = $token->{data};

        if ($token_type == USED_NAME && $token_data eq 'vars') {
            if (
                $next_token->{type} == RAW_STRING &&
                $next_token->{data} eq '$VERSION'
            ) {
                $does_exist_version_ver = 1;
                last;
            }
            for ($i++; my $token = $tokens->[$i]; $i++) {
                my $token_type = $token->{type};
                my $token_data = $token->{data};
                if ($token_type == SEMI_COLON) {
                    last;
                }

                if ($token_type == REG_EXP && $token_data eq '$VERSION') {
                    $does_exist_version_ver = 1;
                    last TOP;
                }
            }
        }
        elsif (
            ($token_type == GLOBAL_VAR && $token_data eq '$VERSION') ||
            ($token_type == CLASS && $next_token->{type} == DOUBLE) ||
            (
                $token_type == NAMESPACE_RESOLVER &&
                $next_token->{type} == NAMESPACE  &&
                $next_token->{data} eq 'VERSION'
            )
        ) {
            $does_exist_version_ver = 1;
            last;
        }
    }

    unless ($does_exist_version_ver) {
        push @violations, {
            filename => $file,
            line     => 0, # TODO
            description => DESC,
            explanation => EXPL,
            policy => __PACKAGE__,
        };
    }

    return \@violations;
}

1;

