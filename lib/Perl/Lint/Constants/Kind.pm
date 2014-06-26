package Perl::Lint::Constants::Kind;
use strict;
use warnings;
use Compiler::Lexer::Constants;
use parent qw/Exporter/;

our @EXPORT = qw(
    KIND_CTRL
    KIND_DECL
    KIND_OP
    KIND_STMT
    KIND_STMT_END
);

use constant {
    KIND_CTRL => Compiler::Lexer::Kind::T_Control,
    KIND_DECL => Compiler::Lexer::Kind::T_Decl,
    KIND_OP   => Compiler::Lexer::Kind::T_Operator,
    KIND_STMT => Compiler::Lexer::Kind::T_Stmt,
    KIND_STMT_END => Compiler::Lexer::Kind::T_StmtEnd,
};

1;

