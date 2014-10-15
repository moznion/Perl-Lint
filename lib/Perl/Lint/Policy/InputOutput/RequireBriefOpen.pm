package Perl::Lint::Policy::InputOutput::RequireBriefOpen;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

# TODO msg!
use constant {
    DESC => '',
    EXPL => '',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;

    my $line_gap = 9;

    if (my $this_policies_arg = $args->{require_brief_open}) {
        $line_gap = $this_policies_arg->{lines} // 9;
    }

    my $depth = 0;

    my @opened_file_handlers_for_each_depth = ([]);

    my %opened_file_globs_for_each_depth;
    my %closed_file_globs_for_each_depth;

    my %function_declared_depth;

    # use Data::Dumper::Concise; warn Dumper($tokens); # TODO remove

    my @not_closed_file_handlers;

    for (my $i = 0, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};
        $token_data = $token->{data};

        if ($token_type == LEFT_BRACE) {
            $depth++;
            next;
        }

        if ($token_type == RIGHT_BRACE) {
            my %not_closed_file_handlers = %{$opened_file_handlers_for_each_depth[-1]->[$depth] || {}};
            for my $not_closed_fh_name (keys %not_closed_file_handlers) {
                push @not_closed_file_handlers, $not_closed_file_handlers{$not_closed_fh_name};
            }

            $depth--;

            if ($function_declared_depth{$depth}) {
                pop @opened_file_handlers_for_each_depth;
            }

            next;
        }

        if ($token_type == BUILTIN_FUNC && $token_data eq 'open') {
            my $lbnum = 0;
            for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};
                $token_data = $token->{data};
                if (
                    $token_type == GLOBAL_VAR ||
                    $token_type == LOCAL_VAR  ||
                    $token_type == VAR
                ) {
                    $opened_file_handlers_for_each_depth[-1]->[$depth]->{$token_data} = $token;
                    last;
                }
                elsif ($token_type == KEY) {
                    if ($token_data =~ /\A[A-Z0-9_]+\z/) { # check UPPER_CASE or not
                        $opened_file_globs_for_each_depth{$token_data} = $token;
                    }
                    last;
                }
                elsif ($token_type == LEFT_BRACE) {
                    $lbnum++;
                }
                elsif (
                    $token_type == TYPE_STDIN  ||
                    $token_type == TYPE_STDOUT ||
                    $token_type == TYPE_STDERR ||
                    $token_type == COMMA # <= fail safe
                ) {
                    last;
                }
            }

            if ($lbnum) {
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};
                    if ($token_type == RIGHT_BRACE) {
                        last if --$lbnum <= 0;
                    }
                }
            }

            next;
        }
        elsif ($token_type == RETURN || ($token_type == BUILTIN_FUNC && $token_data eq 'close')) {
            $token = $tokens->[++$i] or last;
            $token_type = $token->{type};
            if ($token_type == LEFT_PAREN) {
                $token = $tokens->[++$i] or last;
                $token_type = $token->{type};
            }

            $token_data = $token->{data};

            if (
                $token_type == GLOBAL_VAR ||
                $token_type == LOCAL_VAR  ||
                $token_type == VAR
            ) {
                for my $d (reverse 0 .. $depth) {
                    my $hit = $opened_file_handlers_for_each_depth[-1]->[$d]->{$token_data};

                    if (defined $hit) {
                        if ($token->{line} - $hit->{line} <= $line_gap) {
                            delete $opened_file_handlers_for_each_depth[-1]->[$d]->{$token_data};
                        }
                        last;
                    }
                }
            }
            elsif ($token_type == KEY) {
                $closed_file_globs_for_each_depth{$token_data} = 1;
            }
        }

        if ($token_type == METHOD && $token_data eq 'close') {
            my $var_token = $tokens->[$i-2];
            my $var_type = $var_token->{type};
            my $var_name = $var_token->{data};

            if (
                $var_type == GLOBAL_VAR ||
                $var_type == LOCAL_VAR  ||
                $var_type == VAR
            ) {
                for my $d (reverse 0 .. $depth) {
                    my $hit = $opened_file_handlers_for_each_depth[-1]->[$d]->{$var_name};
                    if (defined $hit) {
                        if ($var_token->{line} - $hit->{line} <= $line_gap) {
                            delete $opened_file_handlers_for_each_depth[-1]->[$d]->{$var_name};
                        }
                        last;
                    }
                }
            }
        }

        if ($token_type == FUNCTION_DECL) {
            $function_declared_depth{$depth} = 1;

            push @opened_file_handlers_for_each_depth, [];
            next;
        }
    }

    my %not_closed_file_handlers = %{$opened_file_handlers_for_each_depth[-1]->[0] || {}};
    for my $not_closed_fh_name (keys %not_closed_file_handlers) {
        push @not_closed_file_handlers, $not_closed_file_handlers{$not_closed_fh_name};
    }

    for my $not_closed_file_glob (keys %closed_file_globs_for_each_depth) {
        delete $opened_file_globs_for_each_depth{$not_closed_file_glob};
    }

    for my $not_closed_file_handler (@not_closed_file_handlers) {
        push @violations, {
            filename => $file,
            line     => $not_closed_file_handler->{line},
            description => DESC,
            explanation => EXPL,
            policy => __PACKAGE__,
        };
    }

    for my $not_closed_file_glob (keys %opened_file_globs_for_each_depth) {
        push @violations, {
            filename => $file,
            line     => $opened_file_globs_for_each_depth{$not_closed_file_glob}->{line},
            description => DESC,
            explanation => EXPL,
            policy => __PACKAGE__,
        };
    }

    return \@violations;
}

1;

