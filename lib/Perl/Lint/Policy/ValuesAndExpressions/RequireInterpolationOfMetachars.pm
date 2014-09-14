package Perl::Lint::Policy::ValuesAndExpressions::RequireInterpolationOfMetachars;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use List::Util qw/any/;
use Email::Address;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'String *may* require interpolation',
    EXPL => [51],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @rcs_keywords = ();
    if (my $this_policies_arg = $args->{require_interpolation_of_matchers}) {
        @rcs_keywords = split /\s+/, $this_policies_arg->{rcs_keywords} || '';
    }

    my $is_used_vers = 0;

    my @violations;
    for (my $i = 0, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};
        $token_data = $token->{data};

        if ($token_type == USED_NAME) {
            if ($token_data eq 'vars') {
                $is_used_vers = 1;
            }
            next;
        }

        if ($token_type == REG_QUOTE) {
            $i++; # skip reg delimiter
            $token = $tokens->[++$i];

            $token_data = $token->{data}; # It is REG_EXP, e.g. q{THIS ONE}
            $token_type = RAW_STRING; # XXX
        } # straight through!
        if ($token_type == RAW_STRING) {
            if ($is_used_vers) {
                next;
            }

            if (my @captures = $token_data =~ /
                (\\*)
                (?:
                    [\$\@]([^\s{]\S*) |
                    \\[tnrfbae01234567xcNluLUEQ]
                )/gx
            ) {
                my $length_of_captures = scalar @captures;
                my $is_violated = 0;
                for (my $i = 0; $i < $length_of_captures; $i++) {
                    if ($i % 2 == 0) {
                        my $backslash = $captures[$i];
                        if (length($backslash) % 2 == 0) { # check escaped or not
                            $is_violated = 1;
                        }
                    } else {
                        if (
                            # ports from Perl::Critic::Policy::ValuesAndExpressions::RequireInterpolationOfMetachars
                            index ($token_data, q<@>) >= 0      &&
                            $token_data !~ m< \W \@ >xms        &&
                            $token_data !~ m< \A \@ \w+ \b >xms &&
                            $token_data =~ $Email::Address::addr_spec
                        ) {
                            next;
                        }

                        my ($var_name) = ($captures[$i] || '') =~ /\A(\w+)/;

                        if (any {$_ eq $var_name} @rcs_keywords) {
                            $is_violated = 0;
                            next;
                        }

                        if ($is_violated) {
                            push @violations, {
                                filename => $file,
                                line     => $token->{line},
                                description => DESC,
                                explanation => EXPL,
                                policy => __PACKAGE__,
                            };
                            $is_violated = 0;
                            last;
                        }
                    }
                }
            }

            next;
        }

        if ($token_type == SEMI_COLON) {
            $is_used_vers = 0;
            next;
        }
    }

    return \@violations;
}

1;

