package Perl::Lint::Constants::Kind;
use strict;
use warnings;
use Compiler::Lexer::Constants;
use parent qw/Exporter/;

our @EXPORT = qw(
    KIND_DECL
    KIND_STMT
);

use constant {
    KIND_DECL => Compiler::Lexer::Kind::T_Decl,
    KIND_STMT => Compiler::Lexer::Kind::T_Stmt,
};

1;

