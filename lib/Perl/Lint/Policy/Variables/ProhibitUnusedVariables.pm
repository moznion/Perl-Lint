package Perl::Lint::Policy::Variables::ProhibitUnusedVariables;
use strict;
use warnings;
use List::Flatten ();
use List::Util ();
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => '"%s" is declared but not used.',
    EXPL => 'Unused variables clutter code and make it harder to read',
};

my %var_token_types = (
    &LOCAL_VAR        => 1,
    &LOCAL_ARRAY_VAR  => 1,
    &LOCAL_HASH_VAR   => 1,
    &GLOBAL_VAR       => 1,
    &GLOBAL_ARRAY_VAR => 1,
    &GLOBAL_HASH_VAR  => 1,
    &VAR              => 1,
    &ARRAY_VAR        => 1,
    &HASH_VAR         => 1,
);

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    my $depth;
    my %vars_by_depth;
    for (my $i = 0, my $token_type; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};

        if ($token_type == LEFT_PAREN) {
            $depth++;
            next;
        }

        if ($token_type == RIGHT_PAREN) {
            for my $variable (keys %vars_by_depth) {
                push @violations, {
                    filename => $file,
                    line     => $variable,
                    description => sprintf(DESC, $variable),
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
            }
            %vars_by_depth = ();

            $depth--;
            next;
        }

        if ($token_type == VAR_DECL) {
            $token = $tokens->[++$i];
            if ($token->{type} == LEFT_PAREN) {
                my $lpnum = 1;
                my %vars_in_paren;
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};

                    if ($token_type == LEFT_PAREN) {
                        $lpnum++;
                        next;
                    }

                    if ($token_type == RIGHT_PAREN) {
                        last if --$lpnum <= 0;
                        next;
                    }

                    if ($var_token_types{$token_type}) {
                        $vars_in_paren{$token->{data}} = $token->{line};
                        next;
                    }
                }

                $token = $tokens->[$i+1];
                if ($token->{type} != ASSIGN) {
                    %vars_by_depth = (%vars_by_depth, %vars_in_paren);
                }

                next;
            }

            my $next_token = $tokens->[$i+1];
            if ($next_token->{type} != ASSIGN) {
                $vars_by_depth{$token->{data}} = $token->{line};
            }
            next;
        }

        if ($token_type == OUR_DECL || $token_type == LOCAL_DECL) {
            for ($i++; $token = $tokens->[$i]; $i++) {
                if ($token->{type} == SEMI_COLON) {
                    last;
                }
            }
            next;
        }

        if ($var_token_types{$token_type}) {
            my $variable = $token->{data};

            $token = $tokens->[$i+1];
            $token_type = $token->{type};
            if ($token_type == LEFT_BRACKET) {
                $variable = '@' . substr $variable, 1;
            }
            elsif ($token_type == LEFT_BRACE) {
                $variable = '%' . substr $variable, 1;
            }

            delete $vars_by_depth{$variable};
            next;
        }

        if (
            $token_type == REG_REPLACE_TO ||
            $token_type == REG_EXP
        ) {
            my $regex = $token->{data};

            while ($regex =~ /(\\*)([\$\@]\w+[\{\[]?)/gc) { # XXX
                if (length($1) % 2 == 0) {
                    # not escaped
                    my $variable  = $2;
                    my $last_char = substr $variable, -1, 1;
                    if ($last_char eq '{') {
                        $variable = '%' . substr $variable, 1, -1;
                    }
                    elsif ($last_char eq '[') {
                        $variable = '@' . substr $variable, 1, -1;
                    }

                    delete $vars_by_depth{$variable};
                    next;
                }
                else {
                    # escaped
                    next;
                }
            }

            next;
        }
    }

    for my $variable (keys %vars_by_depth) {
        push @violations, {
            filename => $file,
            line     => $variable,
            description => sprintf(DESC, $variable),
            explanation => EXPL,
            policy => __PACKAGE__,
        };
    }

    return \@violations;
}

1;

