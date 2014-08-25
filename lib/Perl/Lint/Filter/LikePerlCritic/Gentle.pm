package Perl::Lint::Filter::LikePerlCritic::Gentle;
use strict;
use warnings;
use utf8;
use Perl::Lint::Filter::LikePerlCritic::Stern;

sub filter {
    return [
        qw{
            BuiltinFunctions/ProhibitBooleanGrep.pm
            BuiltinFunctions/ProhibitStringySplit.pm
            BuiltinFunctions/ProhibitUselessTopic.pm
            CodeLayout/ProhibitQuotedWordLists.pm
            ControlStructures/ProhibitCStyleForLoops.pm
            ControlStructures/ProhibitPostfixControls.pm
            ControlStructures/ProhibitUnlessBlocks.pm
            ControlStructures/ProhibitUntilBlocks.pm
            Documentation/RequirePodLinksIncludeText.pm
            Documentation/RequirePodSections.pm
            InputOutput/RequireCheckedClose.pm
            Miscellanea/ProhibitTies.pm
            Miscellanea/ProhibitUselessNoCritic.pm
            Modules/RequireNoMatchVarsWithUseEnglish.pm
            Modules/RequireVersionVar.pm
            References/ProhibitDoubleSigils.pm
            RegularExpressions/ProhibitFixedStringMatches.pm
            RegularExpressions/ProhibitUselessTopic.pm
            RegularExpressions/RequireDotMatchAnything.pm
            RegularExpressions/RequireLineBoundaryMatching.pm
            Subroutines/ProhibitAmpersandSigils.pm
            ValuesAndExpressions/ProhibitEmptyQuotes.pm
            ValuesAndExpressions/ProhibitEscapedCharacters.pm
            ValuesAndExpressions/ProhibitLongChainsOfMethodCalls.pm
            ValuesAndExpressions/ProhibitMagicNumbers.pm
            ValuesAndExpressions/ProhibitNoisyQuotes.pm
            ValuesAndExpressions/RequireConstantVersion.pm
            ValuesAndExpressions/RequireNumberSeparators.pm
            ValuesAndExpressions/RequireUpperCaseHeredocTerminator.pm
            Variables/ProhibitLocalVars.pm
            Variables/ProhibitPerl4PackageNames.pm
            Variables/ProhibitPunctuationVars.pm
        },
        @{Perl::Lint::Filter::LikePerlCritic::Stern->filter},
    ];
}

1;

