package Perl::Lint::Policy::Subroutines::ProhibitBuiltinHomonyms;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use Perl::Lint::Keywords;
use List::Util qw/any/;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Subroutine name is a homonym for builtin %s %s',
    EXPL => [177],
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

                my $homonym_type;
                if (is_perl_builtin($token_data)) {
                    $homonym_type = 'function';
                }
                elsif (is_perl_bareword($token_data)) {
                    $homonym_type = 'keyword';
                }
                else {
                    next;
                }

                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => sprintf(DESC, $homonym_type, $token_data),
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
            }
        }
    }

    return \@violations;
}

1;

