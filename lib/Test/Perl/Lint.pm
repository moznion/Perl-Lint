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

our $VERSION = "0.22";

our @EXPORT = (@test_more_exports, qw/all_policies_ok/);

sub all_policies_ok {
    local $Test::Builder::Level = $Test::Builder::Level + 2;

    my ($args) = @_;

    my $targets = $args->{targets} // Carp::croak "Targets must not be empty";
    my $ignore_files = $args->{ignore_files};

    if (defined $targets && ref $targets ne 'ARRAY') {
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
    for my $target (@$targets) {
        if (-d $target) {
            path($target)->visit(sub {
                my ($path) = @_;
                if ($path->is_file) {
                    my $path_string = $path->stringify;
                    if (!grep {$_ eq $path_string} @$ignore_files) {
                        push @paths, $path_string;
                    }
                }
            }, {recurse => 1});
        }
        elsif (-f $target) {
            if (!grep {$_ eq $target} @$ignore_files) {
                push @paths, $target;
            }
        }
        else {
            Carp::carp "'$target' doesn't exist";
        }
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

__END__

=encoding utf-8

=head1 NAME

Test::Perl::Lint - A testing module to analyze your Perl code with L<Perl::Lint>

=head1 SYNOPSIS

    use Test::Perl::Lint;

    all_policies_ok({
        targets => ['lib', 'script/bar.pl'],
        ignore_files => ['lib/Foo/Buz.pm', 'lib/Foo/Qux.pm'],
        filter => ['LikePerlCritic::Stern'],
        ignore_policies => ['Modules::RequireVersionVar'],
    });

=head1 DESCRIPTION

A testing module to analyze your Perl code with L<Perl::Lint>.

=head1 FUNCTIONS

=over 4

=item * C<all_policies_ok($args:HASHREF)>

This function tests your codes whether they conform to the policies.
C<$args> accepts following fields;

=over 8

=item targets (ARRAYREF)

THIS FIELD IS ESSENTIAL.

Specify targets to test.
If you specify directory as an item, this function checks the all of
files which are contained in that directory.

=item ignore_files (ARRAYREF)

Specify files to exclude from testing target.

=item filter (ARRAYREF)

Apply Perl::Lint filters.

=item ignore_policies (ARRAYREF)

Specify policies to ignore violations.

=back

=back

=head1 SEE ALSO

L<Perl::Lint>

=head1 LICENSE

Copyright (C) moznion.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

moznion E<lt>moznion@gmail.comE<gt>

=cut

