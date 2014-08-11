package Perl::Lint;
use 5.008005;
use strict;
use warnings;
use Carp ();
use Compiler::Lexer;
use Module::Pluggable;
use parent "Exporter";
our @EXPORT_OK = qw/lint/;

our $VERSION = "0.01";

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

Perl::Lint - It's new $module

=head1 SYNOPSIS

    use Perl::Lint;

=head1 DESCRIPTION

Perl::Lint is ...

=head1 LICENSE

Copyright (C) moznion.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

moznion E<lt>moznion@gmail.comE<gt>

=cut

