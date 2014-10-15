package Perl::Lint::Constants::Type;
use strict;
use warnings;
use Compiler::Lexer::Constants;
use parent qw/Exporter/;

our @EXPORT = qw(
    VAR_DECL OUR_DECL LOCAL_DECL FUNCTION_DECL FORMAT_DECL STATE_DECL
    USE_DECL REQUIRE_DECL
    USED_NAME REQUIRED_NAME
    CALL FUNCTION
    VAR CODE_VAR ARRAY_VAR HASH_VAR
    GLOBAL_VAR GLOBAL_ARRAY_VAR GLOBAL_HASH_VAR
    LOCAL_VAR LOCAL_ARRAY_VAR LOCAL_HASH_VAR
    PROGRAM_ARGUMENT LIBRARY_DIRECTORIES ARGUMENT_ARRAY
    INCLUDE ENVIRONMENT SIGNAL
    SEMI_COLON COMMA ARROW COLON POINTER
    ASSIGN REG_OK REG_NOT
    DOUBLE
    RIGHT_BRACE LEFT_BRACE
    RIGHT_PAREN LEFT_PAREN
    RIGHT_BRACKET LEFT_BRACKET
    KEY METHOD
    STRING RAW_STRING EXEC_STRING VERSION_STRING
    INT
    HERE_DOCUMENT RAW_HERE_DOCUMENT HERE_DOCUMENT_END HERE_DOCUMENT_TAG HERE_DOCUMENT_RAW_TAG
    REG_QUOTE REG_DOUBLE_QUOTE
    REG_DELIM REG_OPT
    REG_EXP REG_EXEC REG_LIST REG_ALL_REPLACE REG_MATCH REG_REPLACE REG_REPLACE_TO REG_REPLACE_FROM REG_DECL
    IF_STATEMENT ELSE_STATEMENT ELSIF_STATEMENT UNLESS_STATEMENT FOR_STATEMENT FOREACH_STATEMENT WHILE_STATEMENT UNTIL_STATEMENT WHEN_STATEMENT
    CONTINUE
    BUILTIN_FUNC GOTO RETURN NEXT LAST REDO
    PACKAGE CLASS NAMESPACE NAMESPACE_RESOLVER
    AND OR ALPHABET_AND ALPHABET_OR ALPHABET_XOR BIT_AND BIT_OR BIT_XOR OR_EQUAL AND_EQUAL EQUAL_EQUAL NOT ALPHABET_NOT NOT_EQUAL
    RIGHT_SHIFT_EQUAL LEFT_SHIFT_EQUAL
    SHORT_SCALAR_DEREFERENCE SHORT_ARRAY_DEREFERENCE SHORT_HASH_DEREFERENCE SHORT_CODE_DEREFERENCE
    THREE_TERM_OP DEFAULT_OP
    DO
    RIGHT_SHIFT LEFT_SHIFT
    GLOB REF PROTOTYPE
    MOD_WORD
    TYPE_STDIN TYPE_STDOUT TYPE_STDERR
    HANDLE HANDLE_DELIM DIAMOND
    LESS LESS_EQUAL GREATER GREATER_EQUAL COMPARE
    STRING_LESS STRING_GREATER STRING_COMPARE STRING_NOT_EQUAL
    STRING_LESS_EQUAL STRING_GREATER_EQUAL
    MUL MOD STRING_ADD STRING_MUL
    SPECIFIC_VALUE SPECIFIC_KEYWORD ARRAY_SIZE
    DEFAULT
    PROTOTYPE
    SCALAR_DEREFERENCE HASH_DEREFERENCE ARRAY_DEREFERENCE ARRAY_SIZE_DEREFERENCE

    POWER_EQUAL ADD_EQUAL MUL_EQUAL AND_BIT_EQUAL SUB_EQUAL DIV_EQUAL
    OR_BIT_EQUAL MOD_EQUAL NOT_BIT_EQUAL DEFAULT_EQUAL STRING_ADD_EQUAL

    PLUSPLUS MINUSMINUS

    SLICE
);

