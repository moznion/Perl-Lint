package Perl::Lint::Policy::ValuesAndExpressions::RequireNumberSeparators;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Long number not separated with underscores',
    EXPL => [59],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $min_value = 100_000;
    if (my $this_policies_arg = $args->{require_number_separators}) {
        $min_value = $this_policies_arg->{min_value} || $min_value;
    }

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};

        if ($token_type == INT || $token_type == DOUBLE) {
            (my $num = $token->{data}) =~ s/\A[+-]//;

            my ($decimal_part, $fractional_part) = split /\./, $num;
            my @decimals    = split /_/, $decimal_part;
            my @fractionals = ();

            my $joined;
            if (defined $fractional_part) {
                @fractionals = split /_/, $fractional_part;
                $joined = join('', @decimals) . '.' . join('', @fractionals);
            } else {
                $joined = join '', @decimals;
            }

            if ((eval($joined) // -$min_value - 1) < $min_value) { ## no critic
                #                 ~~~~~~~~~~~~~~~ If reach here, $joined is not a number
                next;
            }

            for my $part (@decimals, @fractionals) {
                if (eval($part) >= 1000) {  ## no critic
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
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

