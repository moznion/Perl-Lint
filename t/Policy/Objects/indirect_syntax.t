#!perl

use strict;
use warnings;
use utf8;
use Perl::Lint;
use Perl::Lint::Policy::Objects::IndirectSyntax;
use t::Policy::Util qw/fetch_violations/;
use Test::More;

my $class_name = 'Objects::IndirectSyntax';

subtest 'basic passes' => sub {
    my $src = <<'...';
Foo->new;
Foo->new();
Foo->new( bar => 'baz' );

$foo->new;

{$foo}->new;
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 0;
};

subtest 'basic failures' => sub {
    my $src = <<'...';
new Foo;
new Foo();
new Foo( bar => 'baz' );

new $foo;

new {$foo};

my $bar;
new $bar;
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 6;
    # TODO
};

subtest 'specify name of subroutine to check' => sub {
    my $src = <<'...';
create Foo;
create Foo();
create Foo( bar => 'baz' );
create $foo;
create {$foo};

construct Foo;
construct Foo();
construct Foo( bar => 'baz' );
construct $foo;
construct {$foo};

delete Foo;
delete Foo();
delete Foo( bar => 'baz' );
delete $foo;
delete {$foo};
...

    subtest 'unchecked indirect objects' => sub {
        my $violations = fetch_violations($class_name, $src);
        is scalar @$violations, 0;
    };

    subtest 'checked indirect objects' => sub {
        my $arg = {
            indirect_syntax => {
                forbid => ['create', 'construct']
            }
        };
        my $violations = fetch_violations($class_name, $src, $arg);
        is scalar @$violations, 10;
        # TODO
    }
};

done_testing;

