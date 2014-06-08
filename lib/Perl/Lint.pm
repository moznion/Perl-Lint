package Perl::Lint;
use 5.008005;
use strict;
use warnings;
use Compiler::Lexer;
use parent "Exporter";
our @EXPORT_OK = qw/lint/;

our $VERSION = "0.01";

sub lint {
    my ($file) = @_;

    my ($tokens, $src) = _tokenize($file);

    my $violations = [];
    return $violations;
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

