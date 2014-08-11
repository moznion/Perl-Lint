package Perl::Lint::Policy::InputOutput::ProhibitTwoArgOpen;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use Perl::Lint::Constants::Kind;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Two-argument "open" used',
    EXPL => [207],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        if ($token_type == USE_DECL) {
            # Skip when `use (<=5.005)`
            $i++;
            my $token = $tokens->[$i];
            my $token_type = $token->{type};
            my $token_data = $token->{data};
            if ($token_type == DOUBLE && $token_data <= 5.005) {
                return [];
            }
        }
        elsif ($token_type == BUILTIN_FUNC && $token_data eq 'open') {
            $i++;
            my $token = $tokens->[$i];
            my $token_type = $token->{type};

            if ($token_type == LEFT_PAREN) {
                my $left_paren_num = 1;
                my @args;
                for ($i++; my $token = $tokens->[$i]; $i++) {
                    my $token_type = $token->{type};
                    my $token_kind = $token->{kind};

                    if ($token_type == LEFT_PAREN) {
                        $left_paren_num++;
                    }
                    elsif ($token_type == RIGHT_PAREN) {
                        last if --$left_paren_num <= 0;
                    }
                    elsif (
                        $token_type != COMMA &&
                        $token_type != REG_DOUBLE_QUOTE &&
                        $token_type != REG_QUOTE &&
                        $token_type != REG_DELIM &&
                        $token_kind != KIND_DECL
                    ) {
                        push @args, $token->{data};
                    }
                }
                if (scalar @args < 3) {
                    my $second = $args[1];
                    if (
                        $second &&
                        (
                            $second eq '-|' || $second eq '|-' ||
                            $second =~ /STD(?:OUT|ERR|IN)\Z/
                        )
                    ) {
                        next;
                    }

                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                }
            }
            else {
                my @args;
                for (; my $token = $tokens->[$i]; $i++) {
                    my $token_type = $token->{type};
                    my $token_kind = $token->{kind};
                    if ($token_kind == KIND_STMT_END || $token_kind == KIND_OP) {
                        last;
                    }
                    elsif (
                        $token_type != COMMA &&
                        $token_type != REG_DOUBLE_QUOTE &&
                        $token_type != REG_QUOTE &&
                        $token_type != REG_DELIM &&
                        $token_kind != KIND_DECL
                    ) {
                        push @args, $token->{data};
                    }
                }
                if (scalar @args < 3) {
                    my $second = $args[1];
                    if (
                        $second &&
                        (
                            $second eq '-|' || $second eq '|-' ||
                            $second =~ /STD(?:OUT|ERR|IN)\Z/
                        )
                    ) {
                        next;
                    }
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                }
            }
        }
    }

    return \@violations;
}

1;

