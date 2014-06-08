package Perl::Lint::Evaluator::Modules::RequireExplicitPackage;
use strict;
use warnings;
use List::Util qw/any/;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Evaluator";

# TODO msg!
use constant {
    DESC => '',
    EXPL => '',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    my $exempt_scripts = $args->{require_explicit_package}->{exempt_scripts};
    my $allow_import_of = $args->{require_explicit_package}->{allow_import_of};
    # for (my $i = 0; my $token = $next_token || $tokens->[$i]; $i++) {
    #     $next_token = $tokens->[$i+1];
    #     my $token_type = $token->{type};
    #     my $token_data = $token->{data};
    # }
    my $token = $tokens->[0];
    if (($exempt_scripts || !$token || $token->{type} == PACKAGE) && !$allow_import_of) {
        return [];
    }
    else {
        for (my $i = 0; my $token = $tokens->[$i]; $i++) {
            my $token_type = $token->{type};
            my $token_data = $token->{data};

            if ($token_type == USE_DECL) {
                my $used_name = '';
                for ($i++; my $token = $tokens->[$i]; $i++) {
                    my $token_type = $token->{type};
                    my $token_data = $token->{data};
                    if (
                        $token_type != NAMESPACE &&
                        $token_type != NAMESPACE_RESOLVER &&
                        $token_type != USED_NAME
                    ) {
                        last;
                    }
                    else {
                        $used_name .= $token_data;
                    }
                }
                if (!any {$_ eq $used_name} @$allow_import_of) {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
                    };
                    last;
                }
            }
            elsif ($token_type == PACKAGE) {
                last;
            }
            else {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL,
                };
                last;
            }
        }
    }

    return \@violations;
}

1;

