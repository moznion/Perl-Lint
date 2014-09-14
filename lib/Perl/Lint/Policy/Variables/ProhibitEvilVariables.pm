package Perl::Lint::Policy::Variables::ProhibitEvilVariables;
use strict;
use warnings;
use Carp ();
use Perl::Lint::RegexpParser;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'The names of or patterns for variables to forbid.',
    EXPL => 'Find an alternative variable (used: "%s")',
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

use constant DEREFERENCE_TOKENS => {
    &SCALAR_DEREFERENCE => 1,
    &HASH_DEREFERENCE   => 1,
};

my $variable_name_regex = qr< [\$\@%] \S+ >xms;
my $regular_expression_regex = qr< [/] ( [^/]+ ) [/] >xms;
my @description_regexes = (
    qr< [{] ( [^}]+ ) [}] >xms,
    qr{  <  ( [^>]+ )  >  }xms,
    qr{ [[] ( [^]]+ ) []] }xms,
    qr{ [(] ( [^)]+ ) [)] }xms,
);
my $description_regex = qr< @{[join '|', @description_regexes]} >xms;
my $variables_regex = qr<
    \A
    \s*
    (?:
            ( $variable_name_regex )
        |   $regular_expression_regex
    )
    (?: \s* $description_regex )?
    \s*
>xms;
my $variables_file_line_regex = qr<
    \A
    \s*
    (?:
            ( $variable_name_regex )
        |   $regular_expression_regex
    )
    \s*
    ( \S (?: .* \S )? )?
    \s*
    \z
>xms;

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @evil_variables;
    my @evil_variables_regex;
    if (my $this_policies_arg = $args->{prohibit_evil_variables}) {
        my $variable_specifications = $this_policies_arg->{variables};
        if ($variable_specifications) {
            while (my ($variable, $regex_string, @descrs) = $variable_specifications =~ m/ $variables_regex /xms) {
                substr $variable_specifications, 0, $+[0], '';

                if ($variable) {
                    push @evil_variables, $variable;
                }
                else {
                    push @evil_variables_regex, $regex_string;
                }
            }
        }

        my $variable_specification_files = $this_policies_arg->{variables_file};
        if ($variable_specification_files) {
            open my $fh, '<', $variable_specification_files or die "Cannot open file: $!";
            while (my $line = <$fh>) {
                $line =~ s< [#] .* \z ><>xms;
                $line =~ s< \s+ \z ><>xms;
                $line =~ s< \A \s+ ><>xms;

                next if not $line;

                if (my ($variable, $regex_string, $description) =
                    $line =~ m< $variables_file_line_regex >xms) {

                    if ($variable) {
                        push @evil_variables, $variable;
                    }
                    else {
                        push @evil_variables_regex, $regex_string;
                    }
                }
            }
        }
    }

    my %used_var_with_line_num;
    for (my $i = 0, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};
        $token_data = $token->{data};

        if (VAR_TOKENS->{$token_type} || DEREFERENCE_TOKENS->{$token_type}) {
            my $var  = $token_data;
            my $line = $token->{line};

            my $opener;
            my $closer;
            if (DEREFERENCE_TOKENS->{$token_type}) { # XXX workaround
                $opener = LEFT_BRACE;
                $closer = RIGHT_BRACE;
            }
            elsif ($token_type == SPECIFIC_VALUE && $token_data eq '$^') { # XXX ad hoc
                $token = $tokens->[++$i];
                $var .= $token->{data};
                $used_var_with_line_num{$var} = $line;
                next;
            }
            else {
                $token = $tokens->[++$i];
                $token_type = $token->{type};

                if ($token_type == LEFT_BRACE) {
                    $opener = LEFT_BRACE;
                    $closer = RIGHT_BRACE;
                }
                elsif ($token_type == LEFT_BRACKET) {
                    $opener = LEFT_BRACKET;
                    $closer = RIGHT_BRACKET;
                }
                else {
                    $used_var_with_line_num{$var} = $line;
                    next;
                }

                $var .= $token->{data}; # data of opener
            }

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
            $used_var_with_line_num{$var} = $line;
        }
    }

    my @violations;
    for my $evil_var (@evil_variables) {
        (my $alt_evil_var = $evil_var) =~ s/\A[\%\@]/\$/;

        my $line = $used_var_with_line_num{$evil_var};
        my $used_var = $evil_var;
        if (! $line && $alt_evil_var) {
            $line = $used_var_with_line_num{$alt_evil_var};
            $used_var = $alt_evil_var;

            if (! $line) {
                for my $_used_var (keys %used_var_with_line_num) {
                    if ($line = $_used_var =~ /\A\Q$alt_evil_var\E [\[\{]/x) {
                        $used_var = $_used_var;
                        last;
                    }
                }
            }
        }

        if ($line) {
            push @violations, {
                filename => $file,
                line     => $line,
                description => DESC,
                explanation => sprintf(EXPL, $used_var),
                policy => __PACKAGE__,
            };
        }
    }

    my $regexp_parser = Perl::Lint::RegexpParser->new;
    for my $regex (@evil_variables_regex) {
        if (! $regexp_parser->parse($regex)) {
            Carp::croak "invalid regular expression: /$regex/";
        }

        for my $used_var (keys %used_var_with_line_num) {
            if ($used_var =~ /$regex/) {
                push @violations, {
                    filename => $file,
                    line     => $used_var_with_line_num{$used_var},
                    description => DESC,
                    explanation => sprintf(EXPL, $used_var),
                    policy => __PACKAGE__,
                };
            }
        }
    }

    return \@violations;
}

1;

