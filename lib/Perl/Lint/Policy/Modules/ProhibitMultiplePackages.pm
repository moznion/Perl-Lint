package Perl::Lint::Policy::Modules::ProhibitMultiplePackages;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Multiple "package" declarations',
    EXPL => 'Limit to one per file',
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    my $had_declared_package = 0;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        if ($token_type == PACKAGE) {
             unless ($had_declared_package) {
                 $had_declared_package = 1;
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

    return \@violations;
}

1;

