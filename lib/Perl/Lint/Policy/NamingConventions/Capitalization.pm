package Perl::Lint::Policy::NamingConventions::Capitalization;
use strict;
use warnings;
use String::CamelCase qw/wordsplit/;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

# TODO msg!
use constant {
    DESC => '',
    EXPL => [45, 46],
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    my $token_num = scalar @$tokens;
    my $declared = 0;
    my $next_token;
    for (my $i = 0; $i < $token_num; $i++) {
        my $token   = $next_token || $tokens->[$i];
        $next_token = $tokens->[$i + 1] || {};
        my $token_type = $token->{type};

        if ($token_type == VAR_DECL || $token_type == OUR_DECL) {
            $declared = 1;
            next;
        }

        my $must_be_all_caps_fullname = '';

        # for `const my $CONST`
        if ($token_type == KEY && $token->{data} eq 'const') {
            $i++;
            my $next_token_type = $next_token->{type};
            if ($next_token_type == VAR_DECL || $next_token_type == OUR_DECL) {
                $must_be_all_caps_fullname = substr $tokens->[++$i]->{data}, 1;
                $next_token = undef;
            }
        }

        my $fullname = '';
        if (
            $declared &&
            (
                $token_type == VAR             ||
                $token_type == LOCAL_VAR       ||
                $token_type == LOCAL_ARRAY_VAR ||
                $token_type == LOCAL_HASH_VAR  ||
                $token_type == GLOBAL_VAR # XXX
            )
        ) {
            next if ($next_token->{type} == NAMESPACE_RESOLVER);
            $fullname = substr $token->{data}, 1;
        }
        elsif ($token_type == FUNCTION) {
            $fullname = $token->{data};
        }

        # if ($fullname && $declared) { # for vars
        if ($fullname) { # for vars
            for my $name (wordsplit($fullname)) {
                if (lcfirst($name) ne $name) { # XXX
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

        if ($token_type == CLASS) {
            $fullname = $token->{data};
            next if $fullname eq 'main';
        }
        elsif ($token_type == NAMESPACE) {
            # for `Readonly::Scalar my $CONSTANT`
            if ($token->{data} eq 'Readonly') {
                $i += 2;
                my $after_token = $tokens->[$i];
                if (
                    $after_token->{type} == NAMESPACE &&
                    $after_token->{data} eq 'Scalar'
                ) {
                    $after_token = $tokens->[++$i];
                    my $after_token_type = $after_token->{type};
                    if (
                        $after_token_type == VAR_DECL ||
                        $after_token_type == OUR_DECL
                    ) {
                        $must_be_all_caps_fullname = substr $tokens->[++$i]->{data}, 1;
                        $next_token = undef;
                    }
                }
            }
            else {
                $fullname = $token->{data};
            }
        }

        if ($fullname) {
            for my $name (wordsplit($fullname)) {
                if (ucfirst($name) ne $name) { # XXX
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

        if ($must_be_all_caps_fullname) {
            for my $name (wordsplit($must_be_all_caps_fullname)) {
                if ($name !~ /\A[A-Z]+\Z/) {
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

        if ($token_type == SEMI_COLON) {
            $declared = 0;
        }
    }

    return \@violations;
}

1;

