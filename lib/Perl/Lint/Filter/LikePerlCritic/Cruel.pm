package Perl::Lint::Filter::LikePerlCritic::Cruel;
use strict;
use warnings;
use utf8;
use Perl::Lint::Filter::LikePerlCritic::Brutal;

sub filter {
    return [
        qw{
            BuiltinFunctions::ProhibitSleepViaSelect
            BuiltinFunctions::ProhibitStringyEval
            BuiltinFunctions::RequireGlobFunction
            ClassHierarchies::ProhibitOneArgBless
            ControlStructures::ProhibitMutatingListFunctions
            InputOutput::ProhibitBarewordFileHandles
            InputOutput::ProhibitInteractiveTest
            InputOutput::ProhibitTwoArgOpen
            InputOutput::RequireEncodingWithUTF8Layer
            Modules::ProhibitEvilModules
            Modules::RequireBarewordIncludes
            Modules::RequireFilenameMatchesPackage
            Subroutines::ProhibitExplicitReturnUndef
            Subroutines::ProhibitNestedSubs
            Subroutines::ProhibitReturnSort
            Subroutines::ProhibitSubroutinePrototypes
            TestingAndDebugging::ProhibitNoStrict
            TestingAndDebugging::RequireUseStrict
            ValuesAndExpressions::ProhibitLeadingZeros
            Variables::ProhibitConditionalDeclarations
            Variables::ProhibitEvilVariables
            Variables::RequireLexicalLoopIterators
        },
        @{Perl::Lint::Filter::LikePerlCritic::Brutal->filter},
    ];
}

1;

