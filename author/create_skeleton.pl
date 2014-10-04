#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use autodie;
use FindBin;
use Pod::Usage;
use File::Path qw/mkpath/;
use String::CamelCase qw(decamelize);

my ($category, $polycy) = @ARGV;
if (!$category || !$polycy) {
    pod2usage(0);
}

my $project_root = "$FindBin::Bin/..";

{
    my $category_dir = "$project_root/lib/Perl/Lint/Policy/$category";
    mkpath($category_dir);

    my $pm_file = "$category_dir/$polycy.pm";

    if (-f $pm_file) {
        print "[WARN] '$pm_file' has already existed\n";
    }
    else {
        open my $fh, '>', $pm_file or die "Cannot open $pm_file: $!";
        print $fh <<"...";
package Perl::Lint::Policy::$category\:\:$polycy;
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
    my (\$class, \$file, \$tokens, \$src, \$args) = \@_;

    my \@violations;
    for (my \$i = 0, my \$token_type; my \$token = \$tokens->[\$i]; \$i++) {
        \$token_type = \$token->{type};

        # push \@violations, {
        #     filename => \$file,
        #     line     => \$token->{line},
        #     description => DESC,
        #     explanation => EXPL,
        #     policy => __PACKAGE__,
        # };
    }

    return \\\@violations;
}

1;

...
        print "[INFO] Created '$pm_file'\n";
    }

}

{
    my $test_category_dir = "$project_root/t/Policy/$category";
    mkpath($test_category_dir);

    my $test_file = "$test_category_dir/" . decamelize($polycy) . '.t';

    if (-f $test_file) {
        print "[WARN] '$test_file' has already existed\n";
    }
    else {
        open my $fh, '>', $test_file or die "Cannot open $test_file: $!";
        print $fh <<"...";
use strict;
use warnings;
use Perl::Lint::Policy::$category\:\:$polycy;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my \$class_name = '$category\:\:$polycy';

filters {
    params => [qw/eval/],
};

for my \$block (blocks) {
    my \$violations = fetch_violations(\$class_name, \$block->input, \$block->params);
    is scalar \@\$violations, \$block->failures, \$block->dscr;
}

done_testing;

__DATA__

...
        print "[INFO] Created '$test_file'\n";
    }
}

__END__

=head1 NAME

create_skeleton.pl - create skeletons to evaluate for Perl::Lint

=head1 SYNOPSIS

    $ create_skeleton.pl <Category> <PolycyName>

=head1 AUTHOR

moznion

=cut
