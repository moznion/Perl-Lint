package Perl::Lint::RegexpParser;
use strict;
use warnings;
use utf8;
use parent "Regexp::Parser";

sub new {
    my ($class) = @_;

    my $parser = $class->SUPER::new();

    # XXX workaround
    for my $escape_char (qw/Q E u U v V F g h H k K l L N o R/) {
        $parser->add_handler("\\$escape_char" => sub {
            my ($S, $cc) = @_;
            $S->warn($class->SUPER::RPe_BADESC, $escape_char, " in character class") if $cc;
            return $S->force_object(anyof_char => $escape_char) if $cc;
            return $S->object(exact => "\\$escape_char"); # XXX not sure about object class
        });
    }

    return $parser;
}

sub walker {
    my $self = shift;

    # XXX workaround
    if (! $self->{tree} && ${$self->{regex}} eq '') {
        return sub {};
    }

    return $self->SUPER::walker(@_);
}

1;

