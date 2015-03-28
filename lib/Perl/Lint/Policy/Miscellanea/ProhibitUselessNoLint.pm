package Perl::Lint::Policy::Miscellanea::ProhibitUselessNoLint;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => q{Useless '## no critic' annotation},
    EXPL => 'This annotation can be removed',
};

sub evaluate {
    my ($class, $file, $no_lint_lines, $used_no_lint_lines) = @_;

    my @violations;
    for my $line (keys %$no_lint_lines) {
        unless ($used_no_lint_lines->{$line}) {
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

