package Perl::Lint::Policy::ClassHierarchies::ProhibitAutoloading;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'AUTOLOAD method declared',
    EXPL => [393],
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    my $token_num = scalar @$tokens;
    for (my $i = 0; $i < $token_num; $i++) {
        my $token = $tokens->[$i];
        my $token_type = $token->{type};
        if ($token_type == FUNCTION_DECL) {
            if ($tokens->[++$i]->{data} eq 'AUTOLOAD') {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
                next;
            }
        }
    }

    return \@violations;
}

1;

