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

    my @violations;
    for (my $i = 0, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};

        if ($token_type != GLOBAL_VAR && $token_type != VAR) {
            next;
        }

        $token_data = $token->{data};
        if ($token_data ne '$VERSION') {
            next;
        }

        $token = $tokens->[++$i] or last;

        if ($token->{type} != ASSIGN) {
            next;
        }

        for ($i++; $token = $tokens->[$i]; $i++) {
            $token_type = $token->{type};
            $token_data = $token->{data};

            if ($token_type == SEMI_COLON) {
                last;
            }
            elsif ($token_type == STRING) {
                while ($token_data =~ /(\\*)(\$\S+)/gc) {
                }
            }
        }

        # push @violations, {
        #     filename => $file,
        #     line     => $token->{line},
        #     description => DESC,
        #     explanation => EXPL,
        #     policy => __PACKAGE__,
        # };
    }

    return \@violations;
}

1;

