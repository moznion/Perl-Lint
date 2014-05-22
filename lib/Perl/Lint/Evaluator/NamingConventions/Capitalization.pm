package Perl::Lint::Evaluator::NamingConventions::Capitalization;
use strict;
use warnings;
use String::CamelCase qw/wordsplit/;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Evaluator";

# TODO msg!
use constant {
    DESC => '',
    EXPL => '',
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    my $token_num = scalar @$tokens;
    # use Data::Dumper::Concise; warn Dumper($tokens); # TODO remove
    for (my $i = 0; $i < $token_num; $i++) {
        my $token      = $tokens->[$i];
        my $token_type = $token->{type};

        my $name = '';
        if (
            $token_type == LOCAL_VAR       ||
            $token_type == LOCAL_ARRAY_VAR ||
            $token_type == LOCAL_HASH_VAR  ||
            $token_type == GLOBAL_VAR # XXX
        ) {
            $name = substr $token->{data}, 1;
        }
        elsif ($token_type == FUNCTION) {
            $name = $token->{data};
        }

        if ($name) {
            for my $name (wordsplit($name)) {
                if (lcfirst($name) ne $name) { # XXX
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
                    };
                    last;
                }
            }
            next;
        }

        if (
            $token_type == CLASS ||
            $token_type == NAMESPACE
        ) {
            for my $name (wordsplit($token->{data})) {
                if (ucfirst($name) ne $name) { # XXX
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
                    };
                    last;
                }
            }
            next;
        }
    }

    return \@violations;
}

1;

