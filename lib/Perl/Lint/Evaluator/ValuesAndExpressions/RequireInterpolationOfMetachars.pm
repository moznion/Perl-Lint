package Perl::Lint::Evaluator::ValuesAndExpressions::RequireInterpolationOfMetachars;
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
        }
        if ($token_type == RAW_STRING) {
            if ($is_used_vers) {
                next;
            }

            if (my @backslashes = $token_data =~ /(\\*)(?:[\$\@][^\s{]\S*|\\[tnrfbae01234567xcNluLUEQ])/g) {
                my $is_not_escaped = 0;
                for my $backslash (@backslashes) {
                    if (length($backslash) % 2 == 0) { # check escaped or not
                        $is_not_escaped = 1;
                    }
                }

                if ($is_not_escaped) {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
                    };
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

