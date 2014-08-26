use strict;
use warnings;
use utf8;
use Perl::Lint::Filter::LikePerlCritic::Brutal;
use Perl::Lint::Filter::LikePerlCritic::Cruel;
use Perl::Lint::Filter::LikePerlCritic::Harsh;
use Perl::Lint::Filter::LikePerlCritic::Stern;
use Perl::Lint::Filter::LikePerlCritic::Gentle;

use Test::More;

subtest 'Brutal ok' => sub {
    is scalar @{Perl::Lint::Filter::LikePerlCritic::Brutal->filter}, 0;
};

subtest 'Cruel ok' => sub {
    is scalar @{Perl::Lint::Filter::LikePerlCritic::Cruel->filter}, 22;
};

subtest 'Harsh ok' => sub {
    is scalar @{Perl::Lint::Filter::LikePerlCritic::Harsh->filter}, 49;
};

subtest 'Stern ok' => sub {
    is scalar @{Perl::Lint::Filter::LikePerlCritic::Stern->filter}, 93;
};

subtest 'Gentle ok' => sub {
    is scalar @{Perl::Lint::Filter::LikePerlCritic::Gentle->filter}, 125;
};

done_testing;

