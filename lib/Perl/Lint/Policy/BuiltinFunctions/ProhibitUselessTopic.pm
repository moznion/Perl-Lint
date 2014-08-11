package Perl::Lint::Policy::BuiltinFunctions::ProhibitUselessTopic;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use Perl::Lint::Constants::Kind;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Useless use of $_',
    EXPL_FILETEST => '$_ should be omitted when using a filetest operator',
    EXPL_FUNCTION => '$_ should be omitted when calling "%s"',
    EXPL_FUNCTION_SPLIT => '$_ should be omitted when calling "split" with two arguments',
};

use constant {
    FILETEST_OPERATORS => {
        -r => 1,
        -w => 1,
        -x => 1,
        -o => 1,
        -R => 1,
        -W => 1,
        -X => 1,
        -O => 1,
        -e => 1,
        -z => 1,
        -s => 1,
        -f => 1,
        -d => 1,
        -l => 1,
        -p => 1,
        -S => 1,
        -b => 1,
        -c => 1,
        -u => 1,
        -g => 1,
        -k => 1,
        -T => 1,
        -B => 1,
        -M => 1,
        -A => 1,
        -C => 1,
    },
    TOPICAL_FUNCS => {
        abs       => 1,
        alarm     => 1,
        chomp     => 1,
        chop      => 1,
        chr       => 1,
        chroot    => 1,
        cos       => 1,
        defined   => 1,
        eval      => 1,
        exp       => 1,
        glob      => 1,
        hex       => 1,
        int       => 1,
        lc        => 1,
        lcfirst   => 1,
        length    => 1,
        log       => 1,
        lstat     => 1,
        mkdir     => 1,
        oct       => 1,
        ord       => 1,
        pos       => 1,
        print     => 1,
        quotemeta => 1,
        readlink  => 1,
        readpipe  => 1,
        ref       => 1,
        require   => 1,
        reverse   => 1,
        rmdir     => 1,
        sin       => 1,
        split     => 1,
        sqrt      => 1,
        stat      => 1,
        study     => 1,
        uc        => 1,
        ucfirst   => 1,
        unlink    => 1,
        unpack    => 1,
    },
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        if ($token_type == HANDLE && FILETEST_OPERATORS->{$token_data}) {
            $token = $tokens->[++$i];
            if ($token->{type} == SPECIFIC_VALUE && $token->{data} eq '$_') {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL_FILETEST,
                    policy => __PACKAGE__,
                };
            }
        }
        elsif ($token_type == BUILTIN_FUNC && TOPICAL_FUNCS->{$token_data}) {
            # Ignore when reverse() called in context of assigning into array
            my $function_name = $token_data;
            if ($function_name eq 'reverse') {
                my $two_before_token_type = $tokens->[$i-2]->{type};
                if (
                    $tokens->[$i-1]->{type} == ASSIGN &&
                    (
                        $two_before_token_type == ARRAY_VAR ||
                        $two_before_token_type == LOCAL_ARRAY_VAR ||
                        $two_before_token_type == GLOBAL_ARRAY_VAR
                    )
                ) {
                    next;
                }
            }

            my $expl = $function_name eq 'split' ? EXPL_FUNCTION_SPLIT
                                                 : sprintf EXPL_FUNCTION, $function_name;

            $token = $tokens->[++$i];

            if ($token->{type} == LEFT_PAREN) {
                my $left_paren_num = 1;
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};
                    if ($token_type == LEFT_PAREN) {
                        $left_paren_num++;
                    }
                    elsif ($token_type == RIGHT_PAREN) {
                        if (--$left_paren_num <= 0) {
                            my $previous_token = $tokens->[$i-1];
                            if (
                                $tokens->[$i-2]->{kind} != KIND_OP &&
                                $previous_token->{type} == SPECIFIC_VALUE &&
                                $previous_token->{data} eq '$_'
                            ) {
                                push @violations, {
                                    filename => $file,
                                    line     => $token->{line},
                                    description => DESC,
                                    explanation => $expl,
                                    policy => __PACKAGE__,
                                };
                            }
                        }
                        last;
                    }
                }
            }
            else {
                for (; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};
                    if ($token_type == SEMI_COLON) {
                        my $previous_token = $tokens->[$i-1];
                        if (
                            $tokens->[$i-2]->{kind} != KIND_OP &&
                            $previous_token->{type} == SPECIFIC_VALUE &&
                            $previous_token->{data} eq '$_'
                        ) {
                            push @violations, {
                                filename => $file,
                                line     => $token->{line},
                                description => DESC,
                                explanation => $expl,
                                policy => __PACKAGE__,
                            };
                        }
                        last;
                    }
                }
            }
        }
    }

    return \@violations;
}

1;

