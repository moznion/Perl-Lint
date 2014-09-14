package Perl::Lint::Policy::TestingAndDebugging::RequireTestLabels;
use strict;
use warnings;
use List::Util qw/any/;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Test without a label',
    EXPL => 'Add a label argument to all Test::More functions',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @target_test_module = ('Test::More');

    if (my $this_policies_arg = $args->{require_test_labels}) {
        push @target_test_module, split / /, ($this_policies_arg->{modules} || '');
    }

    my @violations;
    my $is_loaded = 0;
    my $token_num = scalar @$tokens;
    for (my $i = 0; $i < $token_num; $i++) {
        my $token = $tokens->[$i];
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        # for checking Test::More is loaded
        if ($token_type == USE_DECL || $token_type == REQUIRE_DECL) {
            next if $is_loaded;

            my $used_module_name = '';
            for ($i++; $i < $token_num; $i++) {
                my $token = $tokens->[$i];
                my $token_type = $token->{type};
                if ($token_type == NAMESPACE || $token_type == NAMESPACE_RESOLVER) {
                    $used_module_name .= $token->{data};
                }
                else {
                    last;
                }
            }

            if (any {$_ eq $used_module_name} @target_test_module) {
                $is_loaded = 1;
            }
            next;
        }

        if ($token_type == KEY) {
            if ($token_data eq 'pass' || $token_data eq 'fail') {
                if (
                    $tokens->[$i+1]->{type} == SEMI_COLON ||
                    (
                        $tokens->[$i+1]->{type} == LEFT_PAREN &&
                        $tokens->[$i+2]->{type} == RIGHT_PAREN
                    )
                ) {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                }
                next;
            }

            my $expected_commma_num = 0;
            if ($token_data eq 'ok') {
                $expected_commma_num = 1;
            }
            elsif ($token_data eq 'cmp_ok') {
                $expected_commma_num = 3;
            }
            elsif (
                $token_data eq 'is'     ||
                $token_data eq 'isnt'   ||
                $token_data eq 'like'   ||
                $token_data eq 'unlike' ||
                $token_data eq 'is_deeply'
            ) {
                $expected_commma_num = 2;
            }

            if ($expected_commma_num) {
                my $left_paren_num   = 0;
                my $left_brace_num   = 0;
                my $left_bracket_num = 0;
                my $comma_num = 0;

                $i++ if $tokens->[$i+1]->{type} == LEFT_PAREN;

                for ($i++; $i < $token_num; $i++) {
                    my $token = $tokens->[$i];
                    my $token_type = $token->{type};
                    my $token_data = $token->{data};

                    if ($token_type == LEFT_PAREN) {
                        $left_paren_num++;
                    }
                    elsif ($token_type == LEFT_BRACE) {
                        $left_brace_num++;
                    }
                    elsif ($token_type == LEFT_BRACKET) {
                        $left_bracket_num++;
                    }
                    elsif ($token_type == RIGHT_PAREN) {
                        $left_paren_num--;
                    }
                    elsif ($token_type == RIGHT_BRACE) {
                        $left_brace_num--;
                    }
                    elsif ($token_type == RIGHT_BRACKET) {
                        $left_bracket_num--;
                    }
                    elsif (
                        $token_type == COMMA &&
                        $left_paren_num <= 0  &&
                        $left_brace_num <= 0  &&
                        $left_bracket_num <= 0
                    ) {
                        $comma_num++;
                    }
                    elsif (
                        $token_type == SEMI_COLON &&
                        $left_paren_num <= 0       &&
                        $left_brace_num <= 0       &&
                        $left_bracket_num <= 0
                    ) {
                        if ($comma_num < $expected_commma_num) {
                            push @violations, {
                                filename => $file,
                                line     => $token->{line},
                                description => DESC,
                                explanation => EXPL,
                                policy => __PACKAGE__,
                            };
                        }
                        last;
                    }
                }
            }
        }
    }

    return \@violations if $is_loaded;
    return [];
}

1;

