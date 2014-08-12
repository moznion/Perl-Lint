package Perl::Lint::Policy::Variables::ProhibitConditionalDeclarations;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => q{Variable declared in conditional statement},
    EXPL => q{Declare variables outside of the condition},
};

sub evaluate {
    my ($class, $file, $tokens) = @_;

    my @violations;
    my $token_num = scalar @$tokens;
    for (my $i = 0; $i < $token_num; $i++) {
        my $token      = $tokens->[$i];
        my $token_type = $token->{type};

        if ($token_type == VAR_DECL || $token_type == OUR_DECL) {
            for ($i++; $i < $token_num; $i++) {
                $token = $tokens->[$i];

                if ($token->{type} == ASSIGN) {
                    my $is_before_right_paren = 0;
                    for ($i++; $i < $token_num; $i++) {
                        $token = $tokens->[$i];
                        $token_type = $token->{type};

                        if ($token_type == RIGHT_PAREN) {
                            $is_before_right_paren = 1;
                        }
                        elsif (
                            $token_type == IF_STATEMENT     ||
                            $token_type == UNLESS_STATEMENT ||
                            $token_type == WHILE_STATEMENT  ||
                            $token_type == FOR_STATEMENT    ||
                            $token_type == FOREACH_STATEMENT
                        ) {
                            push @violations, {
                                filename => $file,
                                line     => $token->{line},
                                description => DESC,
                                explanation => EXPL,
                                policy => __PACKAGE__,
                            };
                            last;
                        }
                        else {
                            my $_is_before_right_paren = $is_before_right_paren;
                            $is_before_right_paren = 0;
                            if ($_is_before_right_paren && $token_type == LEFT_BRACE) {
                                last;
                            }
                        }

                        last if $token->{type} == SEMI_COLON;
                    }
                    last;
                }

                last if $token->{type} == SEMI_COLON;
            }
        }
    }

    return \@violations;
}

1;

