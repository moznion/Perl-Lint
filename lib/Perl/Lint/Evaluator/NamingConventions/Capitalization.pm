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
    my $declared = 0;
    my $next_token;
    for (my $i = 0; $i < $token_num; $i++) {
        my $token   = $next_token || $tokens->[$i];
        $next_token = $tokens->[$i + 1] || {};
        my $token_type = $token->{type};

        if ($token_type == VAR_DECL || $token_type == OUR_DECL) {
            $declared = 1;
            next;
        }

        my $fullname = '';
        if (
            $declared &&
            ($token_type == VAR             ||
            $token_type == LOCAL_VAR       ||
            $token_type == LOCAL_ARRAY_VAR ||
            $token_type == LOCAL_HASH_VAR  ||
            $token_type == GLOBAL_VAR) # XXX
        ) {
            next if ($next_token->{type} == NAMESPACE_RESOLVER);
            $fullname = substr $token->{data}, 1;
        }
        elsif ($token_type == FUNCTION) {
            $fullname = $token->{data};
        }

        # if ($fullname && $declared) { # for vars
        if ($fullname) { # for vars
            for my $name (wordsplit($fullname)) {
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

        if ($token_type == CLASS) {
            $fullname = $token->{data};
            next if $fullname eq 'main';
        }
        elsif ($token_type == NAMESPACE) {
            $fullname = $token->{data};
        }

        if ($fullname) {
            for my $name (wordsplit($fullname)) {
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

        if ($token_type == SEMI_COLON) {
            $declared = 0;
        }
    }

    return \@violations;
}

1;

