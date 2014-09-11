package Perl::Lint::Policy::ControlStructures::ProhibitNegativeExpressionsInUnlessAndUntilConditions;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Found "%s" in condition for an "%s"',
    EXPL => [99],
};

my %invalid_op_types = (
    &NOT                  => '!',
    &ALPHABET_NOT         => 'not',
    &STRING_NOT_EQUAL     => 'ne',
    &NOT_EQUAL            => '!=',
    &LESS                 => '<',
    &LESS_EQUAL           => '<=',
    &GREATER              => '>',
    &GREATER_EQUAL        => '>=',
    &COMPARE              => '<=>',
    &STRING_LESS          => 'lt',
    &STRING_GREATER       => 'gt',
    &STRING_LESS_EQUAL    => 'le',
    &STRING_GREATER_EQUAL => 'ge',
    &STRING_COMPARE       => 'cmp',
    &REG_NOT              => '!~',
    &STRING_NOT_EQUAL     => 'ne',
    &NOT_EQUAL            => '!=',
);

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0, my $token_type; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};
        if ($token_type == UNLESS_STATEMENT || $token_type == UNTIL_STATEMENT) {
            my $control_structure = $token->{data};

            $token = $tokens->[++$i] or last;
            if ($token->{type} != LEFT_PAREN) {
                for (; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};
                    if ($token_type == SEMI_COLON) {
                        last;
                    }
                    elsif ($invalid_op_types{$token_type}) {
                        push @violations, {
                            filename => $file,
                            line     => $token->{line},
                            description => sprintf(DESC, $invalid_op_types{$token_type}, $control_structure),
                            explanation => EXPL,
                            policy => __PACKAGE__,
                        };
                    }
                }

                next;
            }

            my $lpnum = 1;
            for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};

                if ($token_type == LEFT_PAREN) {
                    $lpnum++;
                }
                elsif ($token_type == RIGHT_PAREN) {
                    last if --$lpnum <= 0;
                }
                elsif ($invalid_op_types{$token_type}) {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => sprintf(DESC, $invalid_op_types{$token_type}, $control_structure),
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                    last;
                }
            }
        }
    }

    return \@violations;
}

1;

