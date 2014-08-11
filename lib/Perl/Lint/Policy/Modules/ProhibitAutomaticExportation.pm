package Perl::Lint::Policy::Modules::ProhibitAutomaticExportation;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Symbols are exported by default',
    EXPL => 'Use "@EXPORT_OK" or "%EXPORT_TAGS" instead',
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    for (my $i = 0, my $next_token, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $next_token = $tokens->[$i+1];
        $token_type = $token->{type};
        $token_data = $token->{data};
        if (
            ($token_type == GLOBAL_ARRAY_VAR && $token_data eq '@EXPORT') ||
            ($token_type == NAMESPACE && $token_data eq 'EXPORT' && $next_token->{type} == ASSIGN)
        ) {
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

1;

