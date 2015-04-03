package Perl::Lint;
use 5.010001;
use strict;
use warnings;
use Carp ();
use Compiler::Lexer;
use Module::Pluggable;
use Module::Load;

our $VERSION = "0.21";

sub new {
    my ($class, $args) = @_;

    my @ignores;

    if (my $ignores = $args->{ignore}) {
        if (ref $ignores ne 'ARRAY') {
            Carp::croak "`ignore` must be array reference";
        }

        push @ignores, map {"Perl::Lint::Policy::$_"} @$ignores;
    }

    if (my $filters = $args->{filter}) {
        if (ref $filters ne 'ARRAY') {
            Carp::croak "`filter` must be array reference";
        }

        for my $filter (@$filters) {
            my $filter_package = "Perl::Lint::Filter::$filter";
            load $filter_package;

            push @ignores, map {"Perl::Lint::Policy::$_"} @{$filter_package->filter};
        }
    }

    Module::Pluggable->import(
        search_path => 'Perl::Lint::Policy',
        require     => 1,
        inner       => 0,
        except      => [@ignores],
    );
    my @site_policies = plugins(); # Exported by Module::Pluggable

    # TODO add mechanism to add extend policies

    bless {
        args => $args,
        site_policies => \@site_policies,
    }, $class;
}

sub lint {
    my ($self, $files) = @_;

    my @files = ($files); # when scalar value
    if (my $ref = ref $files) {
        if ($ref ne 'ARRAY') {
            Carp::croak("Argument of files expects scalar value or array reference");
        }
        @files = @$files;
    }

    my @violations;
    for my $file (@files) {
        open my $fh, '<', $file or die "Cannnot open $file: $!";
        my $src = do { local $/; <$fh> };

        push @violations, @{$self->_lint($src, $file)};
    }

    return \@violations;
}

sub lint_string {
    my ($self, $src) = @_;

    return $self->_lint($src);
}

sub _lint {
    my ($self, $src, $file) = @_;

    if (!defined $src || $src eq '') {
        return [];
    }

    my $args = $self->{args};

    my $lexer = Compiler::Lexer->new($file);
    my $tokens = $lexer->tokenize($src);

    # list `no lint` lines
    # TODO improve performance
    my %no_lint_lines = ();
    my %used_no_lint_lines = ();
    my $line_num = 1;
    for my $line (split /\r?\n/, $src) {
        if ($line =~ /(#.+)?##\s*no\slint(?:\s+(?:qw)?([(][^)]*[)]|"[^"]*"|'[^']*'))?/) {
            next if $1; # Already commented out at before

            my $annotations = {};
            if ($2) {
                my $annotation = substr $2, 1, -1;
                $annotations = {map {$_ => 1} grep {$_} split /[, ]/, $annotation};
            }
            $no_lint_lines{$line_num} = $annotations;
        }
        $line_num++;
    }

    my $prohibit_useless_no_lint_policy;

    my @violations;
    for my $policy (@{$self->{site_policies}}) {
        if ($policy eq 'Perl::Lint::Policy::Miscellanea::ProhibitUselessNoLint') {
            $prohibit_useless_no_lint_policy = $policy;
            next;
        }

        if ($policy eq 'Perl::Lint::Policy::Miscellanea::ProhibitUnrestrictedNoLint') {
            push @violations, @{$policy->evaluate($file, $tokens, $src, $args, \%no_lint_lines)};
            next;
        }


        for my $violation (@{$policy->evaluate($file, $tokens, $src, $args)}) {
            my $violation_line = $violation->{line};
            my $no_lint = $no_lint_lines{$violation_line};
            if (!$no_lint || (keys %$no_lint > 0 && !$no_lint->{(split /::/, $violation->{policy})[-1]})) {
                push @violations, $violation;
            }
            $used_no_lint_lines{$violation_line} = 1;
        }
    }

    if ($prohibit_useless_no_lint_policy) {
        push @violations,
            @{$prohibit_useless_no_lint_policy->evaluate($file, \%no_lint_lines, \%used_no_lint_lines)};
    }

    return \@violations;
}

1;

__END__

=encoding utf-8

=head1 NAME

Perl::Lint - Yet Another Perl Source Code Linter

=head1 SYNOPSIS

    use Perl::Lint;

    my $linter = Perl::Lint->new;
    my $target_files = [qw(foo/bar.pl buz.pm)];
    my $violations   = $linter->lint($target_files);

=head1 DESCRIPTION

Perl::Lint is the yet another source code linter for perl.

=head1 AIMS

Development of this module aims to create a fast and flexible static analyzer for Perl5 that has compatibility with Perl::Critic

Please see also L<http://news.perlfoundation.org/2014/03/grant-proposal-perllint---yet.html>.

=head1 METHODS

=over 4

=item * C<< $linter->lint($target_files:SCALAR or ARRAYREF, $args:HASHREF) >>

C<lint> checks the violations of target files. It can export.
On default, this function checks the all of policies that are in C<Perl::Lint::Policy::*>.

=back

=head1 PERFORMANCE

Benchmark script: L<https://github.com/moznion/Perl-Lint/blob/master/author/benchmark_lint_vs_critic.pl>.

                   Rate Perl::Critic   Perl::Lint
    Perl::Critic 20.6/s           --         -78%
    Perl::Lint   92.0/s         348%           --

=head1 SEE ALSO

L<Perl::Critic>

=head1 LICENSE

Copyright (C) moznion.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

moznion E<lt>moznion@gmail.comE<gt>

=cut

