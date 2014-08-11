package Perl::Lint::Policy::ValuesAndExpressions::ProhibitNoisyQuotes;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

# TODO msg!
use constant {
    DESC => '',
    EXPL => '',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        if ($token_type == STRING || $token_type == RAW_STRING) {
            if ($token_data =~ /\A[^\w(){}[\]<>]{1,2}\Z/) {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL,
                };
            }
            next;
        }

        if ($token_type == USED_NAME && $token_data eq 'overload') {
            $i++; # skip the argument of overload
            next;
        }
    }

    return \@violations;
}

1;

