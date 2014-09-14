package Perl::Lint::Policy::Variables::RequireLocalizedPunctuationVars;
use strict;
use warnings;
use B::Keywords;
use List::MoreUtils qw/apply uniq/;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Magic variable "%s" should be assigned as "local"',
    EXPL => [81, 82],
};

my %var_token_types = (
    &VAR              => 1,
    &ARRAY_VAR        => 1,
    &HASH_VAR         => 1,
    &GLOBAL_VAR       => 1,
    &GLOBAL_ARRAY_VAR => 1,
    &GLOBAL_HASH_VAR  => 1,

    &PROGRAM_ARGUMENT    => 1,
    &LIBRARY_DIRECTORIES => 1,
    &INCLUDE             => 1,
    &ENVIRONMENT         => 1,
    &SIGNAL              => 1,
    &SPECIFIC_VALUE      => 1,
    &ARRAY_SIZE          => 1,
);

my @globals = (
    @B::Keywords::Arrays,
    @B::Keywords::Hashes,
    @B::Keywords::Scalars,
);
push @globals, map { "*$_" } grep { substr($_, 0, 1) ne '*' } @B::Keywords::Filehandles;
my %globals = map { $_ => 1 } @globals;

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @exemptions = qw/$_ $ARG @_/;
    if (my $this_policies_arg = $args->{require_localized_punctuation_vars}) {
        push @exemptions, split(/\s+/, $this_policies_arg->{allow} || '');
    }
    my %exemptions = map { $_ => 1 } @exemptions;

    my @violations;
    for (my $i = 0, my $token_type, my $variable; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};

        if ($token_type == LOCAL_DECL) {
            $token = $tokens->[++$i];

            last if !$token;
            if ($token->{type} == LEFT_PAREN) {
                my $lpnum = 1;
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};

                    if ($token_type == LEFT_PAREN) {
                        $lpnum++;
                    }
                    elsif ($token_type == RIGHT_PAREN) {
                        last if --$lpnum <= 0;
                    }
                }
            }

            next;
        }

        $variable = $token->{data};
        if ($token_type == MOD) {
            $token = $tokens->[++$i];
            $token_type = $token->{type};

            last if !$token;
            if ($token_type == NOT) {
                $variable .= $token->{data};
                $token_type = VAR; # XXX
            }
            elsif ($token_type == BIT_XOR) {
                $variable .= $token->{data};

                $token = $tokens->[++$i];
                $token_type = $token->{type};

                last if !$token;

                if ($token_type == KEY) {
                    $variable .= $token->{data};
                    $token_type = VAR; # XXX
                }
            }
        }
        elsif ($token_type == SPECIFIC_VALUE) {
            $token = $tokens->[$i+1];
            next if !$token;

            if ($token->{type} == KEY) {
                $i++;
                $variable .= $token->{data};
                $token_type = SPECIFIC_VALUE;
            }
        }
        elsif ($token_type == GLOB) {
            $token = $tokens->[++$i];

            last if !$token;
            $token_type = $token->{type};
            if (
                $token_type == KEY ||
                $token_type == TYPE_STDIN  ||
                $token_type == TYPE_STDOUT ||
                $token_type == TYPE_STDERR
            ) {
                $variable .= $token->{data};
                $token_type = VAR; # XXX
            }
        } ## fall through

        if ($var_token_types{$token_type}) {
            my $line = $token->{line};

            my $before_token = $tokens->[$i-1];
            if ($before_token && $before_token->{type} == ASSIGN) {
                next;
            }

            $token = $tokens->[++$i];
            last if !$token;
            $token_type = $token->{type};

            if ($token_type == LEFT_BRACKET) {
                my $lbnum = 1;
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};
                    if ($token_type == LEFT_BRACKET) {
                        $lbnum++;
                    }
                    elsif ($token_type == RIGHT_BRACKET) {
                        last if --$lbnum <= 0;
                    }
                }
                $token = $tokens->[++$i];

                substr($variable, 0, 1) = '@';
            }
            elsif ($token_type == LEFT_BRACE) {
                my $lbnum = 1;
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};
                    if ($token_type == LEFT_BRACE) {
                        $lbnum++;
                    }
                    elsif ($token_type == RIGHT_BRACE) {
                        last if --$lbnum <= 0;
                    }
                }
                $token = $tokens->[++$i];

                substr($variable, 0, 1) = '%';
            }

            last if !$token;

            if ($token->{type} == RIGHT_PAREN) {
                $token = $tokens->[++$i];
                last if !$token;
            }

            next if $token->{type} != ASSIGN;

            if ($globals{$variable} && !$exemptions{$variable}) {
                push @violations, {
                    filename => $file,
                    line     => $line,
                    description => DESC,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
            }
        }
    }

    return \@violations;
}

1;

