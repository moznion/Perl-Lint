package Perl::Lint::Policy::Variables::ProhibitAugmentedAssignmentInDeclaration;
use strict;
use warnings;
use Compiler::Lexer::Constants;
use parent "Perl::Lint::Policy";

use constant {
    DESC => q{Augmented assignment operator '%s' used in declaration},
    EXPL => q{Use simple assignment when initializing variables},
    AUGMENTED_ASSIGNMENTS => {
        '**=' => 1, '+='  => 1, '-='  => 1, '.='  => 1,
        '*='  => 1, '/='  => 1, '%='  => 1, 'x='  => 1,
        '&='  => 1, '|='  => 1, '^='  => 1, '<<=' => 1,
        '>>=' => 1, '&&=' => 1, '||=' => 1, '//=' => 1,
    },
    VAR         => Compiler::Lexer::TokenType::T_Var,
    LOCAL_VAR   => Compiler::Lexer::TokenType::T_LocalVar,
    GLOBAL_VAR  => Compiler::Lexer::TokenType::T_GlobalVar,
    SEMI_COLON  => Compiler::Lexer::TokenType::T_SemiColon,
    ASSIGN      => Compiler::Lexer::TokenType::T_Assign,
    DECL        => Compiler::Lexer::Kind::T_Decl,
    KIND_ASSIGN => Compiler::Lexer::Kind::T_Assign,
};

sub evaluate {
    my ($class, $file, $tokens) = @_;

    my @violations;
    my $token_num = scalar @$tokens;
    for (my $i = 0; $i < $token_num; $i++) {
        if ($tokens->[$i]->{kind} == DECL) {
            $i++;
            my $var_type = $tokens->[$i]->{type};
            if ($var_type == VAR || $var_type == LOCAL_VAR || $var_type == GLOBAL_VAR) {
                for ($i++; $i < $token_num; $i++) {
                    my $token = $tokens->[$i];
                    if (
                        $token->{kind} == KIND_ASSIGN &&
                        AUGMENTED_ASSIGNMENTS->{$token->{data}} # XXX Not good
                    ) {
                        push @violations, {
                            filename => $file,
                            line     => $token->{line},
                            description => sprintf(DESC, $token->{data}),
                            explanation => EXPL,
                            policy => __PACKAGE__,
                        };
                        last;
                    }
                    elsif ($token->{type} == ASSIGN || $token->{type} == SEMI_COLON) {
                        last;
                    }
                }
            }
        }
    }
    return \@violations;
}

1;

