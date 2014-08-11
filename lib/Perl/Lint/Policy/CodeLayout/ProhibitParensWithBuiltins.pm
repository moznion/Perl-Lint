package Perl::Lint::Policy::CodeLayout::ProhibitParensWithBuiltins;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use Perl::Lint::Constants::Kind;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Builtin function called with parentheses',
    EXPL => [13],
};

my %named_unary_ops = (
    alarm          => 1,
    glob           => 1,
    rand           => 1,
    caller         => 1,
    gmtime         => 1,
    readlink       => 1,
    chdir          => 1,
    hex            => 1,
    ref            => 1,
    chroot         => 1,
    int            => 1,
    require        => 1,
    cos            => 1,
    lc             => 1,
    return         => 1,
    defined        => 1,
    lcfirst        => 1,
    rmdir          => 1,
    delete         => 1,
    length         => 1,
    scalar         => 1,
    do             => 1,
    localtime      => 1,
    sin            => 1,
    eval           => 1,
    lock           => 1,
    sleep          => 1,
    exists         => 1,
    log            => 1,
    sqrt           => 1,
    exit           => 1,
    lstat          => 1,
    srand          => 1,
    getgrp         => 1,
    my             => 1,
    stat           => 1,
    gethostbyname  => 1,
    oct            => 1,
    uc             => 1,
    getnetbyname   => 1,
    ord            => 1,
    ucfirst        => 1,
    getprotobyname => 1,
    quotemeta      => 1,
    umask          => 1,
    undef          => 1,
    sort           => 1,
);

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};

        if ($token_type == BUILTIN_FUNC) {
            my $func = $token->{data};

            $token = $tokens->[++$i];
            if ($token->{type} == LEFT_PAREN) {
                # for unary operators with parens
                if ($named_unary_ops{$func}) {
                    $token = $tokens->[++$i];

                    if ($token->{type} == RIGHT_PAREN) { # no args
                        push @violations, {
                            filename => $file,
                            line     => $token->{line},
                            description => DESC,
                            explanation => EXPL,
                            policy => __PACKAGE__,
                        };
                        next;
                    }

                    my $left_paren_num = 1;
                    for (; my $token = $tokens->[$i]; $i++) {
                        my $token_type = $token->{type};

                        if ($token_type == LEFT_PAREN) {
                            $left_paren_num++;
                        }
                        elsif ($token_type == RIGHT_PAREN) {
                            last if --$left_paren_num <= 0;
                        }
                        elsif ($token_type == COMMA) {
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
                    next;
                }

                my $is_op_in_arg = 0;
                my $left_paren_num = 1;
                for ($i++; my $token = $tokens->[$i]; $i++) {
                    my $token_type = $token->{type};

                    if ($token_type == LEFT_PAREN) {
                        $left_paren_num++;
                    }
                    elsif ($token_type == RIGHT_PAREN) {
                        last if --$left_paren_num <= 0;
                    }
                    elsif ($token_type == ASSIGN || $token->{kind} == KIND_OP) {
                        $is_op_in_arg = 1;
                    }
                }

                if ($is_op_in_arg) {
                    next;
                }

                $token = $tokens->[++$i];
                my $token_data = $token->{data};
                if (
                    $token->{type} == COMMA ||
                    (
                        $token->{kind} == KIND_OP &&
                        $token_data ne 'and' && # XXX enough?
                        $token_data ne 'or'  && # for low-precedence operator
                        $token_data ne 'xor'    #
                    )
                ) {
                    next;
                }

                push @violations, {
                    filename => $file,
                    line     => $token->{line},
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
