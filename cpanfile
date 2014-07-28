requires 'perl', '5.008005';
requires 'Compiler::Lexer', '0.19';
requires 'feature';
requires 'parent';
requires 'List::Util', '1.38';
requires 'String::CamelCase';
requires 'B::Keywords';
requires 'Email::Address';

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
    requires 'Pod::Usage';
    requires 'autodie';
};
