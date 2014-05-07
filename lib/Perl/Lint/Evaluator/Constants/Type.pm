package Perl::Lint::Evaluator::Constants::Type;
use strict;
use warnings;
use Compiler::Lexer::Constants;
use parent qw/Exporter/;

our @EXPORT = qw(
    VAR_DECL OUR_DECL
    VAR CODE_VAR ARRAY_VAR HASH_VAR
    GLOBAL_VAR GLOBAL_ARRAY_VAR GLOBAL_HAHS_VAR
    LOCAL_VAR LOCAL_ARRAY_VAR LOCAL_HASH_VAR
    SEMI_COLON
    ASSIGN
    LEFT_BRACE
    RIGHT_PAREN
    KEY
    IF_STATEMENT UNLESS_STATEMENT FOR_STATEMENT FOREACH_STATEMENT WHILE_STATEMENT
);

use constant {
    VAR_DECL   => Compiler::Lexer::TokenType::T_VarDecl,
    OUR_DECL   => Compiler::Lexer::TokenType::T_OurDecl,

    VAR       => Compiler::Lexer::TokenType::T_Var,
    CODE_VAR  => Compiler::Lexer::TokenType::T_CodeVar,
    ARRAY_VAR => Compiler::Lexer::TokenType::T_ArrayVar,
    HASH_VAR  => Compiler::Lexer::TokenType::T_HashVar,

    GLOBAL_VAR       => Compiler::Lexer::TokenType::T_GlobalVar,
    GLOBAL_ARRAY_VAR => Compiler::Lexer::TokenType::T_GlobalArrayVar,
    GLOBAL_HAHS_VAR  => Compiler::Lexer::TokenType::T_GlobalHashVar,

    LOCAL_VAR       => Compiler::Lexer::TokenType::T_LocalVar,
    LOCAL_ARRAY_VAR => Compiler::Lexer::TokenType::T_LocalArrayVar,
    LOCAL_HASH_VAR  => Compiler::Lexer::TokenType::T_LocalHashVar,

    IF_STATEMENT      => Compiler::Lexer::TokenType::T_IfStmt,
    UNLESS_STATEMENT  => Compiler::Lexer::TokenType::T_UnlessStmt,
    WHILE_STATEMENT   => Compiler::Lexer::TokenType::T_WhileStmt,
    FOR_STATEMENT     => Compiler::Lexer::TokenType::T_ForStmt,
    FOREACH_STATEMENT => Compiler::Lexer::TokenType::T_ForeachStmt,

    LEFT_BRACE  => Compiler::Lexer::TokenType::T_LeftBrace,
    RIGHT_PAREN => Compiler::Lexer::TokenType::T_RightParenthesis,

    KEY => Compiler::Lexer::TokenType::T_Key,

    SEMI_COLON => Compiler::Lexer::TokenType::T_SemiColon,
    ASSIGN     => Compiler::Lexer::TokenType::T_Assign,
};

1;

