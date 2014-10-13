package Perl::Lint::Policy::InputOutput::RequireBriefOpen;
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
    for (my $i = 0, my $token_type; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};

        # push @violations, {
        #     filename => $file,
        #     line     => $token->{line},
        #     description => DESC,
        #     explanation => EXPL,
        #     policy => __PACKAGE__,
        # };
    }

    return \@violations;
}

1;

