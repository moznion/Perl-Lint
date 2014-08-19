use strict;
use warnings;
use utf8;
use Module::Pluggable;
use Perl::Lint;

use Test::More;

subtest 'Should success filtering policies' => sub {
    Module::Pluggable->import(
        search_path => 'Perl::Lint::Policy',
        require     => 1,
        inner       => 0,
    );
    my @site_policies = plugins(); # Exported by Module::Pluggable

    my $linter = Perl::Lint->new({
        ignore => [
            'BuiltinFunctions::ProhibitBooleanGrep',
            'Objects::IndirectSyntax'
        ],
    });

    is scalar(@site_policies) - 2, scalar(@{$linter->{site_policies}});
};

subtest 'Should die when it gives invalid type to `ignore`' => sub {
    eval {
        my $linter = Perl::Lint->new({
            ignore => 'BuiltinFunctions::ProhibitBooleanGrep',
        });
    };
    like $@, qr/`ignore` must be array reference/;
};

done_testing;

