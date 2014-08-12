package Perl::Lint::Policy::References::ProhibitDoubleSigils;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Double-sigil dereference',
    EXPL => [228],
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    my $token_num = scalar @$tokens;
    for (my $i = 0; $i < $token_num; $i++) {
        my $token      = $tokens->[$i];
        my $token_type = $token->{type};

        if (
            $token_type == SHORT_SCALAR_DEREFERENCE ||
            $token_type == SHORT_ARRAY_DEREFERENCE  ||
            $token_type == SHORT_HASH_DEREFERENCE
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

    return \@violations;
}

1;

