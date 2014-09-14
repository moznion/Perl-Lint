package Perl::Lint::Policy::TestingAndDebugging::RequireUseStrict;
use strict;
use warnings;
use List::Util qw/any/;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant EQUIVALENT_PERL_VERSION => 5.011;

use constant {
    DESC => 'Code before strictures are enabled',
    EXPL => [429],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @marshals = ('strict', 'Moose', 'Moose::Role', 'Moose::Util::TypeConstraints');
    if (my $this_policies_arg = $args->{require_use_strict}) {
        push @marshals, split / /, ($this_policies_arg->{equivalent_modules} || '');
    }

    my @violations;
    my $token_num = scalar @$tokens;
    my $is_used_strict = 0;
    TOP: for (my $i = 0; $i < $token_num; $i++) {
        my $token = $tokens->[$i];
        my $token_type = $token->{type};

        if ($token_type == USE_DECL) {
            my $next_token = $tokens->[$i+1];
            if ($next_token->{type} == DOUBLE) {
                if ($next_token->{data} >= EQUIVALENT_PERL_VERSION) {
                    last;
                }
                next;
            }

            my $used_module = '';
            for ($i++; $i < $token_num; $i++) {
                $token = $tokens->[$i];
                my $token_type = $token->{type};
                my $token_data = $token->{data};
                if (
                    $token_type == USED_NAME ||
                    $token_type == NAMESPACE ||
                    $token_type == NAMESPACE_RESOLVER
                ) {
                    $used_module .= $token_data;
                }
                else {
                    if (any {$_ eq $used_module} @marshals) {
                        last TOP;
                    }
                    next TOP;
                }
            }
        }

        if ($token_type == PACKAGE) {
            for ($i++; $i < $token_num; $i++) {
                $token = $tokens->[$i];
                if ($token->{type} == SEMI_COLON) {
                    next TOP;
                }
            }
        }

        push @violations, {
            filename => $file,
            line     => $token->{line},
            description => DESC,
            explanation => EXPL,
            policy => __PACKAGE__,
        };
        last;
    }

    return \@violations;
}

1;

