package Perl::Lint::Policy::ControlStructures::ProhibitPostfixControls;
use strict;
use warnings;
use List::Util qw/any/;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Postfix control "%s" used',
    EXPL => {
        &IF_STATEMENT      => [93, 94],
        &UNLESS_STATEMENT  => [96, 97],
        &UNTIL_STATEMENT   => [96, 97],
        &FOR_STATEMENT     => [96],
        &FOREACH_STATEMENT => [96],
        &WHILE_STATEMENT   => [96],
        &WHEN_STATEMENT    => q<Similar to "if", postfix "when" should only be used with flow-control>,
    }
};

my %control_statement_tokens = (
    &IF_STATEMENT      => 1,
    &UNLESS_STATEMENT  => 1,
    &UNTIL_STATEMENT   => 1,
    &FOR_STATEMENT     => 1,
    &FOREACH_STATEMENT => 1,
    &WHILE_STATEMENT   => 1,
    &WHEN_STATEMENT    => 1,
);

my %like_flow_control_function_tokens = (
    &GOTO   => 1,
    &RETURN => 1,
    &NEXT   => 1,
    &LAST   => 1,
    &REDO   => 1,
);

my %flow_control_statements = (
    exit    => 1,
    die     => 1,
    warn    => 1,
    carp    => 1,
    croak   => 1,
    cluck   => 1,
    confess => 1,
    exit    => 1,
);

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my @allow = split /\s+/, ($args->{prohibit_postfix_controls}->{allow} || '');

    my @flowcontrol = split /\s+/, ($args->{prohibit_postfix_controls}->{flowcontrol} || '');
    if (@flowcontrol) {
        undef %flow_control_statements; # override
        for my $flowcontrol (@flowcontrol) {
            $flow_control_statements{$flowcontrol} = 1;
        }
    }

    my @violations;
    my $is_postfix = 0;
    for (my $i = 0, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};
        $token_data = $token->{data};

        if ($token_type == SEMI_COLON || $token_type == LEFT_BRACE || $token_type == RIGHT_BRACE) {
            $is_postfix = 0;
            next;
        }

        if ($is_postfix && $control_statement_tokens{$token_type}) {
            if (any {$_ eq $token_data} @allow) {
                next;
            }

            push @violations, {
                filename => $file,
                line     => $token->{line},
                description => sprintf(DESC, $token_data),
                explanation => EXPL->{$token_type},
                policy => __PACKAGE__,
            };
            next;
        }

        if (
            $token_type == BUILTIN_FUNC ||
            $token_type == KEY          ||
            $token_type == POINTER      ||
            $like_flow_control_function_tokens{$token_type}
        ) {
            if (
                $token_type == POINTER ||
                $like_flow_control_function_tokens{$token_type} ||
                $flow_control_statements{$token_data}
            ) {
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};
                    if (
                        $token_type == SEMI_COLON ||
                        $token_type == LEFT_BRACE ||
                        $control_statement_tokens{$token_type}
                    ) {
                        last;
                    }
                }
            }
            next;
        }

        $is_postfix = 1; # other tokens has came
    }

    return \@violations;
}

1;

