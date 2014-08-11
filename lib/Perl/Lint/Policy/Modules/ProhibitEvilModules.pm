package Perl::Lint::Policy::Modules::ProhibitEvilModules;
use strict;
use warnings;
use List::Util qw/any/;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'The names of or patterns for modules to forbid',
    EXPL => 'Find an alternative module',
};

# TODO Should use Module::Adviser?
use constant EVILS => [qw/
    Class::ISA
    Pod::Plainer
    Shell
    Switch
/];

sub evaluate {
    my ($class, $file, $tokens, $src, $args) = @_;

    my $modules_arg = $args->{prohibit_evil_modules}->{modules} || '';
    $modules_arg =~ s/{.*?}//g;
    my @evils = split(/ /, $modules_arg);

    my $modules_file = $args->{prohibit_evil_modules}->{modules_file};
    if ($modules_file) {
        open my $fh, '<', $modules_file;
        my $content = do { local $/; <$fh> };
        push @evils, ($content =~ /^\s*?([^ \n\r\f\t#]+)/gm);
    }

    my @evils_re = map {m!/(.+?)/!; $1} @evils;

    my @violations;
    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type = $token->{type};
        if ($token_type == USE_DECL) {
            my $used_name = '';
            for ($i++; my $token = $tokens->[$i]; $i++) {
                my $token_type = $token->{type};
                if (
                    $token_type != NAMESPACE &&
                    $token_type != NAMESPACE_RESOLVER &&
                    $token_type != USED_NAME
                ) {
                    last;
                }
                $used_name .= $token->{data};
            }

            if (
                any {$used_name eq $_} (@{+EVILS}, @evils) or
                any {$_ && $used_name =~ /$_/} @evils_re
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
    }

    return \@violations;
}

1;

