package Perl::Lint::Policy::Miscellanea::ProhibitUnrestrictedNoLint;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => q{Unrestricted '## no critic' annotation},
    EXPL => 'Only disable the Policies you really need to disable',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args, $no_lint_lines) = @_;

    my @violations;
    my $no_lint;
    for my $line (keys %$no_lint_lines) {
        $no_lint = $no_lint_lines->{$line};

        if (keys %$no_lint == 0) {
            push @violations, {
                filename => $file,
                line     => $line,
                description => DESC,
                explanation => EXPL,
                policy => __PACKAGE__,
            };
        }
    }

    return \@violations;
}

1;

