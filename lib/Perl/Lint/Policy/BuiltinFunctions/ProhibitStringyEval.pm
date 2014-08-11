package Perl::Lint::Policy::BuiltinFunctions::ProhibitStringyEval;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Expression form of "eval"',
    EXPL => [161],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $allow_includes = $args->{prohibit_stringy_eval}->{allow_includes} || 0;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        if ($token_type == BUILTIN_FUNC && $token_data eq 'eval') {
            $token = $tokens->[++$i];
            if ($token->{type} == LEFT_PAREN) {
                $token = $tokens->[++$i];
                if ($token->{type} == RIGHT_PAREN) {
                    next;
                }
            }
            $token_type = $token->{type};

            if ($token_type != LEFT_BRACE) {
                if ($allow_includes) {
                    if ($token_type == STRING) {
                        if ($token->{data} =~ /\A(?:use|require)[^;]*(?:;|;\s*1;)?\Z/) {
                            next;
                        }
                    }
                    elsif ($token_type == RAW_STRING) {
                        if ($token->{data} =~ /\A(?:use|require)\s+([^;\s]+)[^;]*(?:;|;\s*1;)?\Z/) {
                            if ($1 !~ /\A\$/) {
                                next;
                            }
                        }
                    }
                    elsif ($token_type == REG_DOUBLE_QUOTE) {
                        $i += 2; # skip reg delimiter
                        $token = $tokens->[$i];
                        if ($token->{data} =~ /\A(?:use|require)[^;]*(?:;|;\s*1;)?\Z/) {
                            next;
                        }
                    }
                    elsif ($token_type == REG_QUOTE) {
                        $i += 2; # skip reg delimiter
                        $token = $tokens->[$i];
                        if ($token->{data} =~ /\A(?:use|require)\s+([^;\s]+)[^;]*(?:;|;\s*1;)?\Z/) {
                            if ($1 !~ /\A\$/) {
                                next;
                            }
                        }
                    }
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

    return \@violations;
}

1;

