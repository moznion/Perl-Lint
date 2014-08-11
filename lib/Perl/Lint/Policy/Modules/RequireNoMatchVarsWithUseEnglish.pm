package Perl::Lint::Policy::Modules::RequireNoMatchVarsWithUseEnglish;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => '"use English" without "-no_match_vars" argument',
    EXPL => '"use English" without the "-no_match_vars" argument degrades performance',
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};
        if ($token_type == USED_NAME && $token_data eq 'English') {
            SCANNING: for ($i++; my $token = $tokens->[$i]; $i++) {
                my $token_type = $token->{type};
                my $token_data = $token->{data};
                if (
                    $token_type == STRING ||
                    $token_type == RAW_STRING ||
                    $token_type == REG_EXP
                ) {
                    for my $data (split / /, $token_data) {
                        last SCANNING if $data =~ /\A-no_match_vars\Z/;
                    }
                }

                if ($token_type == SEMI_COLON) {
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

