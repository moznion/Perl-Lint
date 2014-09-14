package Perl::Lint::Policy::Variables::ProhibitReusedNames;
use strict;
use warnings;
use List::Flatten ();
use List::Util ();
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => '',
    EXPL => '',
};

my %var_token_types = (
    &LOCAL_VAR        => 1,
    &LOCAL_ARRAY_VAR  => 1,
    &LOCAL_HASH_VAR   => 1,
    &GLOBAL_VAR       => 1,
    &GLOBAL_ARRAY_VAR => 1,
    &GLOBAL_HASH_VAR  => 1,
    &VAR              => 1,
    &ARRAY_VAR        => 1,
    &HASH_VAR         => 1,
);

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @allows = qw/$self $class/;
    if (my $this_policies_arg = $args->{prohibit_reused_names}) {
        push @allows, split(/\s+/, $this_policies_arg->{allow} || '');
    }

    my @violations;

    my $depth = 0;
    my @local_vars_by_depth = ([]);
    for (my $i = 0, my $token_type; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};

        if ($token_type == LEFT_BRACE) {
            $depth++;
            push @local_vars_by_depth, [];
            next;
        }

        if ($token_type == RIGHT_BRACE) {
            pop @local_vars_by_depth;
            $depth--;
            next;
        }

        if ($token_type == PACKAGE) {
            $local_vars_by_depth[$depth] = [];
            next;
        }

        if ($token_type == VAR_DECL || $token_type == OUR_DECL) {
            $i++;
            $token = $tokens->[$i];
            $token_type = $token->{type};

            my @vars;
            if ($token_type == LEFT_PAREN) {
                my $lpnum = 1;
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};

                    if ($token_type == LEFT_PAREN) {
                        $lpnum++;
                        next;
                    }

                    if ($token_type == RIGHT_PAREN) {
                        last if --$lpnum <= 0;
                        next;
                    }

                    if ($var_token_types{$token_type}) {
                        my $token_data = $token->{data};
                        if (List::Util::any { $_ eq $token_data } @allows) {
                            next;
                        }

                        if (
                            List::Util::any {
                                $_ eq $token_data
                            } List::Flatten::flat(@local_vars_by_depth)
                        ) {
                            push @violations, {
                                filename => $file,
                                line     => $token->{line},
                                description => DESC,
                                explanation => EXPL,
                                policy => __PACKAGE__,
                            };
                            next;
                        }

                        push @{$local_vars_by_depth[$depth]}, $token_data;
                        next;
                    }
                }
                next;
            }

            my $token_data = $token->{data};

            if (List::Util::any { $_ eq $token_data } @allows) {
                next;
            }

            if (
                List::Util::any {
                    $_ eq $token_data
                } List::Flatten::flat(@local_vars_by_depth)
            ) {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
                next;
            }

            push @{$local_vars_by_depth[$depth]}, $token_data;
            next;
        }
    }

    return \@violations;
}

1;