use constant {
    VAR_DECL      => Compiler::Lexer::TokenType::T_VarDecl,
    OUR_DECL      => Compiler::Lexer::TokenType::T_OurDecl,
    LOCAL_DECL    => Compiler::Lexer::TokenType::T_LocalDecl,
    FUNCTION_DECL => Compiler::Lexer::TokenType::T_FunctionDecl,
    FORMAT_DECL   => Compiler::Lexer::TokenType::T_FormatDecl,
    STATE_DECL    => Compiler::Lexer::TokenType::T_StateDecl,

    USE_DECL     => Compiler::Lexer::TokenType::T_UseDecl,
    REQUIRE_DECL => Compiler::Lexer::TokenType::T_RequireDecl,

    USED_NAME     => Compiler::Lexer::TokenType::T_UsedName,
    REQUIRED_NAME => Compiler::Lexer::TokenType::T_RequiredName,

    CALL     => Compiler::Lexer::TokenType::T_Call,
    FUNCTION => Compiler::Lexer::TokenType::T_Function,

    VAR       => Compiler::Lexer::TokenType::T_Var,
    CODE_VAR  => Compiler::Lexer::TokenType::T_CodeVar,
    ARRAY_VAR => Compiler::Lexer::TokenType::T_ArrayVar,
    HASH_VAR  => Compiler::Lexer::TokenType::T_HashVar,

    GLOBAL_VAR       => Compiler::Lexer::TokenType::T_GlobalVar,
    GLOBAL_ARRAY_VAR => Compiler::Lexer::TokenType::T_GlobalArrayVar,
    GLOBAL_HASH_VAR  => Compiler::Lexer::TokenType::T_GlobalHashVar,

    LOCAL_VAR       => Compiler::Lexer::TokenType::T_LocalVar,
    LOCAL_ARRAY_VAR => Compiler::Lexer::TokenType::T_LocalArrayVar,
    LOCAL_HASH_VAR  => Compiler::Lexer::TokenType::T_LocalHashVar,

    PROGRAM_ARGUMENT    => Compiler::Lexer::TokenType::T_ProgramArgument,
    LIBRARY_DIRECTORIES => Compiler::Lexer::TokenType::T_LibraryDirectories,
    ARGUMENT_ARRAY      => Compiler::Lexer::TokenType::T_ArgumentArray,
    INCLUDE             => Compiler::Lexer::TokenType::T_Include,
    ENVIRONMENT         => Compiler::Lexer::TokenType::T_Environment,
    SIGNAL              => Compiler::Lexer::TokenType::T_Signal,

    IF_STATEMENT      => Compiler::Lexer::TokenType::T_IfStmt,
    ELSE_STATEMENT    => Compiler::Lexer::TokenType::T_ElseStmt,
    ELSIF_STATEMENT   => Compiler::Lexer::TokenType::T_ElsifStmt,
    UNLESS_STATEMENT  => Compiler::Lexer::TokenType::T_UnlessStmt,
    WHILE_STATEMENT   => Compiler::Lexer::TokenType::T_WhileStmt,
    FOR_STATEMENT     => Compiler::Lexer::TokenType::T_ForStmt,
    FOREACH_STATEMENT => Compiler::Lexer::TokenType::T_ForeachStmt,
    UNTIL_STATEMENT   => Compiler::Lexer::TokenType::T_UntilStmt,
    WHEN_STATEMENT   => Compiler::Lexer::TokenType::T_WhenStmt,

    CONTINUE => Compiler::Lexer::TokenType::T_Continue,

    BUILTIN_FUNC => Compiler::Lexer::TokenType::T_BuiltinFunc,
    GOTO         => Compiler::Lexer::TokenType::T_Goto,
    RETURN       => Compiler::Lexer::TokenType::T_Return,
    NEXT         => Compiler::Lexer::TokenType::T_Next,
    LAST         => Compiler::Lexer::TokenType::T_Last,
    REDO         => Compiler::Lexer::TokenType::T_Redo,

    RIGHT_BRACE => Compiler::Lexer::TokenType::T_RightBrace,
    LEFT_BRACE  => Compiler::Lexer::TokenType::T_LeftBrace,
    RIGHT_PAREN => Compiler::Lexer::TokenType::T_RightParenthesis,
    LEFT_PAREN  => Compiler::Lexer::TokenType::T_LeftParenthesis,
    RIGHT_BRACKET => Compiler::Lexer::TokenType::T_RightBracket,
    LEFT_BRACKET  => Compiler::Lexer::TokenType::T_LeftBracket,

    METHOD         => Compiler::Lexer::TokenType::T_Method,
    KEY            => Compiler::Lexer::TokenType::T_Key,
    STRING         => Compiler::Lexer::TokenType::T_String,
    RAW_STRING     => Compiler::Lexer::TokenType::T_RawString,
    EXEC_STRING    => Compiler::Lexer::TokenType::T_ExecString,
    VERSION_STRING => Compiler::Lexer::TokenType::T_VersionString,

    INT => Compiler::Lexer::TokenType::T_Int,

    HERE_DOCUMENT         => Compiler::Lexer::TokenType::T_HereDocument,
    RAW_HERE_DOCUMENT     => Compiler::Lexer::TokenType::T_RawHereDocument,
    HERE_DOCUMENT_TAG     => Compiler::Lexer::TokenType::T_HereDocumentTag,
    HERE_DOCUMENT_RAW_TAG => Compiler::Lexer::TokenType::T_HereDocumentRawTag,
    HERE_DOCUMENT_END     => Compiler::Lexer::TokenType::T_HereDocumentEnd,

    REG_QUOTE        => Compiler::Lexer::TokenType::T_RegQuote,
    REG_DOUBLE_QUOTE => Compiler::Lexer::TokenType::T_RegDoubleQuote,

    REG_DELIM => Compiler::Lexer::TokenType::T_RegDelim,
    REG_OPT   => Compiler::Lexer::TokenType::T_RegOpt,

    REG_EXP  => Compiler::Lexer::TokenType::T_RegExp,
    REG_EXEC => Compiler::Lexer::TokenType::T_RegExec,
    REG_LIST => Compiler::Lexer::TokenType::T_RegList,
    REG_MATCH => Compiler::Lexer::TokenType::T_RegMatch,
    REG_REPLACE => Compiler::Lexer::TokenType::T_RegReplace,
    REG_REPLACE_TO => Compiler::Lexer::TokenType::T_RegReplaceTo,
    REG_REPLACE_FROM => Compiler::Lexer::TokenType::T_RegReplaceFrom,
    REG_ALL_REPLACE => Compiler::Lexer::TokenType::T_RegAllReplace,
    REG_DECL => Compiler::Lexer::TokenType::T_RegDecl,

    THREE_TERM_OP => Compiler::Lexer::TokenType::T_ThreeTermOperator,

    DEFAULT_OP => Compiler::Lexer::TokenType::T_DefaultOperator,

    COMMA      => Compiler::Lexer::TokenType::T_Comma,
    SEMI_COLON => Compiler::Lexer::TokenType::T_SemiColon,
    COLON      => Compiler::Lexer::TokenType::T_Colon,
    ARROW      => Compiler::Lexer::TokenType::T_Arrow,
    ASSIGN     => Compiler::Lexer::TokenType::T_Assign,
    REG_OK     => Compiler::Lexer::TokenType::T_RegOK,
    REG_NOT    => Compiler::Lexer::TokenType::T_RegNot,
    POINTER    => Compiler::Lexer::TokenType::T_Pointer,

    DOUBLE => Compiler::Lexer::TokenType::T_Double,

    AND => Compiler::Lexer::TokenType::T_And,
    OR  => Compiler::Lexer::TokenType::T_Or,
    NOT => Compiler::Lexer::TokenType::T_Not,
    ALPHABET_AND => Compiler::Lexer::TokenType::T_AlphabetAnd,
    ALPHABET_OR  => Compiler::Lexer::TokenType::T_AlphabetOr,
    ALPHABET_NOT => Compiler::Lexer::TokenType::T_AlphabetNot,
    ALPHABET_XOR => Compiler::Lexer::TokenType::T_AlphabetXOr,
    BIT_AND => Compiler::Lexer::TokenType::T_BitAnd,
    BIT_OR  => Compiler::Lexer::TokenType::T_BitOr,
    BIT_XOR => Compiler::Lexer::TokenType::T_BitXOr,
    OR_EQUAL => Compiler::Lexer::TokenType::T_OrEqual,
    AND_EQUAL => Compiler::Lexer::TokenType::T_AndEqual,
    EQUAL_EQUAL => Compiler::Lexer::TokenType::T_EqualEqual,
    NOT_EQUAL => Compiler::Lexer::TokenType::T_NotEqual,

    RIGHT_SHIFT_EQUAL => Compiler::Lexer::TokenType::T_RightShiftEqual,
    LEFT_SHIFT_EQUAL  => Compiler::Lexer::TokenType::T_LeftShiftEqual,

    SHORT_SCALAR_DEREFERENCE => Compiler::Lexer::TokenType::T_ShortScalarDereference,
    SHORT_ARRAY_DEREFERENCE  => Compiler::Lexer::TokenType::T_ShortArrayDereference,
    SHORT_HASH_DEREFERENCE   => Compiler::Lexer::TokenType::T_ShortHashDereference,
    SHORT_CODE_DEREFERENCE   => Compiler::Lexer::TokenType::T_ShortCodeDereference,

    PACKAGE   => Compiler::Lexer::TokenType::T_Package,
    CLASS     => Compiler::Lexer::TokenType::T_Class,
    NAMESPACE => Compiler::Lexer::TokenType::T_Namespace,
    NAMESPACE_RESOLVER => Compiler::Lexer::TokenType::T_NamespaceResolver,

    GLOB => Compiler::Lexer::TokenType::T_Glob,
    REF  => Compiler::Lexer::TokenType::T_Ref,
    PROTOTYPE => Compiler::Lexer::TokenType::T_Prototype,

    DO => Compiler::Lexer::TokenType::T_Do,

    RIGHT_SHIFT => Compiler::Lexer::TokenType::T_RightShift,
    LEFT_SHIFT => Compiler::Lexer::TokenType::T_LeftShift,

    MOD_WORD => Compiler::Lexer::TokenType::T_ModWord,

    TYPE_STDIN => Compiler::Lexer::TokenType::T_STDIN, # STDIN is reserved by main::
    TYPE_STDOUT => Compiler::Lexer::TokenType::T_STDOUT, # STDOUT is reserved by main::
    TYPE_STDERR => Compiler::Lexer::TokenType::T_STDERR, # STDERR is reserved by main::

    HANDLE => Compiler::Lexer::TokenType::T_Handle,
    HANDLE_DELIM => Compiler::Lexer::TokenType::T_HandleDelim,
    DIAMOND => Compiler::Lexer::TokenType::T_Diamond,

    LESS => Compiler::Lexer::TokenType::T_Less,
    LESS_EQUAL => Compiler::Lexer::TokenType::T_LessEqual,
    GREATER => Compiler::Lexer::TokenType::T_Greater,
    GREATER_EQUAL => Compiler::Lexer::TokenType::T_GreaterEqual,
    COMPARE => Compiler::Lexer::TokenType::T_Compare,

    STRING_LESS      => Compiler::Lexer::TokenType::T_StringLess,
    STRING_GREATER   => Compiler::Lexer::TokenType::T_StringGreater,
    STRING_COMPARE   => Compiler::Lexer::TokenType::T_StringCompare,
    STRING_NOT_EQUAL => Compiler::Lexer::TokenType::T_StringNotEqual,
    STRING_LESS_EQUAL    => Compiler::Lexer::TokenType::T_StringLessEqual,
    STRING_GREATER_EQUAL => Compiler::Lexer::TokenType::T_StringGreaterEqual,

    MUL => Compiler::Lexer::TokenType::T_Mul,
    MOD => Compiler::Lexer::TokenType::T_Mod,
    STRING_ADD => Compiler::Lexer::TokenType::T_StringAdd,
    STRING_MUL => Compiler::Lexer::TokenType::T_StringMul,

    SPECIFIC_VALUE   => Compiler::Lexer::TokenType::T_SpecificValue,
    SPECIFIC_KEYWORD => Compiler::Lexer::TokenType::T_SpecificKeyword,
    ARRAY_SIZE => Compiler::Lexer::TokenType::T_ArraySize,

    DEFAULT => Compiler::Lexer::TokenType::T_Default,

    PROTOTYPE => Compiler::Lexer::TokenType::T_Prototype,

    SCALAR_DEREFERENCE => Compiler::Lexer::TokenType::T_ScalarDereference,
    HASH_DEREFERENCE   => Compiler::Lexer::TokenType::T_HashDereference,
    ARRAY_DEREFERENCE  => Compiler::Lexer::TokenType::T_ArrayDereference,
    ARRAY_SIZE_DEREFERENCE  => Compiler::Lexer::TokenType::T_ArraySizeDereference,

    POWER_EQUAL   => Compiler::Lexer::TokenType::T_PowerEqual,
    ADD_EQUAL     => Compiler::Lexer::TokenType::T_AddEqual,
    MUL_EQUAL     => Compiler::Lexer::TokenType::T_MulEqual,
    AND_BIT_EQUAL => Compiler::Lexer::TokenType::T_AndBitEqual,
    SUB_EQUAL     => Compiler::Lexer::TokenType::T_SubEqual,
    DIV_EQUAL     => Compiler::Lexer::TokenType::T_DivEqual,
    OR_BIT_EQUAL  => Compiler::Lexer::TokenType::T_OrBitEqual,
    MOD_EQUAL     => Compiler::Lexer::TokenType::T_ModEqual,
    NOT_BIT_EQUAL => Compiler::Lexer::TokenType::T_NotBitEqual,
    DEFAULT_EQUAL => Compiler::Lexer::TokenType::T_DefaultEqual,
    STRING_ADD_EQUAL => Compiler::Lexer::TokenType::T_StringAddEqual,

    PLUSPLUS => Compiler::Lexer::TokenType::T_Inc,
    MINUSMINUS => Compiler::Lexer::TokenType::T_Dec,

    SLICE => Compiler::Lexer::TokenType::T_Slice,
};

1;

