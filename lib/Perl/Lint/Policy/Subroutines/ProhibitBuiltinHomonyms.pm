package Perl::Lint::Policy::Subroutines::ProhibitBuiltinHomonyms;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use Perl::Lint::Keywords;
use List::Util qw/any/;
use parent "Perl::Lint::Policy";

# TODO msg!
use constant {
    DESC => '',
    EXPL => '',
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        if ($token_type == FUNCTION_DECL) {
            my $token = $tokens->[++$i];
            my $token_data = $token->{data};
            if ($token->{type} == FUNCTION) {
                next if $token_data eq 'import' || $token_data eq 'AUTOLOAD' || $token_data eq 'DESTROY';

                if (is_perl_builtin($token_data) || is_perl_bareword($token_data)) {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
                    };
                }
            }
        }
    }

    return \@violations;
}

1;

