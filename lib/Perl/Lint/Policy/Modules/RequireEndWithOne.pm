package Perl::Lint::Policy::Modules::RequireEndWithOne;
use strict;
use warnings;
use utf8;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Module does not end with "1;"',
    EXPL => 'Must end with a recognizable true value',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    if ($src =~ /\A#!/) { # for shebang. If
        return [];
    }

    my $last_token = $tokens->[-1];
    my $last_token_type = $last_token->{type};
    my $last_token_data = $last_token->{data};
    my $before_last_token = $tokens->[-2];
    my $before_last_token_type = $before_last_token->{type};
    my $before_last_token_data = $before_last_token->{data};
    my $extra_before_token = $tokens->[-3];
    if (
        !(
            $before_last_token_type == ASSIGN &&
            $last_token_type == KEY &&
            $last_token_data eq 'pod'
        ) &&
        !(
            (
                !$extra_before_token ||
                $extra_before_token->{type} == SEMI_COLON ||
                $extra_before_token->{type} == RIGHT_BRACE
            ) &&
            $before_last_token_type == INT &&
            $before_last_token_data == 1 &&
            $last_token_type == SEMI_COLON
        )
    ) {
        push @violations, {
            filename => $file,
            line     => $last_token->{line},
            description => DESC,
            explanation => EXPL,
            policy => __PACKAGE__,
        };
    }

    return \@violations;
}

1;

