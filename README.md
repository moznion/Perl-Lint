[![Build Status](https://travis-ci.org/moznion/Perl-Lint.png?branch=master)](https://travis-ci.org/moznion/Perl-Lint) [![Coverage Status](https://coveralls.io/repos/moznion/Perl-Lint/badge.png?branch=master)](https://coveralls.io/r/moznion/Perl-Lint?branch=master)
# NAME

Perl::Lint - Yet Another Perl Source Code Linter

# SYNOPSIS

    use Perl::Lint qw(lint);

    my $target_files = [qw(foo/bar.pl buz.pm)];
    my $violations   = lint($target_files);

# DESCRIPTION

Perl::Lint is the yet another source code linter for perl.

__THIS IS A DEVELOPMENT RELEASE. API MAY CHANGE WITHOUT NOTICE__

__PLEASE DO NOT BELIEVE THE RESULT OF THIS MODULE YET.__

# AIMS

Development of this module aims to create a fast and flexible static analyzer for Perl5 that has compatibility with Perl::Critic

Please see also [http://news.perlfoundation.org/2014/03/grant-proposal-perllint---yet.html](http://news.perlfoundation.org/2014/03/grant-proposal-perllint---yet.html).

# FUNCTIONS

- `lint($target_files:SCALAR or ARRAYREF, $args:HASHREF)`

    `lint` checks the violations of target files. It can export.
    On default, this function checks the all of policies that are in `Perl::Lint::Policy::*`.

# SEE ALSO

[Perl::Critic](https://metacpan.org/pod/Perl::Critic)

# LICENSE

Copyright (C) moznion.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

moznion <moznion@gmail.com>
