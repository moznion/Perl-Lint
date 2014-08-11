package Perl::Lint::Policy::InputOutput::RequireBracedFileHandleWithPrint;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use Perl::Lint::Constants::Kind;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'File handle for "print" or "printf" is not braced',
    EXPL => [217],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        if ($token_type == BUILTIN_FUNC && ($token_data eq 'print' || $token_data eq 'printf' || $token_data eq 'say')) {
            my @function_args;
            for ($i++; my $token = $tokens->[$i]; $i++) {
                my $token_type = $token->{type};
                my $token_kind = $token->{kind};

                if ($token_type == SEMI_COLON) {
                    last;
                }
                elsif ($token_type == LEFT_PAREN || $token_type == RIGHT_PAREN) {
                    next;
                }

                push @function_args, $token;
            }

            if (scalar @function_args > 1) {
                my $first_arg = $function_args[0];
                my $first_arg_type = $first_arg->{type};
                my $second_arg = $function_args[1];
                my $second_arg_type = $second_arg->{type};
                my $second_arg_kind = $second_arg->{kind};
                if (
                    (
                        $first_arg_type == GLOBAL_VAR ||
                        $first_arg_type == LOCAL_VAR ||
                        $first_arg_type == VAR ||
                        $first_arg_type == KEY
                    ) &&
                    $second_arg_kind != KIND_OP &&
                    $second_arg_type != COMMA &&
                    $second_arg_type != STRING_ADD
                ) {
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

    }

    return \@violations;
}

1;

