package Perl::Lint::Policy::ControlStructures::ProhibitDeepNests;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Code structure is deeply nested',
    EXPL => 'Consider refactoring',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $max_nexts = $args->{prohibit_deep_nests}->{max_nests} || 5;

    my @violations;
    my $lbnum = 0;
    my $parent_of_nests_line_number = 0;
    for (my $i = 0, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};
        $token_data = $token->{data};

        if ($token_type == LEFT_BRACE) {
            if ($lbnum == 0) {
                $parent_of_nests_line_number = $token->{line};
            }

            $lbnum++;

            if ($lbnum > $max_nexts) {
                push @violations, {
                    filename => $file,
                    line     => $parent_of_nests_line_number,
                    description => DESC,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
            }

            next;
        }

        if ($token_type == RIGHT_BRACE) {
            $lbnum--;
            next;
        }

        if (
            $token_type == VAR ||
            $token_type == GLOBAL_VAR ||
            $token_type == FUNCTION_DECL ||
            ($token_type == BUILTIN_FUNC && $token_data eq 'eval')
        ) {
            $token = $tokens->[++$i];

            if (!$token) {
                last;
            }

            if ($token->{type} == POINTER) {
                $token = $tokens->[++$i];
                last if !$token;
            }

            if ($token->{type} == LEFT_BRACE) {
                my $unnecessary_lbnum = 1;

                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};

                    if ($token_type == LEFT_BRACE) {
                        $unnecessary_lbnum++;
                    }
                    elsif ($token_type == RIGHT_BRACE) {
                        last if --$unnecessary_lbnum <= 0;
                    }
                }
            }

            next;
        }
    }

    return \@violations;
}

1;

