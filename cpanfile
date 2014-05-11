requires 'perl', '5.008005';
requires 'Compiler::Lexer';
requires 'feature';
requires 'parent';
requires 'List::Util', '1.38';

on configure => sub {
    requires 'Module::Build::Tiny', '0.035';
};

on test => sub {
    requires 'Test::More', '0.98';
    requires 'File::Temp';
    requires 'Test::Base::Less';
};

on develop => sub {
    requires 'Test::Perl::Critic';
};
