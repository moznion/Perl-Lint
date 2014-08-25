requires 'perl', '5.010001';
requires 'Carp';
requires 'Compiler::Lexer', '0.19';
requires 'feature';
requires 'parent';
requires 'List::Util', '1.38';
requires 'String::CamelCase';
requires 'B::Keywords';
requires 'Email::Address';
requires 'Regexp::Parser';
requires 'Module::Load';
requires 'Module::Pluggable';

on configure => sub {
    requires 'Module::Build::Tiny', '0.035';
};

on test => sub {
    requires 'Test::More', '0.98';
    requires 'File::Temp';
    requires 'Test::Base::Less';
    requires 'Capture::Tiny';
};

on develop => sub {
    requires 'Test::Perl::Critic';
    requires 'Pod::Usage';
    requires 'autodie';
};
