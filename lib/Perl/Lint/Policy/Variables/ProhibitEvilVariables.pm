package Perl::Lint::Policy::Variables::ProhibitEvilVariables;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'The names of or patterns for variables to forbid.',
    EXPL => 'Find an alternative variable',
};

use constant VAR_TOKENS => {
    &VAR              => 1,
    &CODE_VAR         => 1,
    &ARRAY_VAR        => 1,
    &HASH_VAR         => 1,

    &GLOBAL_VAR       => 1,
    &GLOBAL_ARRAY_VAR => 1,
    &GLOBAL_HASH_VAR  => 1,

    &LOCAL_VAR        => 1,
    &LOCAL_ARRAY_VAR  => 1,
    &LOCAL_HASH_VAR   => 1,

    &SPECIFIC_VALUE   => 1,
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @evil_variables = split /\s/, ($args->{prohibit_evil_variables}->{variables} || '');
    if (! @evil_variables) {
        return [];
    }

    my %used_var_with_line_num;
    for (my $i = 0, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};
        $token_data = $token->{data};

        if (VAR_TOKENS->{$token_type}) {
            my $var  = $token_data;
            my $line = $token->{line};

            $token = $tokens->[++$i];
            $token_type = $token->{type};

            my $opener;
            my $closer;
            if ($token_type == LEFT_BRACE) {
                $opener = LEFT_BRACE;
                $closer = RIGHT_BRACE;
            }
            elsif ($token_type == LEFT_BRACKET) {
                $opener = LEFT_BRACKET;
                $closer = RIGHT_BRACKET;
            }

            if ($opener && $closer) {
                $var .= $token->{data}; # data of opener
                my $left_bracket_num = 1;
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};

                    $var .= $token->{data};

                    if ($token_type == $opener) {
                        $left_bracket_num++;
                    }
                    elsif ($token_type == $closer) {
                        last if --$left_bracket_num <= 0;
                    }
                }
            }

            $used_var_with_line_num{$var} = $line;
        }
    }

    my @violations;
    for my $evil_var (@evil_variables) {
        if (my $line = $used_var_with_line_num{$evil_var}) {
            push @violations, {
                filename => $file,
                line     => $line,
                description => DESC,
                explanation => EXPL,
                policy => __PACKAGE__,
            };
        }
    }
    return \@violations;
}

1;

