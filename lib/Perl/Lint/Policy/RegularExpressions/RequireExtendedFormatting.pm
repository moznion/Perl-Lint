package Perl::Lint::Policy::RegularExpressions::RequireExtendedFormatting;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Regular expression without "/x" flag',
    EXPL => [236],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $require_extended_formatting_arg = $args->{require_extended_formatting};
    my $minimum_regex_length_to_complain_about = $require_extended_formatting_arg->{minimum_regex_length_to_complain_about} || 0;
    my $strict = $require_extended_formatting_arg->{strict} || 0;

    my @violations;

    my $depth = 0;
    my $is_non_target_reg = 0;

    my $enabled_re_x_depth = -1; # use negative value as default
    my @enabled_re_x_depths;

    my $disabled_re_x_depth = -1; # use negative value as default
    my @disabled_re_x_depths;

    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        my $next_token = $tokens->[$i+1];
        my $next_token_type = $next_token->{type};
        my $next_token_data = $next_token->{data};

        if (!$is_non_target_reg && $token_type == REG_DELIM) {
            if (
                $next_token_type == SEMI_COLON ||                        # when any regex options don't exist
                ($next_token_type == REG_OPT && $next_token_data !~ /x/) # when the `x` regex option doesn't exist
            ) {
                if (
                    !($enabled_re_x_depth >= 0 && $depth >= $enabled_re_x_depth) ||
                    ($disabled_re_x_depth >= 0 && $disabled_re_x_depth > $enabled_re_x_depth)
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

        if ($token_type == REG_EXP || $token_type == REG_REPLACE_FROM) {
            if (length $token_data <= $minimum_regex_length_to_complain_about) {
                $is_non_target_reg = 1;
            }
            next;
        }

        # Represent block scope hierarchy
        if ($token_type == LEFT_BRACE) {
            $depth++;
            next;
        }
        if ($token_type == RIGHT_BRACE) {
            if ($enabled_re_x_depth == $depth) {
                pop @enabled_re_x_depths;
                $enabled_re_x_depth = $enabled_re_x_depths[-1] // -1;
            }
            if ($disabled_re_x_depth == $depth) {
                pop @disabled_re_x_depths;
                $disabled_re_x_depth = $disabled_re_x_depths[-1] // -1;
            }
            $depth--;
            next;
        }

        # for
        #   `use re qw{/x}`
        #   `use re '/x'`
        if ($token_type == USED_NAME && $token_data eq 're') {
            for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};
                $token_data = $token->{data};
                if ($token_type == SEMI_COLON) {
                    last;
                }
                if (
                    ($token_type == RAW_STRING || $token_type == STRING || $token_type == REG_EXP) &&
                    $token_data =~ /x/
                ) {
                    push @enabled_re_x_depths, $depth;
                    $enabled_re_x_depth = $depth;
                }
            }

            next;
        }

        # for
        #   `no re qw{/x}`
        #   `no re '/x'`
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
                    $token_data =~ /x/
                ) {
                    push @disabled_re_x_depths, $depth;
                    $disabled_re_x_depth = $depth;
                }
            }

            next;
        }
    }

    return \@violations;
}

1;

