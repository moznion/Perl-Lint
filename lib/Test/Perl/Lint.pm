package Test::Perl::Lint;
use strict;
use warnings;
use utf8;
use parent qw/Test::Builder::Module/;

my @test_more_exports;
BEGIN { @test_more_exports = (qw/done_testing/) }
use Test::More import => \@test_more_exports;
use Carp ();
use Path::Tiny 0.068 qw/path/;
use Perl::Lint;

our @EXPORT = (@test_more_exports, qw/all_policies_ok/);

sub all_policies_ok {
    local $Test::Builder::Level = $Test::Builder::Level + 2;

    my ($args) = @_;

    my $target_dirs = $args->{target_dir} // Carp::croak "Target directories must not be empty";
    my $ignore_files = $args->{ignore_files};

    if (defined $target_dirs && ref $target_dirs ne 'ARRAY') {
        Carp::croak 'Target directories are must be an array reference';
    }

    if (defined $ignore_files && ref $ignore_files ne 'ARRAY') {
        Carp::croak 'Ignore files are must be an array reference';
    }

    my $linter = Perl::Lint->new({
        ignore => $args->{ignore_policies},
        filter => $args->{filter},
    });

    my @paths;
    for my $dir (@$target_dirs) {
        path($dir)->visit(sub {
            my ($path) = @_;
            if ($path->is_file) {
                my $path_string = $path->stringify;
                if (!grep {$_ eq $path_string} @$ignore_files) {
                    push @paths, $path_string;
                }
            }
        }, {recurse => 1});
    }
    @paths = sort {$a cmp $b} @paths;

    for my $path_string (@paths) {
        my $violations = $linter->lint($path_string);
        if (scalar @$violations == 0) {
            Test::More::pass(__PACKAGE__ . ' for ' . $path_string);
        }
        else {
            my $package = __PACKAGE__;
            my $error_msg = <<"...";

$package found these violations in "$path_string":
...

            for my $violation (@$violations) {
                my $explanation = $violation->{explanation};
                if (ref $explanation eq 'ARRAY') {
                    $explanation = 'See page ' . join(', ', @$explanation) . ' of PBP';
                }
                $error_msg .= <<"...";
$violation->{description} at line $violation->{line}. $explanation.
...
            }

            Test::More::ok(0, "$package for $path_string") or Test::More::diag($error_msg);
        }
    }

    return;
}

1;

