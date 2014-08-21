package Perl::Lint::Policy::Variables::RequireLexicalLoopIterators;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Loop iterator is not lexical',
    EXPL => [108],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $perl_version_threshold = 5.003;
    my $perl_version = 6; # to hit always on default. Yes, this is Perl6 :)

    my @violations;
    for (my $i = 0, my $token_type; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};

        if (
            $token_type == FOR_STATEMENT ||
            ($token_type == FOREACH_STATEMENT && $perl_version > $perl_version_threshold)
        ) {
            $token = $tokens->[++$i];
            $token_type = $token->{type};

            if ($token_type != VAR_DECL && $token_type != LEFT_PAREN) {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
            }
        }
        elsif ($token_type == USE_DECL || $token_type == REQUIRE_DECL) {
            $token = $tokens->[++$i];
            if ($token->{type} == DOUBLE) {
                $perl_version = $token->{data};
            }
        }
    }

    return \@violations;
}

1;

