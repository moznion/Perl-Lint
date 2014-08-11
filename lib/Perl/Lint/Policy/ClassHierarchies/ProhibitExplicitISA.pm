package Perl::Lint::Policy::ClassHierarchies::ProhibitExplicitISA;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => '@ISA used instead of "use base"',
    EXPL => [360],
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    my $token_num = scalar @$tokens;
    for (my $i = 0; $i < $token_num; $i++) {
        my $token = $tokens->[$i];
        my $token_type = $token->{type};
        my $token_data = $token->{data};
        if (($token_type == ARRAY_VAR || $token_type == GLOBAL_ARRAY_VAR) && $token_data eq '@ISA') {
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

