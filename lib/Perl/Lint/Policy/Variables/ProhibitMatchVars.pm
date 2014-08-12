package Perl::Lint::Policy::Variables::ProhibitMatchVars;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Match variable used',
    EXPL => [82],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};
        $token_data = $token->{data};

        if ($token_type == SPECIFIC_VALUE) {
            if ($token_data eq q{$`} || $token_data eq q{$&} || $token_data eq q{$'}) {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
            }
        }
        elsif ($token_type == GLOBAL_VAR) {
            if (
                $token_data eq '$PREMATCH' ||
                $token_data eq '$MATCH'    ||
                $token_data eq '$POSTMATCH'
            ) {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
            }
        }
        elsif ($token_type == USED_NAME && $token_data eq 'English') {
            $token = $tokens->[++$i];

            if ($token->{type} == REG_LIST) {
                $i++; # Skip the first REG_DELIM
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};
                    if ($token_type == REG_DELIM) {
                        last;
                    }
                    elsif ($token_type == REG_EXP) {
                        my @regexps = split / /, $token->{data};
                        for my $regexp (@regexps) {
                            if (
                                $regexp eq '$PREMATCH' ||
                                $regexp eq '$MATCH' ||
                                $regexp eq '$POSTMATCH'
                            ) {
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
            }
        }
    }

    return \@violations;
}

1;

