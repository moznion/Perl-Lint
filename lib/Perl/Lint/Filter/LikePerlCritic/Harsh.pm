package Perl::Lint::Filter::LikePerlCritic::Harsh;
use strict;
use warnings;
use utf8;
use Perl::Lint::Filter::LikePerlCritic::Cruel;

sub filter {
    return [
        qw{
            BuiltinFunctions::RequireBlockGrep
            BuiltinFunctions::RequireBlockMap
            CodeLayout::RequireConsistentNewlines
            ControlStructures::ProhibitLabelsWithSpecialBlockNames
            ControlStructures::ProhibitUnreachableCode
            InputOutput::ProhibitExplicitStdin
            InputOutput::ProhibitOneArgSelect
            InputOutput::ProhibitReadlineInForLoop
            InputOutput::RequireBriefOpen
            Modules::ProhibitAutomaticExportation
            Modules::ProhibitMultiplePackages
            Modules::RequireEndWithOne
            Modules::RequireExplicitPackage
            Objects::ProhibitIndirectSyntax
            Subroutines::ProhibitBuiltinHomonyms
            Subroutines::RequireArgUnpacking
            Subroutines::RequireFinalReturn
            TestingAndDebugging::ProhibitNoWarnings
            TestingAndDebugging::ProhibitProlongedStrictureOverride
            TestingAndDebugging::RequireUseWarnings
            ValuesAndExpressions::ProhibitCommaSeparatedStatements
            ValuesAndExpressions::ProhibitConstantPragma
            ValuesAndExpressions::ProhibitMixedBooleanOperators
            Variables::ProhibitAugmentedAssignmentInDeclaration
            Variables::ProhibitMatchVars
            Variables::RequireLocalizedPunctuationVars
            Variables::RequireNegativeIndices
        },
        @{Perl::Lint::Filter::LikePerlCritic::Cruel->filter},
    ];
}

1;

