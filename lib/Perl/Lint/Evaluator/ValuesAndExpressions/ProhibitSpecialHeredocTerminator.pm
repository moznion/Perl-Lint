package Perl::Lint::Evaluator::ValuesAndExpressions::ProhibitSpecialHeredocTerminator;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Evaluator";

# TODO msg!
use constant {
    DESC => '',
    EXPL => '',
};

sub evaluate {
    my ($class, $file, $tokens, $args) = @_;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        if ($token_type == HERE_DOCUMENT_TAG || $token_type == HERE_DOCUMENT_RAW_TAG) {
            my $token_data = $token->{data};
            if (
                $token_data eq '__FILE__' ||
                $token_data eq '__LINE__' ||
                $token_data eq '__PACKAGE__' ||
                $token_data eq '__END__' ||
                $token_data eq '__DATA__'
            ) {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL,
                };
            }
        }
    }

    return \@violations;
}

1;

