package Perl::Lint::Evaluator::TestingAndDebugging::ProhibitNoStrict;
use strict;
use warnings;
use utf8;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Evaluator";

# TODO msg!
use constant {
    DESC => '',
    EXPL => '',
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @arg_allows;
    if ($args->{allow}) {
        @arg_allows = map { lc $_ } split(/[\s,]/, $args->{allow});
    }

    my @violations;
    my $token_num = scalar @$tokens;
    for (my $i = 0; $i < $token_num; $i++) {
        my $token = $tokens->[$i];
        my $token_type = $token->{type};

        if ($token_type == BUILTIN_FUNC and $token->{data} eq 'no') {
            $token = $tokens->[++$i];

            my @allows;
            if ($token->{type} == KEY && $token->{data} eq 'strict') {
                for ($i++; $i < $token_num; $i++) {
                    $token = $tokens->[$i];
                    $token_type = $token->{type};

                    if ($token_type == STRING || $token_type == RAW_STRING) {
                        push @allows, $token->{data};
                    }
                    elsif ($token_type == REG_EXP) {
                        push @allows, split(/ /, $token->{data});
                    }
                    elsif ($token_type == SEMI_COLON || !$tokens->[$i+1]) {
                        for my $arg_allow (@arg_allows) {
                            @allows = grep { $_ ne $arg_allow } @allows;
                        }
                        if (!@arg_allows || @allows) {
                            push @violations, {
                                filename => $file,
                                line     => $token->{line},
                                description => DESC,
                                explanation => EXPL,
                            };
                            last;
                        }
                    }
                }
            }
        }
    }

    return \@violations;
}

1;

