package Perl::Lint::Evaluator::NamingConventions::ProhibitAmbiguousNames;
use strict;
use warnings;
use String::CamelCase qw/wordsplit/;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Evaluator";

use constant DEFAULT_FORBIDDEN_WORDS => [qw/abstract bases close contract last left no record right second set/];

# TODO msg!
use constant {
    DESC => '',
    EXPL => '',
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    my $token_num = scalar @$tokens;
    my $next_token;
    # use Data::Dumper::Concise; warn Dumper($tokens); # TODO remove
    for (my $i = 0; $i < $token_num; $i++) {
        my $token   = $next_token || $tokens->[$i];
        $next_token = $tokens->[$i + 1] || {};
        my $token_type = $token->{type};

        my $declared_name = '';

        if (
            $token_type == VAR             ||
            $token_type == LOCAL_VAR       ||
            $token_type == LOCAL_ARRAY_VAR ||
            $token_type == LOCAL_HASH_VAR  ||
            $token_type == GLOBAL_VAR
        ) {
            $declared_name = substr $token->{data}, 1;
        }
        elsif ($token_type == FUNCTION || $token_type == NAMESPACE) {
            $declared_name = $token->{data};
        }

        if ($declared_name) {
            for my $word (wordsplit($declared_name)) {
                if (grep {$_ eq $word} @{+DEFAULT_FORBIDDEN_WORDS}) { # TODO
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

