package Perl::Lint::Policy::InputOutput::RequireEncodingWithUTF8Layer;
use strict;
use warnings;
use Perl::Lint::Constants::Kind;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'I/O layer ":utf8" used',
    EXPL => 'Use ":encoding(UTF-8)" to get strict validation',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        if ($token_type == BUILTIN_FUNC && ($token_data eq 'open' || $token_data eq 'binmode')) {
            my @args;
            for ($i++; my $token = $tokens->[$i]; $i++) {
                my $token_type = $token->{type};
                my $token_kind = $token->{kind};
                if ($token_type == RIGHT_PAREN || $token_kind == KIND_STMT_END || $token_kind == KIND_OP) {
                    last;
                }
                elsif (
                    $token_type != COMMA &&
                    $token_type != REG_DOUBLE_QUOTE &&
                    $token_type != REG_QUOTE &&
                    $token_type != REG_DELIM &&
                    $token_type != LEFT_PAREN &&
                    $token_kind != KIND_DECL
                ) {
                    push @args, $token->{data};
                }
            }
            my $second_arg = $args[1];
            if ($second_arg && $second_arg =~ /utf8\Z/) {
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

