package Perl::Lint::Evaluator::Variables::ProtectPrivateVars;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Evaluator";

# TODO msg!
use constant {
    DESC => '',
    EXPL => '',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};
        $token_data = $token->{data};

        if ($token_type == NAMESPACE && $token_data =~ /\A_/) {
            push @violations, {
                filename => $file,
                line     => $token->{line},
                description => DESC,
                explanation => EXPL,
            };
        }
    }

    return \@violations;
}

1;

