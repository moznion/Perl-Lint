package Perl::Lint::Policy::RegularExpressions::ProhibitUselessTopic;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Useless use of $_',
    EXPL => '$_ should be omitted when matching a regular expression',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0, my $token_type; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};

        if ($token_type == SPECIFIC_VALUE) {
            $token = $tokens->[++$i] or last;
            $token_type = $token->{type};

            if ($token_type == REG_OK || $token_type == REG_NOT) {
                $token = $tokens->[++$i] or last;
                $token_type = $token->{type};

                if ($token_type != VAR && $token_type != GLOBAL_VAR) {
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

