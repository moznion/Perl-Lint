package Perl::Lint::Policy::Variables::ProhibitPerl4PackageNames;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Using the obsolete single quote as package separator',
    EXPL => q{Use double colon (::) to separate package name components instead of single quotes (')},
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (
        my $i = 0, my $token_type, my $token_data, my $is_just_before_left_brace = 0;
        my $token = $tokens->[$i];
        $i++
    ) {
        $token_type = $token->{type};

        if ($token_type == NAMESPACE_RESOLVER) {
            my $is_perl4_package_name = $token->{data} eq q{'} ? 1 : 0;

            for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};

                if ($token_type == NAMESPACE_RESOLVER) {
                    if ($token->{data} eq q{'}) {
                        $is_perl4_package_name = 1;
                    }
                }
                elsif ($token_type != NAMESPACE) {
                    last;
                }
            }

            if ($is_perl4_package_name) {
                if ($is_just_before_left_brace) { # XXX workaround, for example `$foo{ bar'baz }`
                    next;
                }

                if ($token && $token->{type} == ARROW) { # XXX workaround, for example `$foo = { bar'baz => 0 }`
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

            $is_just_before_left_brace = 0;
        }
        elsif ($token_type == LEFT_BRACE) {
            $is_just_before_left_brace = 1;
        }
        elsif ($token_type != NAMESPACE) {
            $is_just_before_left_brace = 0;
        }
    }

    return \@violations;
}

1;

