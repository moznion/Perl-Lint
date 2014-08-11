package Perl::Lint::Policy::Modules::RequireFilenameMatchesPackage;
use strict;
use warnings;
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

use constant {
    DESC => 'Package declaration must match filename',
    EXPL => 'Correct the filename or package statement',
};

sub evaluate {
    my ($class, $realfile, $tokens, $src, $args) = @_;

    if ($src =~ /\A#!/) { # for exempt
        return [];
    }

    # Determine the filename with considering directive
    my $file;
    my @src_rows = split /\r?\n/, $src;
    my $row = 0;
    my $directive_declared_row = 0;
    for my $src_row (@src_rows) {
        $row++;
        if ($src_row =~ /\A#line\s\d+\s(.+)\Z/) {
            if ($file) {
                return [{
                    filename => $realfile,
                    line     => $row,
                    description => DESC,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                }];
            }
            ($file = $1) =~ s/['"]//g;
            $directive_declared_row = $row;
        }
    }
    $file ||= $realfile;

    my @violations;
    my @paths;
    for (my $i = 0, my $next_token, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $next_token = $tokens->[$i+1];
        $token_type = $token->{type};
        $token_data = $token->{data};
        if ($token_type == PACKAGE) {
            if ($next_token->{type} == CLASS) {
                push @paths, {
                    path => "$next_token->{data}",
                    line => $token->{line},
                };
                next;
            }

            my $path = '';
            for ($i++; my $token = $tokens->[$i]; $i++) {
                my $token_type = $token->{type};
                if ($token_type == NAMESPACE) {
                    $path .= $token->{data};
                }
                elsif ($token_type == NAMESPACE_RESOLVER) {
                    $path .= '/';
                }
                else {
                    push @paths, {
                        path => $path,
                        line => $token->{line},
                    };
                    last;
                }
            }
        }
    }

    for my $p (@paths) {
        my $is_directive_declared_after = 0;
        my $should_be_no_error = 0;

        my $path = $p->{path};
        my $package_declared_line = $p->{line};

        if ($directive_declared_row && $package_declared_line < $directive_declared_row) {
            $is_directive_declared_after = 1;
        }

        my $last_path = @{[split(/\//, $path)]}[-1];
        (my $module_name = $path) =~ s!/!-!;

        if ($path eq 'main' && !$is_directive_declared_after) {
            last;
        }
        elsif ($file !~ m!/!) {
            my $last_path = @{[split(/\//, $path)]}[-1] || '';
            if ($file =~ /$last_path\.p[ml]/) {
                $should_be_no_error = 1;
            }
        }
        elsif ($file =~ /$path\.p[ml]/) {
            $should_be_no_error = 1;
        }
        elsif ($file =~ m!$module_name(?:-\d[\d\.]*?\d)?/$last_path!) {
            $should_be_no_error = 1;
        }
        elsif ($file =~ m![A-Z]\w*-\d[\d\.]*\d/$last_path!) {
            $should_be_no_error = 1;
        }

        if (
            !$should_be_no_error ||
            ($should_be_no_error && $is_directive_declared_after)
        ) {
            push @violations, {
                filename => $realfile,
                line     => $package_declared_line,
                description => DESC,
                explanation => EXPL,
                policy => __PACKAGE__,
            };
        }
    }

    return \@violations;
}

1;

