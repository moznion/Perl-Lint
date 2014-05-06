requires 'perl', '5.008005';
requires 'Compiler::Lexer';
requires 'feature';
requires 'parent';

on configure => sub {
    requires 'Module::Build::Tiny', '0.035';
};

on test => sub {
    requires 'Test::More', '0.98';
};

