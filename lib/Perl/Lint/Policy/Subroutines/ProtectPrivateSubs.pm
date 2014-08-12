package Perl::Lint::Policy::Subroutines::ProtectPrivateSubs;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Private subroutine/method used',
    EXPL => 'Use published APIs',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @allows = ();
    for my $allow (split(/ /, $args->{protect_private_subs}->{allow} || '')) {
        my @name_spaces = split /::/, $allow;
        my $method_name = pop @name_spaces;
        push @allows, +{
            package_name => join('::', @name_spaces),
            method_name  => $method_name,
        };
    }
    my $private_name_regex = $args->{protect_private_subs}->{private_name_regex} || '';

    my @violations;
    my $module_name = '';
    TOP: for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        my $token_data = $token->{data};

        if ($token_type == POINTER || $token_type == NAMESPACE_RESOLVER) {
            my $delimiter = $token_data;

            $token = $tokens->[++$i];
            $token_data = $token->{data};
            my $next_token = $tokens->[$i+1];
            my $next_token_type = $next_token->{type};
            if (
                substr($token_data, 0, 1) eq '_' &&
                $next_token_type != POINTER &&
                $next_token_type != NAMESPACE_RESOLVER
            ) {
                for my $allow (@allows) {
                    if (
                        $allow->{package_name} eq $module_name &&
                        $allow->{method_name} eq $token_data
                    ) {
                        next TOP;
                    }
                }

                if ($private_name_regex && $token_data =~ /$private_name_regex/) {
                    next;
                }

                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
                $module_name = '';
            }
            else {
                $module_name .= $delimiter . $token_data;
            }
        }
        elsif (
            $token_type == USE_DECL ||
            $token_type == REQUIRE_DECL ||
            $token_type == PACKAGE
        ) {
            for ($i++; $token = $tokens->[$i]; $i++) {
                $token_type = $token->{type};
                if ($token_type == SEMI_COLON) {
                    last;
                }
            }
        }
        elsif (
            ($token_type == SPECIFIC_KEYWORD && $token_data eq '__PACKAGE__') ||
            ($token_type == BUILTIN_FUNC && $token_data eq 'shift') ||
            ($token_type == NAMESPACE && $token_data eq 'POSIX')
        ) {
            $i++; # skip target func
        }
        elsif ($token_type == NAMESPACE) {
            $module_name .= $token_data;
        }
        elsif (
            (
                $token_type == VAR ||
                $token_type == GLOBAL_VAR ||
                $token_type == LOCAL_VAR
            ) && ($token_data eq '$pkg' || $token_data eq '$self')
        ) {
            $i++;
            my $next_token = $tokens->[$i+1];
            if ($next_token->{type} == NAMESPACE && $next_token->{data} eq 'SUPER') {
                $i += 2;
            }
        }
        elsif ($token_type == SEMI_COLON) {
            $module_name = '';
        }
    }

    return \@violations;
}

1;

