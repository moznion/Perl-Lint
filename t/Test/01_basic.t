use strict;
use warnings;
use utf8;
use Test::Builder::Tester;
use Test::Perl::Lint;

test_out(
    'not ok 1 - Test::Perl::Lint for t/Test/resources/c_style_loop.pl',
    'ok 2 - Test::Perl::Lint for t/Test/resources/no_package_scoped_version.pl',
);

all_policies_ok({
    targets => ['t/Test/resources'],
    ignore_files => ['t/Test/resources/should_be_ignore.pl'],
    filter => ['LikePerlCritic::Stern'],
    ignore_policies => ['Modules::RequireVersionVar'],
});

test_test (name => 'testing all_policies_ok()', skip_err => 1);

done_testing;

