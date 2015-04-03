[![Build Status](https://travis-ci.org/moznion/Perl-Lint.svg?branch=master)](https://travis-ci.org/moznion/Perl-Lint) [![Coverage Status](https://img.shields.io/coveralls/moznion/Perl-Lint/master.svg)](https://coveralls.io/r/moznion/Perl-Lint?branch=master)
# NAME

Perl::Lint - Yet Another Perl Source Code Linter

# SYNOPSIS

    use Perl::Lint;

    my $linter = Perl::Lint->new;
    my $target_files = [qw(foo/bar.pl buz.pm)];
    my $violations   = $linter->lint($target_files);

# DESCRIPTION

Perl::Lint is the yet another source code linter for perl.

# AIMS

Development of this module aims to create a fast and flexible static analyzer for Perl5 that has compatibility with Perl::Critic

Please see also [http://news.perlfoundation.org/2014/03/grant-proposal-perllint---yet.html](http://news.perlfoundation.org/2014/03/grant-proposal-perllint---yet.html).

# METHODS

- `$linter->lint($target_files:SCALAR or ARRAYREF, $args:HASHREF)`

    `lint` checks the violations of target files. It can export.
    On default, this function checks the all of policies that are in `Perl::Lint::Policy::*`.

# PERFORMANCE

Benchmark script: [https://github.com/moznion/Perl-Lint/blob/master/author/benchmark\_lint\_vs\_critic.pl](https://github.com/moznion/Perl-Lint/blob/master/author/benchmark_lint_vs_critic.pl).

                   Rate Perl::Critic   Perl::Lint
    Perl::Critic 20.6/s           --         -78%
    Perl::Lint   92.0/s         348%           --

# SEE ALSO

[Perl::Critic](https://metacpan.org/pod/Perl::Critic)

# LICENSE

Copyright (C) moznion.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

moznion <moznion@gmail.com>
