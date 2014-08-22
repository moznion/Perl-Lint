package Perl::Lint::Policy::RegularExpressions::RequireLineBoundaryMatching;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Regular expression without "/m" flag',
    EXPL => [237],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;

    my $depth = 0;
    my $is_non_target_reg = 0;

    my $enabled_re_m_depth = -1; # use negative value as default
    my @enabled_re_m_depths;

    my $disable_re_m_depth = -1; # use negative value as default
    my @disable_re_m_depths;

    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        my $next_token = $tokens->[$i+1];
        my $next_token_type = $next_token->{type};
        my $next_token_data = $next_token->{data};

        if (!$is_non_target_reg && $token_type == REG_DELIM) {
            if (
                defined $next_token_type &&
                (
                    $next_token_type == SEMI_COLON ||                        # when any regex options don't exist
                    ($next_token_type == REG_OPT && $next_token_data !~ /m/) # when the `m` regex option doesn't exist
                )
            ) {
                if (
                    !($enabled_re_m_depth >= 0 && $depth >= $enabled_re_m_depth) ||
                    ($disable_re_m_depth >= 0 && $disable_re_m_depth > $enabled_re_m_depth)
                ) {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                }
            }

            next;
        }

        # Ignore regexes which are unnecessary to check
        # XXX more?
        if (
            $token_type == REG_ALL_REPLACE ||
            $token_type == REG_LIST ||
            $token_type == REG_QUOTE ||
            $token_type == REG_EXEC
        ) {
            $is_non_target_reg = 1;
            next;
        }

        if ($token_type == SEMI_COLON) {
            $is_non_target_reg = 0;
            next;
        }

        # Represent block scope hierarchy
        if ($token_type == LEFT_BRACE) {
            $depth++;
            next;
        }
        if ($token_type == RIGHT_BRACE) {
            if ($enabled_re_m_depth == $depth) {
                pop @enabled_re_m_depths;
                $enabled_re_m_depth = $enabled_re_m_depths[-1] // -1;
            }
            if ($disable_re_m_depth == $depth) {
                pop @disable_re_m_depths;
                $disable_re_m_depth = $disable_re_m_depths[-1] // -1;
            }
            $depth--;
            next;
        }

        # for
        #   `use re qw{/m}`
        #   `use re '/m'`
        if ($token_type == USED_NAME && $token_data eq 're') {
            for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};
                $token_data = $token->{data};
                if ($token_type == SEMI_COLON) {
                    last;
                }
                if (
                    ($token_type == RAW_STRING || $token_type == STRING || $token_type == REG_EXP) &&
                    $token_data =~ /m/
                ) {
                    push @enabled_re_m_depths, $depth;
                    $enabled_re_m_depth = $depth;
                }
            }

            next;
        }

        # for
        #   `no re qw{/m}`
        #   `no re '/m'`
        if (
            $token_type == BUILTIN_FUNC &&
            $token_data eq 'no' &&
            $next_token_type == KEY &&
            $next_token_data eq 're'
        ) {
            for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};
                $token_data = $token->{data};
                if ($token_type == SEMI_COLON) {
                    last;
                }
                if (
                    ($token_type == RAW_STRING || $token_type == STRING || $token_type == REG_EXP) &&
                    $token_data =~ /m/
                ) {
                    push @disable_re_m_depths, $depth;
                    $disable_re_m_depth = $depth;
                }
            }

            next;
        }
    }

    return \@violations;
}

1;

