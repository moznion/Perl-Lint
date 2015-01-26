requires 'perl', '5.010001';
requires 'Carp';
requires 'Compiler::Lexer', '0.21';
requires 'feature';
requires 'parent';
requires 'List::Util', '1.41';
requires 'List::MoreUtils', '0.33';
requires 'String::CamelCase';
requires 'B::Keywords';
requires 'Email::Address';
requires 'Module::Load';
requires 'Module::Pluggable';
requires 'List::Flatten';
requires 'Test::Deep::NoTest';
requires 'Regexp::Lexer', '0.04';

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

