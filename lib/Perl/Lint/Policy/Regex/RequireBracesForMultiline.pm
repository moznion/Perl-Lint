package Perl::Lint::Policy::Regex::RequireBracesForMultiline;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

# TODO msg!
use constant {
    DESC => '',
    EXPL => '',
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $brackets_regex = qr/\A{\Z/;
    if ($args->{require_braces_for_multiline}->{allow_all_brackets}) {
        $brackets_regex = qr/\A[\{\(\[\<]\Z/;
    }

    my @violations;
    for (my $i = 0, my $token_type; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};

        if ($token_type == REG_EXP || $token_type == REG_REPLACE_FROM) {
            if (my @backslashes = $token->{data} =~ /(\\*)\n/g) {
                my $reg_delim_token = $tokens->[$i-1];
                if ($reg_delim_token->{data} !~ $brackets_regex) {
                    for my $backslash (@backslashes) {
                        if (!$backslash || length($backslash) % 2 == 0) {
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
            }
        }
    }

    return \@violations;
}

1;

