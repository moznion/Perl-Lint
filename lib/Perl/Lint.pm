package Perl::Lint;
use 5.008005;
use strict;
use warnings;
use Carp ();
use Compiler::Lexer;
use Module::Pluggable;
use parent "Exporter";
our @EXPORT_OK = qw/lint/;

our $VERSION = "0.01_01";

sub lint {
    my ($files, $args) = @_;

    my @files = ($files); # when scalar value
    if (my $ref = ref $files) {
        if ($ref ne 'ARRAY') {
            Carp::croak("Argument of files expects scalar value or array reference");
        }
        @files = @$files;
    }

    # TODO to be more pluggable!
    Module::Pluggable->import(
        search_path => 'Perl::Lint::Policy',
        require     => 1,
        inner       => 0
    );
    my @site_policy_names = plugins(); # Exported by Module::Pluggable

    my @violations;
    for my $file (@files) {
        my ($tokens, $src) = _tokenize($file);

        for my $policy (@site_policy_names) {
            push @violations, @{$policy->evaluate($file, $tokens, $src, $args)};
        }
    }

    return \@violations;
}

sub _tokenize {
    my ($file) = @_;
    open my $fh, '<', $file or die "Cannnot open $file: $!";
    my $src = do { local $/; <$fh> };

    my $lexer = Compiler::Lexer->new($file);
    my $tokens = $lexer->tokenize($src);

    return ($tokens, $src);
}

1;
__END__

=encoding utf-8

=head1 NAME

Perl::Lint - Yet Another Perl Source Code Linter

=head1 SYNOPSIS

    use Perl::Lint qw(lint);

    my $target_files = [qw(foo/bar.pl buz.pm)];
    my $violations   = lint($target_files);

=head1 DESCRIPTION

Perl::Lint is the yet another source code linter for perl.

B<THIS IS A DEVELOPMENT RELEASE. API MAY CHANGE WITHOUT NOTICE>

B<PLEASE DO NOT BELIEVE THE RESULT OF THIS MODULE YET.>

=head1 AIMS

Development of this module aims to create a fast and flexible static analyzer for Perl5 that has compatibility with Perl::Critic

Please see also L<http://news.perlfoundation.org/2014/03/grant-proposal-perllint---yet.html>.

=head1 FUNCTIONS

=over 4

=item * C<lint($target_files:SCALAR or ARRAYREF, $args:HASHREF)>

C<lint> checks the violations of target files. It can export.
On default, this function checks the all of policies that are in C<Perl::Lint::Policy::*>.

=back

=head1 SEE ALSO

L<Perl::Critic>

=head1 LICENSE

Copyright (C) moznion.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

moznion E<lt>moznion@gmail.comE<gt>

=cut

