package Perl::Lint::Policy::RegularExpressions::ProhibitComplexRegexes;
use strict;
use warnings;
use Perl::Lint::RegexpParser;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Split long regexps into smaller qr// chunks',
    EXPL => [261],
};

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $max_characters = $args->{prohibit_complex_regexes}->{max_characters} || 60;

    my $regexp_parser = Perl::Lint::RegexpParser->new; # to use to check the regexp syntax

    my @violations;
    my $is_reg_quote = 0;
    my $is_delimiter_single_quote = 0;
    for (my $i = 0, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};
        $token_data = $token->{data};

        if ($token_type == REG_DELIM) {
            if ($token_data eq q{'}) {
                $is_delimiter_single_quote = 1;
            }
        }
        elsif ($token_type == REG_EXP) {
            my $regexp = $token_data;

            my $_is_delimiter_single_quote = $is_delimiter_single_quote;
            $is_delimiter_single_quote = 0;

            my $_is_reg_quote = $is_reg_quote;
            $is_reg_quote = 0;

            if ($_is_reg_quote) {
                # ignore when reg quote
                next;
            }

            if (!$regexp_parser->parse($regexp)) {
                # invalid regexp with syntax error
                next;
            }

            if (!$_is_delimiter_single_quote) {
                # replace variables
                while ($regexp =~ /(\\*)([\$\@]\S+)/gc) {
                    if (length($1) % 2 == 0) {
                        # not escaped
                        $regexp =~ s/(\\*)[\$\@]\S+/$1xxxx/; # replace the variable to no-meaning 4 characters string
                    }
                    else {
                        # escaped
                        $regexp =~ s/(\\*)[\$\@]/$1X/; # replace the sigil to no-meaning character
                    }
                }
            }

            my $maybe_regopt = $tokens->[$i+2]; # XXX right!?
            if (
                $maybe_regopt->{type} == REG_OPT &&
                $maybe_regopt->{data} =~ /x/
            ) {
                $regexp =~ s/#.*?\n//gs; # reduce comments
                $regexp =~ s/\s//g; # reduce white spaces
            }

            if (length $regexp > $max_characters) {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
            }
        }
        elsif ($token_type == REG_QUOTE || $token_type == REG_DOUBLE_QUOTE) {
            $is_reg_quote = 1;
        }
    }

    return \@violations;
}

1;

