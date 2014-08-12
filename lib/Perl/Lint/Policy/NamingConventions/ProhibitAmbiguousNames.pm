package Perl::Lint::Policy::NamingConventions::ProhibitAmbiguousNames;
use strict;
use warnings;
use String::CamelCase qw/wordsplit/;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant DEFAULT_FORBIDDEN_WORDS => [qw/abstract bases close contract last left no record right second set/];

use constant {
    DESC => 'The variable names that are not to be allowed',
    EXPL => [48],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @forbidden_words = @{+DEFAULT_FORBIDDEN_WORDS};
    if (defined(my $forbiddens = $args->{prohibit_ambiguous_names}->{forbid})) {
        @forbidden_words = split / /, $forbiddens;
    }

    my @violations;
    my $token_num = scalar @$tokens;
    for (my $i = 0; $i < $token_num; $i++) {
        my $token      = $tokens->[$i];
        my $token_type = $token->{type};

        if ($token_type == FOR_STATEMENT || $token_type == FOREACH_STATEMENT) {
            my $next_token_type = $tokens->[++$i]->{type};
            $i++ if $next_token_type == VAR_DECL || $next_token_type == OUR_DECL;
            $i++;
            next;
        }

        my @word_blocks;
        if ($token_type == VAR_DECL || $token_type == OUR_DECL || $token_type == LOCAL_DECL) {
            my $left_paren_num = 0;
            for ($i++; $i < $token_num; $i++) {
                my $token = $tokens->[$i];
                my $token_type = $token->{type};

                if (
                    $token_type == VAR             ||
                    $token_type == LOCAL_VAR       ||
                    $token_type == LOCAL_ARRAY_VAR ||
                    $token_type == LOCAL_HASH_VAR  ||
                    $token_type == GLOBAL_VAR
                ) {
                    push @word_blocks, [wordsplit(substr $token->{data}, 1)];
                }
                elsif ($token_type == NAMESPACE_RESOLVER || $token_type == GLOB) {
                    next;
                }
                elsif ($token_type == NAMESPACE) {
                    push @word_blocks, [$tokens->[$i]->{data}];
                }
                elsif ($token_type == LEFT_PAREN) {
                    $left_paren_num++;
                }
                elsif ($token_type == RIGHT_PAREN) {
                    $left_paren_num--;
                }
                elsif ($left_paren_num <= 0) {
                    last;
                }
            }
        }
        elsif ($token_type == FUNCTION_DECL) {
            for ($i++; $i < $token_num; $i++) {
                my $token = $tokens->[$i];
                my $token_type = $token->{type};

                if ($token_type == FUNCTION || $token_type == NAMESPACE) {
                    push @word_blocks, [$token->{data}];
                }
                elsif ($token_type == LEFT_BRACE) {
                    last;
                }
            }
        }

        for my $word_block (@word_blocks) {
            for my $word (@$word_block) {
                if (grep {$_ eq $word} @forbidden_words) {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                    last;
                }
            }
        }
    }

    return \@violations;
}

1;

