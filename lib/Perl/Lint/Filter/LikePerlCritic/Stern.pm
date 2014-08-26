package Perl::Lint::Filter::LikePerlCritic::Stern;
use strict;
use warnings;
use utf8;
use Perl::Lint::Filter::LikePerlCritic::Harsh;

sub filter {
    return [
        qw{
            BuiltinFunctions::ProhibitLvalueSubstr
            BuiltinFunctions::ProhibitComplexMappings
            BuiltinFunctions::ProhibitUniversalIsa
            BuiltinFunctions::ProhibitVoidGrep
            BuiltinFunctions::RequireSimpleSortBlock
            BuiltinFunctions::ProhibitVoidMap
            ClassHierarchies::ProhibitAutoloading
            ClassHierarchies::ProhibitExplicitISA
            BuiltinFunctions::ProhibitUniversalCan
            CodeLayout::ProhibitHardTabs
            ControlStructures::ProhibitCascadingIfElse
            ControlStructures::ProhibitDeepNests
            ControlStructures::ProhibitNegativeExpressionsInUnlessAndUntilConditions
            ErrorHandling::RequireCheckingReturnValueOfEval
            ErrorHandling::RequireCarping
            InputOutput::ProhibitBacktickOperators
            InputOutput::ProhibitJoinedReadline
            InputOutput::RequireCheckedOpen
            Miscellanea::ProhibitFormats
            Miscellanea::ProhibitUnrestrictedNoCritic
            Modules::ProhibitConditionalUseStatements
            Modules::ProhibitExcessMainComplexity
            NamingConventions::ProhibitAmbiguousNames
            RegularExpressions::ProhibitCaptureWithoutTest
            RegularExpressions::ProhibitComplexRegexes
            RegularExpressions::ProhibitUnusedCapture
            RegularExpressions::RequireExtendedFormatting
            Subroutines::ProhibitExcessComplexity
            Subroutines::ProhibitManyArgs
            Subroutines::ProhibitUnusedPrivateSubroutines
            Subroutines::ProtectPrivateSubs
            TestingAndDebugging::RequireTestLabels
            ValuesAndExpressions::ProhibitComplexVersion
            ValuesAndExpressions::ProhibitImplicitNewlines
            ValuesAndExpressions::ProhibitMismatchedOperators
            ValuesAndExpressions::ProhibitQuotesAsQuotelikeOperatorDelimiters
            ValuesAndExpressions::ProhibitSpecialLiteralHeredocTerminator
            ValuesAndExpressions::ProhibitVersionStrings
            ValuesAndExpressions::RequireQuotedHeredocTerminator
            Variables::ProhibitPackageVars
            Variables::ProhibitReusedNames
            Variables::ProhibitUnusedVariables
            Variables::ProtectPrivateVars
            Variables::RequireInitializationForLocalVars
        },
        @{Perl::Lint::Filter::LikePerlCritic::Harsh->filter},
    ];
}

1;

