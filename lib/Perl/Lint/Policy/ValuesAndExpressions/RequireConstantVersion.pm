package Perl::Lint::Policy::ValuesAndExpressions::RequireConstantVersion;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => '$VERSION value must be a constant',
    EXPL => 'Computed $VERSION may tie the code to a single repository, or cause spooky action from a distance',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $is_used_version = 0;
    if (my $this_packages_arg = $args->{require_constant_version}) {
        $is_used_version = $this_packages_arg->{allow_version_without_use_on_same_line};
    }

    my @violations;

    my $is_version_assigner = 0;

    TOP: for (my $i = 0, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};
        $token_data = $token->{data};

        # `use version;` declared?
        if ($token_type == USED_NAME && $token_data eq 'version') {
            $is_used_version = 1;
            next;
        }

        # in assigning context?
        if ($token_type == ASSIGN) {
            $is_version_assigner = 1;
            next;
        }

        # reset context information
        if ($token_type == SEMI_COLON) {
            $is_version_assigner = 0;
            next;
        }

        if ($token_type == BUILTIN_FUNC) {
            $token = $tokens->[++$i] or last;
            if ($token->{type} == LEFT_PAREN) {
                # skip tokens which are surrounded by parenthesis
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
            # else: skip a token (means NOP)
        }

        if ($token_type != GLOBAL_VAR && $token_type != VAR) {
            next;
        }

        if ($token_data ne '$VERSION') {
            next;
        }

        if ($is_version_assigner) {
            # skip this!
            $is_version_assigner = 0;
            next;
        }

        my $is_invalid = 0;
        my $is_var_assigned = 0;

        # check assigning context or not
        for ($i++; $token = $tokens->[$i]; $i++) {
            $token_type = $token->{type};

            if ($token_type == ASSIGN || $token_type == OR_EQUAL) {
                last;
            }
            elsif ($token_type == REG_OK) {
                $is_invalid = 1;
                last;
            }
            elsif ($token_type == SEMI_COLON) {
                next TOP;
            }
        }

        if ($is_invalid) {
            goto JUDGEMENT;
        }

        for ($i++; $token = $tokens->[$i]; $i++) {
            $token_type = $token->{type};
            $token_data = $token->{data};

            if ($token_type == SEMI_COLON) {
                last;
            }
            elsif ($token_type == STRING) {
                if ($is_invalid = $class->_is_interpolation($token_data)) {
                    last;
                }
            }
            elsif ($token_type == REG_DOUBLE_QUOTE) {
                $i += 2; # skip delimiter
                $token = $tokens->[$i] or last;
                if ($is_invalid = $class->_is_interpolation($token->{data})) {
                    last;
                }
            }
            elsif (
                $token_type == BUILTIN_FUNC ||
                $token_type == DO           || # do {...}
                $token_type == STRING_MUL   || # "a" x 42
                $token_type == NAMESPACE    || # call other package
                $token_type == REG_OK       || # =~
                $token_type == LEFT_BRACKET    # access element of array
            ) {
                $is_invalid = 1;
                last;
            }
            elsif ($token_type == ASSIGN) {
                $is_var_assigned = 0;
            }
            elsif ($token_type == VAR || $token_type == GLOBAL_VAR) {
                $is_var_assigned = 1;
            }
            elsif ($token_type == KEY) {
                if ($token_data eq 'qv') { # for `qv(...)` notation
                    if (!$is_used_version) {
                        $is_invalid = 1;
                        last;
                    }
                }
                elsif ($token_data eq 'version') { # for `version->new(...)` notation
                    if (!$is_used_version) {
                        $is_invalid = 1;
                        last;
                    }

                    $token = $tokens->[++$i] or last;
                    if ($token->{type} != POINTER) {
                        next;
                    }

                    $token = $tokens->[++$i] or last;
                    if ($token->{type} != METHOD && $token->{data} ne 'new') {
                        next;
                    }
                }
                else { # for others
                    $is_invalid = 1;
                    last;
                }
            }
        }

        JUDGEMENT:
        if ($is_invalid || $is_var_assigned) {
            push @violations, {
                filename => $file,
                line     => $token->{line},
                description => DESC,
                explanation => EXPL,
                policy => __PACKAGE__,
            };
        }
    }

    return \@violations;
}

sub _is_interpolation {
    my ($class, $str) = @_;

    while ($str =~ /(\\*)(\$\S+)/gc) {
        if (length($1) % 2 == 0) {
            # sigil is not escaped
            # interpolated!
            return 1;
        }
        else {
            # sigil is escaped
            next;
        }
    }

    return;
}

1;

