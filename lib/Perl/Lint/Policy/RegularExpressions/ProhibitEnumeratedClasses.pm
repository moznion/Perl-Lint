package Perl::Lint::Policy::RegularExpressions::ProhibitEnumeratedClasses;
use strict;
use warnings;
use List::Util ();
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Use named character classes (%s VS. %s)',
    EXPL => [248],
};

my @patterns = (
   [q{ },'\\t','\\r','\\n'] => ['\\s', '\\S'],
   ['A-Z','a-z','0-9','_']  => ['\\w', '\\W'],
   ['A-Z','a-z']            => ['[[:alpha:]]','[[:^alpha:]]'],
   ['A-Z']                  => ['[[:upper:]]','[[:^upper:]]'],
   ['a-z']                  => ['[[:lower:]]','[[:^lower:]]'],
   ['0-9']                  => ['\\d','\\D'],
   ['\w']                   => [undef, '\\W'],
   ['\s']                   => [undef, '\\S'],
);

my %ordinals = (
    ord "\n" => '\\n',
    ord "\f" => '\\f',
    ord "\r" => '\\r',
    ord q< > => q< >,
);

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @violations;
    for (my $i = 0, my $token_type; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};

        if ($token_type == REG_EXP || $token_type == REG_REPLACE_FROM) {
            my $regex = $token->{data};
            if (my @captures = $regex =~ / (\\)* \[ (\^?) (.+) ] /gx) {
                while (@captures) {
                    my $backslashes = shift @captures;
                    my $is_negate   = shift @captures;
                    my $in_brackets = shift @captures;

                    if ($backslashes && length($backslashes) % 2 != 0) { # escaped
                        next;
                    }

                    my @parts = $in_brackets =~ /([^\\]-[^\\] | [_ ] | \\[trnws])/gx;
                    my @octs = $in_brackets =~ /\\0([0-7]+)/gx;
                    for my $oct (@octs) {
                        if (my $chr = $ordinals{oct $oct}) {
                            push @parts, $chr;
                        }
                    }

                    my @hexs = $in_brackets =~ /\\x{?([0-9a-f]+)}?/gx;
                    for my $hex (@hexs) {
                        if (my $chr = $ordinals{hex $hex}) {
                            push @parts, $chr;
                        }
                    }

                    my %parts = map {$_ => 1} @parts;
                    for (my $j = 0; $j < @patterns; $j += 2) {
                        if (List::Util::all { exists $parts{$_} } @{$patterns[$j]}) {
                            my $index = 0;
                            if ($is_negate) {
                                $index = 1;
                            }

                            if ($is_negate && ! defined $patterns[$j+1]->[0]) {
                                # the [^\w] => \W rule only applies if \w is the only token.
                                # that is it does not apply to [^\w\s]
                                next if 1 != scalar keys %parts;
                            }

                            my $orig = join q{}, '[', ($is_negate ? q{^} : ()), @{$patterns[$j]}, ']';
                            if (defined (my $improvement = $patterns[$j+1]->[$index])) {
                                push @violations, {
                                    filename => $file,
                                    line     => $token->{line},
                                    description => sprintf(DESC, $orig, $improvement),
                                    explanation => EXPL,
                                    policy => __PACKAGE__,
                                };
                                last;
                            }
                        }
                    }
                }
            }
        }
    }

    return \@violations;
}

1;

