package Perl::Lint::Policy::ErrorHandling::RequireCarping;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => q{Don't complain about die or warn if the message ends in a newline},
    EXPL => [283],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $options = $args->{require_carping};
    my $allow_messages_ending_with_newlines = 1;
    if (defined $options->{allow_messages_ending_with_newlines}) {
        $allow_messages_ending_with_newlines =
            $options->{allow_messages_ending_with_newlines};
    }
    my $allow_in_main_unless_in_subroutine =
        $options->{allow_in_main_unless_in_subroutine } || 0;

    my $is_in_main = 1;
    my $is_in_sub  = 0;

    my $left_brace_num = 0;

    my @violations;
    my $token_num = scalar @$tokens;

    for (my $i = 0; $i < $token_num; $i++) {
        my $token      = $tokens->[$i];
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        if (
            $token_type eq BUILTIN_FUNC &&
            ($token_data eq 'die' || $token_data eq 'warn')
        ) {
            my %last_msg;
            for ($i++; $i <= $token_num; $i++) {
                $token      = $tokens->[$i];
                $token_type = $token->{type};
                $token_data = $token->{data};

                no warnings qw/uninitialized/;
                if ($token_type == STRING) {
                    %last_msg = (type => 'not_raw', data => $token_data);
                }
                elsif ($token_type == REG_DOUBLE_QUOTE) {
                    %last_msg = (type => 'not_raw', data => $tokens->[$i+=2]->{data});
                }
                elsif ($token_type == RAW_STRING) {
                    %last_msg = (type => 'raw', data => $token_data);
                }
                elsif ($token_type == REG_QUOTE) {
                    %last_msg = (type => 'raw', data => $tokens->[$i+=2]->{data});
                }
                elsif ($token_type == HERE_DOCUMENT_TAG || $token_type == HERE_DOCUMENT_RAW_TAG) {
                    %last_msg = (type => 'heredoc', data => $token_data);
                }
                elsif (
                    $i + 1 >= $token_num             ||
                    $token_type == SEMI_COLON        ||
                    $token_type == IF_STATEMENT      ||
                    $token_type == UNLESS_STATEMENT  ||
                    $token_type == WHILE_STATEMENT   ||
                    $token_type == FOR_STATEMENT     ||
                    $token_type == FOREACH_STATEMENT ||
                    $token_type == UNTIL_STATEMENT   ||
                    $token_type == HERE_DOCUMENT_END
                ) {
                    my $last_msg_type = $last_msg{type};
                    my $last_msg_data = $last_msg{data};

                    if(
                        !(defined $last_msg_type && defined $last_msg_data) ||
                        ($last_msg_type eq 'raw' && (substr($last_msg_data, -1) ne "\n" || !$allow_messages_ending_with_newlines)) ||
                        ($last_msg_type eq 'not_raw' && ($last_msg_data !~ /(?:\\n|\n)\Z/ || !$allow_messages_ending_with_newlines))
                    ) {
                        if ($is_in_sub || !($is_in_main && $allow_in_main_unless_in_subroutine)) {
                            push @violations, {
                                filename => $file,
                                line     => $token->{line},
                                description => DESC,
                                explanation => EXPL,
                                policy => __PACKAGE__,
                            };
                        }
                    }
                    last;
                }
                elsif ($token_type == METHOD) {
                    $i++; # Skip a left parenthesis
                    my $left_paren_num = 1;
                    for ($i++; $i < $token_num; $i++) {
                        my $token_type = $tokens->[$i]->{type};

                        if ($token_type == RIGHT_PAREN) {
                            $left_paren_num--;
                        }
                        elsif ($token_type == LEFT_PAREN) {
                            $left_paren_num++;
                        }

                        if ($left_paren_num <= 0) {
                            last;
                        }
                    }
                }
                elsif (
                    $token_type == BUILTIN_FUNC ||
                    $token_type == KEY
                ) {
                    my $left_paren_num = 0;
                    for ($i++; $i < $token_num; $i++) {
                        my $token_type = $tokens->[$i]->{type};

                        if ($token_type == RIGHT_PAREN) {
                            $left_paren_num--;
                        }
                        elsif ($token_type == LEFT_PAREN) {
                            $left_paren_num++;
                        }

                        if ($left_paren_num <= 0) {
                            last;
                        }
                    }
                }
                elsif (
                    $token_type != REG_DELIM     &&
                    $token_type != COMMA         &&
                    $token_type != RIGHT_PAREN   &&
                    $token_type != HERE_DOCUMENT &&
                    $token_type != RAW_HERE_DOCUMENT
                ) {
                    %last_msg = ();
                }
                elsif ($token_type == PACKAGE) {
                    $is_in_main = $tokens->[++$i]->{data} eq 'main' ? 1 : 0;
                }

                use warnings;
            }
        }
        elsif ($token_type == PACKAGE) {
            $is_in_main = $tokens->[++$i]->{data} eq 'main' ? 1 : 0;
        }
        elsif ($token_type == FUNCTION_DECL) {
            $is_in_sub = 1;
        }
        elsif ($token_type == LEFT_BRACE) {
            $left_brace_num++;
        }
        elsif ($token_type == RIGHT_BRACE) {
            $left_brace_num--;
            if ($left_brace_num <= 0) {
                $is_in_sub = 0;
            }
        }
    }

    return \@violations;
}

1;

