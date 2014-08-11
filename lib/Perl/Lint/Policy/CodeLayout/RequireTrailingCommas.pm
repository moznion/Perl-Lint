package Perl::Lint::Policy::CodeLayout::RequireTrailingCommas;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use Perl::Lint::Constants::Kind;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'List declaration without trailing comma',
    EXPL => [17],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};

        if ($token_type == ASSIGN) {
            $token = $tokens->[++$i];

            if ($token->{type} == LEFT_PAREN) { # TODO enough?
                my $begin_line = $token->{line};

                my $left_paren_num = 1;
                my $num_of_item = 0;
                my $is_nested = 0;
                my $does_exist_procedure = 0;
                my $does_exist_any_comma = 0;

                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};

                    if ($token_type == LEFT_PAREN) {
                        $left_paren_num++;
                        $is_nested = 1;
                    }
                    elsif ($token_type == RIGHT_PAREN) {
                        if (--$left_paren_num <= 0) {
                            my $end_line = $token->{line};
                            if (
                                !$is_nested &&
                                (!$does_exist_procedure || $does_exist_any_comma) &&
                                $num_of_item > 1 &&
                                $end_line - $begin_line > 0
                            ) {
                                my $just_before_token = $tokens->[$i-1];
                                if ($just_before_token->{type} != COMMA) {
                                    push @violations, {
                                        filename => $file,
                                        line     => $token->{line},
                                        description => DESC,
                                        explanation => EXPL,
                                        policy => __PACKAGE__,
                                    };
                                }
                            }

                            last;
                        }
                    }
                    elsif (
                        $token->{kind} == KIND_OP
                    ) {
                        $does_exist_procedure = 1;
                    }
                    elsif ($token_type == COMMA) {
                        $does_exist_any_comma = 1;
                    }
                    else {
                        $num_of_item++;
                    }
                }
            }
        }
    }

    return \@violations;
}

1;

