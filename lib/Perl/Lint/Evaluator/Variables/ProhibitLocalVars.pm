package Perl::Lint::Evaluator::Variables::ProhibitLocalVars;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Evaluator";

# TODO msg!
use constant {
    DESC => '',
    EXPL => '',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0, my $token_type; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};

        if ($token_type == LOCAL_DECL) {
            $token = $tokens->[++$i];
            $token_type = $token->{type};

            if ($token_type == LEFT_PAREN) {
                my $violation;
                my $left_paren_num = 1;
                for ($i++; my $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};
                    if ($token_type == LEFT_PAREN) {
                        $left_paren_num++;
                    }
                    elsif ($token_type == RIGHT_PAREN) {
                        if (--$left_paren_num <= 0) {
                            if ($violation) {
                                push @violations, $violation;
                                undef $violation;
                            }
                            last;
                        }
                    }
                    elsif ($token_type == GLOBAL_VAR || $token_type == VAR) {
                        if ($token->{data} =~ /\A\$[a-z]/) {
                            $violation ||= +{
                                filename => $file,
                                line     => $token->{line},
                                description => DESC,
                                explanation => EXPL,
                            };
                        }
                    }
                }
            }
            elsif ($token_type == GLOBAL_VAR || $token_type == VAR) {
                if ($token->{data} =~ /\A\$[a-z]/) {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
                    };
                }
            }
        }
    }

    return \@violations;
}

1;

