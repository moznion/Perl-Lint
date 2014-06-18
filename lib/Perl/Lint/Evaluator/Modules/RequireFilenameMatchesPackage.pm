package Perl::Lint::Evaluator::Modules::RequireFilenameMatchesPackage;
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
    my ($class, $file, $tokens, $src, $args) = @_;

    if ($src =~ /\A#!/) { # for exempt
        return [];
    }

    my @violations;
    my $next_token;
    my @paths;
    for (my $i = 0; my $token = $next_token || $tokens->[$i]; $i++) {
        $next_token = $tokens->[$i+1];
        my $token_type = $token->{type};
        my $token_data = $token->{data};
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
        my $path = $p->{path};
        my $package_declared_line = $p->{line};

        if ($path eq 'main') {
            last;
        }

        if ($file !~ m!/!) {
            my $last_path = @{[split(/\//, $path)]}[-1] || '';
            if ($file =~ /$last_path\.p[ml]/) {
                next;
            }
        }

        if ($file =~ /$path\.p[ml]/) {
            next;
        }

        my $last_path = @{[split(/\//, $path)]}[-1];
        (my $module_name = $path) =~ s!/!-!;
        if ($file =~ m!$module_name(?:-\d[\d\.]*?\d)?/$last_path!) {
            next;
        }

        if ($file =~ m![A-Z]\w*-\d[\d\.]*\d/$last_path!) {
            next;
        }

        push @violations, {
            filename => $file,
            line     => $package_declared_line,
            description => DESC,
            explanation => EXPL,
        };
    }

    return \@violations;
    # (my $filename_without_extension = $file) =~ s/\.p[ml]\Z//;
    # my $file_only = @{[split(/\//, $file)]}[-1];
    # # my @paths = split(/\//, $path);
    # if ($filename_without_extension !~ $re_with_module_name) {
    # }
    # if ($path !~ /$filename_without_extension\Z/ && $filename_without_extension !~ /$path\Z/) {
    # # if ($file_only !~ /\A$last_path.p[ml]\Z/ && $file !~ /$path.p[ml]\Z/) {
    # }
}

1;

