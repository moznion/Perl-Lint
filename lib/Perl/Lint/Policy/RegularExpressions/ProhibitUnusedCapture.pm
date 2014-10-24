package Perl::Lint::Policy::RegularExpressions::ProhibitUnusedCapture;
use strict;
use warnings;
use List::Util qw/any all/;
use Test::Deep::NoTest qw(eq_deeply);
use Perl::Lint::Constants::Type;
use parent "Perl::Lint::Policy";

# TODO msg!
use constant {
    DESC => '',
    EXPL => '',
};

my %ignore_reg_op = (
    &REG_LIST         => 1,
    &REG_EXEC         => 1,
    &REG_QUOTE        => 1,
);

my @captured_for_each_scope;
my $sub_depth;
my @violations;
my $file;
my $tokens;
my $just_before_regex_token;
my $reg_not_ctx;
my $assign_ctx;

sub evaluate {
    my $class = shift;
    $file     = shift;
    $tokens   = shift;
    my ($src, $args) = @_;

    # use Data::Dumper::Concise; warn Dumper($tokens); # TODO remove

    my $is_used_english = 0;

    @violations = ();
    @captured_for_each_scope = ({});
    $just_before_regex_token = undef;
    $assign_ctx = 'NONE';
    $reg_not_ctx = 0;

    my %depth_for_each_subs;
    my $lbnum_for_scope = 0;
    $sub_depth = 0;

    TOP: for (my $i = 0, my $token_type, my $token_data; my $token = $tokens->[$i]; $i++) {
        $token_type = $token->{type};
        $token_data = $token->{data};

        if ($token_type == USED_NAME && $token_data eq 'English') {
            $is_used_english = 1;
            next;
        }

        # to ignore regexp which is not pattern matching
        # NOTE: Compiler::Lexer handles all of the content of q*{} operator as regexp token
        if ($ignore_reg_op{$token_type}) {
            $i += 2; # skip content
            next;
        }

        if ($token_type == ASSIGN) {
            $token = $tokens->[$i-1] or next;
            $token_type = $token->{type};

            $assign_ctx = 'ANY'; # XXX Any!?

            if (
                $token_type == GLOBAL_VAR ||
                $token_type == LOCAL_VAR ||
                $token_type == VAR
            ) {
                $assign_ctx = 'SUCCESS';
            }
            elsif (
                $token_type == GLOBAL_ARRAY_VAR ||
                $token_type == LOCAL_ARRAY_VAR ||
                $token_type == ARRAY_VAR
            ) {
                $assign_ctx = 'UNLIMITED_ARRAY';
            }
            elsif (
                $token_type == GLOBAL_HASH_VAR ||
                $token_type == LOCAL_HASH_VAR ||
                $token_type == HASH_VAR
            ) {
                $assign_ctx = 'UNLIMITED';
            }
            elsif ($token_type == RIGHT_PAREN) {
                $assign_ctx = 'LIMITED';

                $token = $tokens->[$i-2] or next;
                $token_type = $token->{type};
                if ($token_type == LEFT_PAREN) {
                    $assign_ctx = 'UNLIMITED';
                }
                elsif ($token_type == DEFAULT) {
                    $token = $tokens->[$i-3] or next;
                    $token_type = $token->{type};
                    if ($token_type == LEFT_PAREN) {
                        $assign_ctx = 'UNLIMITED';
                    }
                }
            }

            $token = $tokens->[$i+1] or next;
            $token_type = $token->{type};
            if ($token_type == LEFT_BRACE || $token_type == LEFT_BRACKET) {
                $assign_ctx = 'UNLIMITED';
            }

            next;
        }

        if ($token_type == SEMI_COLON) {
            $assign_ctx = 'NONE';
            next;
        }

        if ($token_type == REG_NOT) {
            $reg_not_ctx = 1;
            next;
        }

        if ($token_type == REG_DOUBLE_QUOTE) {
            $i += 2; # jump to string
            $token = $tokens->[$i];
            $token_type = STRING; # XXX Violence!!
            # fall through
        }
        if ($token_type == STRING || $token_type == HERE_DOCUMENT) {
            my @chars = split //, $token_data;
            my $is_var = 0;
            my $escaped = 0;
            for (my $j = 0; my $char = $chars[$j]; $j++) {
                if ($escaped) {
                    if ($char =~ /[0-9]/) {
                        # TODO should track follows number
                        delete $captured_for_each_scope[$sub_depth]->{q<$> . $char};
                    }
                    $escaped = 0;
                    next;
                }

                if ($is_var) {
                    if ($char =~ /[a-zA-Z_]/) {
                        my $var_name = $char;
                        for ($j++; $char = $chars[$j]; $j++) {
                            if ($char !~ /[0-9a-zA-Z_]/) {
                                $j--;
                                last;
                            }
                            $var_name .= $char;
                        }

                        if (!$is_used_english) {
                            next;
                        }
                        elsif (
                            $var_name eq 'LAST_PAREN_MATCH' ||
                            $var_name eq 'LAST_MATCH_END'   ||
                            $var_name eq 'LAST_MATCH_START'
                        ) {
                            $char = '+'; # XXX
                        }
                        else {
                            next;
                        }
                    }

                    if ($char eq '{') {
                        my $var_name = '';
                        for ($j++; $char = $chars[$j]; $j++) {
                            if ($char eq '}') {
                                last;
                            }
                            else {
                                $var_name .= $char;
                            }
                        }
                        delete $captured_for_each_scope[$sub_depth]->{q<$> . $var_name};
                        next;
                    }

                    if ($char =~ /[0-9]/) {
                        # TODO should track follows number
                        delete $captured_for_each_scope[$sub_depth]->{q<$> . $char};
                    }
                    elsif (
                        $char eq '+' || $char eq '-'
                    ) {
                        my $lbnum = 1;
                        my $captured_name = '';

                        my $begin_delimiter = '{';
                        my $end_delimiter = '}';
                        $char = $chars[++$j] or next;
                        if ($char eq '[') {
                            $begin_delimiter = '[';
                            $end_delimiter = ']';
                        }

                        for ($j++; $char = $chars[$j]; $j++) {
                            if ($char eq $begin_delimiter) {
                                $lbnum++;
                            }
                            elsif ($char eq $end_delimiter) {
                                last if --$lbnum <= 0;
                            }
                            elsif ($char ne ' ') {
                                $captured_name .= $char;
                            }
                        }

                        if ($begin_delimiter eq '[') {
                            $captured_name-- if $captured_name > 0;

                            my @num_vars = sort {$a cmp $b} grep { $_ =~ /\A\$[0-9]+\Z/} keys %{$captured_for_each_scope[$sub_depth]};

                            if (my $hit = $num_vars[$captured_name]) {
                                delete $captured_for_each_scope[$sub_depth]->{$hit};
                            }
                        }
                        else {
                            delete $captured_for_each_scope[$sub_depth]->{$captured_name};
                        }
                    }

                    $is_var = 0;
                    next;
                }

                if ($char eq '\\') {
                    $escaped = 1;
                    next;
                }

                if ($char eq q<$>) {
                    $is_var = 1;
                    next;
                }
            }
            next;
        }

        if ($token_type == REG_REPLACE_TO) {
            my $escaped = 0;
            my $is_var = 0;
            my @re_chars = split //, $token_data;
            for (my $j = 0; my $re_char = $re_chars[$j]; $j++) {
                if ($escaped) {
                    if ($re_char =~ /[0-9]/) {
                        # TODO should track follows number
                        delete $captured_for_each_scope[$sub_depth]->{q<$> . $re_char};
                    }
                    $escaped = 0;
                    next;
                }

                if ($is_var) {
                    if ($re_char =~ /[a-zA-Z_]/) {
                        my $var_name = $re_char;
                        for ($j++; $re_char = $re_chars[$j]; $j++) {
                            if ($re_char !~ /[0-9a-zA-Z_]/) {
                                $j--;
                                last;
                            }
                            $var_name .= $re_char;
                        }

                        if (!$is_used_english) {
                            next;
                        }
                        elsif (
                            $var_name eq 'LAST_PAREN_MATCH' ||
                            $var_name eq 'LAST_MATCH_END'   ||
                            $var_name eq 'LAST_MATCH_START'
                        ) {
                            $re_char = '+'; # XXX
                        }
                        else {
                            next;
                        }
                    }

                    if ($re_char eq '{') {
                        my $var_name = '';
                        for ($j++; $re_char = $re_chars[$j]; $j++) {
                            if ($re_char eq '}') {
                                last;
                            }
                            else {
                                $var_name .= $re_char;
                            }
                        }
                        delete $captured_for_each_scope[$sub_depth]->{q<$> . $var_name};
                        next;
                    }

                    if ($re_char =~ /[0-9]/) {
                        # TODO should track follows number
                        delete $captured_for_each_scope[$sub_depth]->{q<$> . $re_char};
                    }
                    elsif (
                        $re_char eq '+' || $re_char eq '-'
                    ) {
                        my $lbnum = 1;
                        my $captured_name = '';

                        my $begin_delimiter = '{';
                        my $end_delimiter = '}';
                        $re_char = $re_chars[++$j] or next;
                        if ($re_char eq '[') {
                            $begin_delimiter = '[';
                            $end_delimiter = ']';
                        }

                        for (; $re_char = $re_chars[$j]; $j++) {
                            if ($re_char eq $begin_delimiter) {
                                $lbnum++;
                            }
                            elsif ($re_char eq $end_delimiter) {
                                last if --$lbnum <= 0;
                            }
                            elsif ($re_char ne ' ') {
                                $captured_name .= $re_char;
                            }
                        }

                        if ($begin_delimiter eq '[') {
                            $captured_name-- if $captured_name > 0;

                            my @num_vars = sort {$a cmp $b} grep { $_ =~ /\A\$[0-9]+\Z/} keys %{$captured_for_each_scope[$sub_depth]};

                            if (my $hit = $num_vars[$captured_name]) {
                                delete $captured_for_each_scope[$sub_depth]->{$hit};
                            }
                        }
                        else {
                            delete $captured_for_each_scope[$sub_depth]->{$captured_name};
                        }
                    }

                    $is_var = 0;
                    next;
                }

                if ($re_char eq '\\') {
                    $escaped = 1;
                    next;
                }

                if ($re_char eq q<$>) {
                    $is_var = 1;
                    next;
                }
            }

            next;
        }

        if ($token_type == REG_EXP || $token_type == REG_REPLACE_FROM) {
            if (%{$captured_for_each_scope[$sub_depth]}) {
                push @violations, {
                    filename => $file,
                    line     => $just_before_regex_token->{line},
                    description => DESC,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
            }

            $captured_for_each_scope[$sub_depth] = {};
            $just_before_regex_token = $token;

            my @re_chars = split //, $token_data;

            my $escaped = 0;
            my $lbnum = 0;
            my $captured_num = 0;
            for (my $j = 0; my $re_char = $re_chars[$j]; $j++) {
                if ($escaped) {
                    if ($re_char =~ /[0-9]/) {
                        # TODO should track follows number
                        delete $captured_for_each_scope[$sub_depth]->{q<$> . $re_char};
                    }
                    $escaped = 0;
                    next;
                }

                if ($re_char eq '\\') {
                    $escaped = 1;
                    next;
                }

                if ($re_char eq '[') {
                    $lbnum++;
                    next;
                }

                if ($lbnum > 0) { # in [...]
                    if ($re_char eq ']') {
                        $lbnum--;
                        next;
                    }

                    next;
                }

                if ($re_char eq '(') {
                    my $captured_name = '';

                    if ($re_chars[$j+1] eq '?') {
                        my $delimiter = $re_chars[$j+2];

                        if ($delimiter eq ':') {
                            next;
                        }

                        if ($delimiter eq 'P') {
                            $delimiter = $re_chars[$j+3];
                            $j++;
                        }

                        if ($delimiter eq '<' || $delimiter eq q{'}) {
                            for ($j += 3; $re_char = $re_chars[$j]; $j++) {
                                if (
                                    ($delimiter eq '<' && $re_char eq '>') ||
                                    ($delimiter eq q{'} && $re_char eq q{'})
                                ) {
                                    last;
                                }
                                $captured_name .= $re_char;
                            }


                            if ($reg_not_ctx) {
                                push @violations, {
                                    filename => $file,
                                    line     => $token->{line},
                                    description => DESC,
                                    explanation => EXPL,
                                    policy => __PACKAGE__,
                                };
                            }
                            else {
                                $captured_num++;
                                $captured_for_each_scope[$sub_depth]->{$captured_name} = 1;
                            }
                        }
                    }
                    elsif ($re_chars[$j+1] ne '?' || $re_chars[$j+2] ne ':') {
                        if ($reg_not_ctx) {
                            push @violations, {
                                filename => $file,
                                line     => $token->{line},
                                description => DESC,
                                explanation => EXPL,
                                policy => __PACKAGE__,
                            };
                        }
                        else {
                            $captured_num++;
                            $captured_for_each_scope[$sub_depth]->{q<$> . $captured_num} = 1;
                        }
                    }
                }
            }

            if ($assign_ctx ne 'NONE') {
                my $captured = $captured_for_each_scope[$sub_depth];

                if ($assign_ctx eq 'UNLIMITED_ARRAY') {
                    if (%{$captured || {}}) {
                        if (all {substr($_, 0, 1) eq q<$> } keys %$captured) {
                            $captured_for_each_scope[$sub_depth] = {};
                        }
                    }
                    next;
                }

                $captured_for_each_scope[$sub_depth] = {};

                my $maybe_reg_opt = $tokens->[$i+2] or next;
                if ($maybe_reg_opt->{type} == REG_OPT) {
                    if ($assign_ctx ne 'UNLIMITED' && $maybe_reg_opt->{data} =~ /g/) {
                        push @violations, {
                            filename => $file,
                            line     => $token->{line},
                            description => DESC,
                            explanation => EXPL,
                            policy => __PACKAGE__,
                        };
                    }
                }

                next;
            }

            $reg_not_ctx = 0;

            next;
        }

        if ($token_type == BUILTIN_FUNC) {
            if ($token_data eq 'grep' || $token_data eq 'map') {
                $token = $tokens->[++$i] or last;
                $token_type = $token->{type};

                if ($token_type == LEFT_PAREN) {
                    my $lpnum = 1;
                    for ($i++; $token = $tokens->[$i]; $i++) {
                        $token_type = $token->{type};
                        if ($token_type == LEFT_PAREN) {
                            $lpnum++;
                        }
                        elsif ($token_type == RIGHT_PAREN) {
                            last if --$lpnum <= 0;
                        }
                    }
                }
                else {
                    for ($i++; $token = $tokens->[$i]; $i++) {
                        if ($token->{type} == SEMI_COLON) {
                            last;
                        }
                    }
                }

                next;
            }
        }

        if (
            $token_type == BUILTIN_FUNC ||
            $token_type == METHOD ||
            $token_type == KEY
        ) {
            my $j = $i + 1;
            $token = $tokens->[$j] or last;
            $token_type = $token->{type};
            if ($token_type == LEFT_PAREN) {
                my $lpnum = 1;
                for ($j++; $token = $tokens->[$j]; $j++) {
                    $token_type = $token->{type};
                    if ($token_type == LEFT_PAREN) {
                        $lpnum++;
                    }
                    elsif ($token_type == RIGHT_PAREN) {
                        last if --$lpnum <= 0;
                    }
                    elsif ($token_type == REG_EXP) {
                        $token->{type} = -1; # XXX Replace to NOP
                    }
                }
            }
            else {
                for (my $j = $i + 1; $token = $tokens->[$j]; $j++) {
                    $token_type = $token->{type};
                    if ($token_type == SEMI_COLON) {
                        last;
                    }
                    elsif ($token_type == REG_EXP) {
                        $token->{type} = -1; # XXX Replace to NOP
                    }
                }
            }

            next;
        }

        if (
            $token_type == IF_STATEMENT    ||
            $token_type == ELSIF_STATEMENT ||
            $token_type == UNLESS_STATEMENT
        ) {
            $token = $tokens->[++$i] or next;

            my @regexs_at_before_and_op;
            my @regexs_at_after_and_op;
            my $and_op_token;

            if ($token->{type} eq LEFT_PAREN) {
                my $lpnum = 1;
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};
                    if ($token_type == LEFT_PAREN) {
                        $lpnum++;
                    }
                    elsif ($token_type == RIGHT_PAREN) {
                        last if --$lpnum <= 0;
                    }
                    elsif ($token_type == REG_EXP) {
                        if ($and_op_token) {
                            push @regexs_at_after_and_op, $token;
                        }
                        else {
                            push @regexs_at_before_and_op, $token;
                        }
                    }
                    elsif ($token_type == AND || $token_type == ALPHABET_AND) {
                        $and_op_token = $token;
                    }
                    elsif ($ignore_reg_op{$token_type} || $token_type == REG_DOUBLE_QUOTE) { # XXX
                        $i += 2;
                    }
                }
            }
            else {
                for ($i++; $token = $tokens->[$i]; $i++) {
                    $token_type = $token->{type};
                    if ($token_type == SEMI_COLON) {
                        last;
                    }
                    elsif ($token_type == REG_EXP) {
                        if ($and_op_token) {
                            push @regexs_at_after_and_op, $token;
                        }
                        else {
                            push @regexs_at_before_and_op, $token;
                        }
                    }
                    elsif ($token_type == AND || $token_type == ALPHABET_AND) {
                        $and_op_token = $token;
                    }
                    elsif ($ignore_reg_op{$token_type} || $token_type == REG_DOUBLE_QUOTE) { # XXX
                        $i += 2;
                    }
                }
            }

            if (!@regexs_at_after_and_op) {
                my @captured;
                for my $regex (@regexs_at_before_and_op) {
                    $class->_scan_regex($regex, $i);

                    push @captured, $captured_for_each_scope[$sub_depth];
                    $captured_for_each_scope[++$sub_depth] = {};
                }

                my $datam = pop @captured;
                if ($datam) {
                    for my $cap (@captured) {
                        if (!eq_deeply($datam, $cap)) {
                            # TODO push violation?
                            next TOP;
                        }
                    }
                }

                $captured_for_each_scope[$sub_depth] = $datam;
            }
            else {
                my $is_captured_at_before_and_op = 0;
                for my $b_regex (@regexs_at_before_and_op) {
                    $class->_scan_regex($b_regex, $i);

                    my %captured_this_scope = %{$captured_for_each_scope[$sub_depth] || {}};
                    if (%captured_this_scope) {
                        $is_captured_at_before_and_op = 1;
                        last;
                    }
                }

                for my $a_regex (@regexs_at_after_and_op) {
                    $class->_scan_regex($a_regex, $i);

                    my %captured_this_scope = %{$captured_for_each_scope[$sub_depth] || {}};
                    if (%captured_this_scope && $is_captured_at_before_and_op) {
                        last;
                    }
                }
            }

            next;
        }

        if ($token_type == SPECIFIC_VALUE) {
            if ($token_data =~ /\A\$[0-9]+\Z/) {
                delete $captured_for_each_scope[$sub_depth]->{$token_data};
                next;
            }

            if ($token_data eq '$+' || $token_data eq '$-') {
                # TODO duplicated...
                $token = $tokens->[$i+2] or next;
                $token_data = $token->{data};
                if ($token_data =~ /\A -? [0-9]+ \Z/x) {
                    $token_data-- if $token_data > 0;

                    my @num_vars = sort {$a cmp $b} grep { $_ =~ /\A\$[0-9]+\Z/} keys %{$captured_for_each_scope[$sub_depth]};

                    if (my $hit = $num_vars[$token_data]) {
                        delete $captured_for_each_scope[$sub_depth]->{$hit};
                    }
                }
                else {
                    delete $captured_for_each_scope[$sub_depth]->{$token->{data}};
                }
            }

            next;
        }

        if ($is_used_english) {
            if ($token_type == GLOBAL_VAR || $token_type == VAR) {
                # TODO duplicated...
                if (
                    $token_data eq '$LAST_PAREN_MATCH' ||
                    $token_data eq '$LAST_MATCH_END'   ||
                    $token_data eq '$LAST_MATCH_START'
                ) {
                    $token = $tokens->[$i+2] or next;
                    $token_data = $token->{data};
                    if ($token_data =~ /\A -? [0-9]+ \Z/x) {
                        $token_data-- if $token_data > 0;

                        my @num_vars = sort {$a cmp $b} grep { $_ =~ /\A\$[0-9]+\Z/} keys %{$captured_for_each_scope[$sub_depth]};

                        if (my $hit = $num_vars[$token_data]) {
                            delete $captured_for_each_scope[$sub_depth]->{$hit};
                        }
                    }
                    else {
                        delete $captured_for_each_scope[$sub_depth]->{$token->{data}};
                    }
                }
            }
        }

        if ($token_type == FUNCTION_DECL) {
            $depth_for_each_subs{$lbnum_for_scope} = 1;
            $assign_ctx = 'NONE'; # XXX Umm...
            $sub_depth++;
            $captured_for_each_scope[$sub_depth] = {};
            next;
        }

        if ($token_type == LEFT_BRACE) {
            $lbnum_for_scope++;
            next;
        }

        if ($token_type == RIGHT_BRACE) {
            $lbnum_for_scope--;
            if (delete $depth_for_each_subs{$lbnum_for_scope}) {
                my $regexp_in_return_ctx;
                if ($token = $tokens->[$i-2]) {
                    if ($token->{type} == REG_EXP) {
                        $regexp_in_return_ctx = $token;
                    }
                    elsif ($token = $tokens->[$i-3]) {
                        if ($token->{type} == REG_EXP) {
                            $regexp_in_return_ctx = $token;
                        }
                    }
                }

                if (my %captured = %{pop @captured_for_each_scope}) {
                    if ($regexp_in_return_ctx) {
                        # should check equality between to just before regexp token?
                        if (all {substr($_, 0, 1) eq q<$>} keys %captured) {
                            next;
                        }
                    }

                    push @violations, {
                        filename => $file,
                        line     => $just_before_regex_token->{line},
                        description => DESC,
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                }
            }
            next;
        }
    }

    if (%{$captured_for_each_scope[-1] || {}}) {
        push @violations, {
            filename => $file,
            line     => $just_before_regex_token->{line},
            description => DESC,
            explanation => EXPL,
            policy => __PACKAGE__,
        };
    }

    return \@violations;
}

sub _scan_regex {
    my ($class, $token, $i) = @_;

    if (%{$captured_for_each_scope[$sub_depth]}) {
        push @violations, {
            filename => $file,
            line     => $just_before_regex_token->{line},
            description => DESC,
            explanation => EXPL,
            policy => __PACKAGE__,
        };
    }

    $captured_for_each_scope[$sub_depth] = {};
    $just_before_regex_token = $token;

    my $token_data = $token->{data};

    my @re_chars = split //, $token_data;

    my $escaped = 0;
    my $lbnum = 0;
    my $captured_num = 0;
    for (my $j = 0; my $re_char = $re_chars[$j]; $j++) {
        if ($escaped) {
            if ($re_char =~ /[0-9]/) {
                # TODO should track follows number
                delete $captured_for_each_scope[$sub_depth]->{q<$> . $re_char};
            }
            $escaped = 0;
            return;
        }

        if ($re_char eq '\\') {
            $escaped = 1;
            return;
        }

        if ($re_char eq '[') {
            $lbnum++;
            return;
        }

        if ($lbnum > 0) { # in [...]
            if ($re_char eq ']') {
                $lbnum--;
                return;
            }

            return;
        }

        if ($re_char eq '(') {
            my $captured_name = '';

            if ($re_chars[$j+1] eq '?') {
                my $delimiter = $re_chars[$j+2];

                if ($delimiter eq ':') {
                    return;
                }

                if ($delimiter eq 'P') {
                    $delimiter = $re_chars[$j+3];
                    $j++;
                }

                if ($delimiter eq '<' || $delimiter eq q{'}) {
                    for ($j += 3; $re_char = $re_chars[$j]; $j++) {
                        if (
                            ($delimiter eq '<' && $re_char eq '>') ||
                            ($delimiter eq q{'} && $re_char eq q{'})
                        ) {
                            last;
                        }
                        $captured_name .= $re_char;
                    }

                    if ($reg_not_ctx) {
                        push @violations, {
                            filename => $file,
                            line     => $token->{line},
                            description => DESC,
                            explanation => EXPL,
                            policy => __PACKAGE__,
                        };
                    }
                    else {
                        $captured_num++;
                        $captured_for_each_scope[$sub_depth]->{$captured_name} = 1;
                    }
                }
            }
            elsif ($re_chars[$j+1] ne '?' || $re_chars[$j+2] ne ':') {
                if ($reg_not_ctx) {
                    push @violations, {
                        filename => $file,
                        line     => $token->{line},
                        description => DESC,
                        explanation => EXPL,
                        policy => __PACKAGE__,
                    };
                }
                else {
                    $captured_num++;
                    $captured_for_each_scope[$sub_depth]->{q<$> . $captured_num} = 1;
                }
            }
        }
    }

    if ($assign_ctx ne 'NONE') {
        my $captured = $captured_for_each_scope[$sub_depth];

        if ($assign_ctx eq 'UNLIMITED_ARRAY') {
            if (%{$captured || {}}) {
                if (all {substr($_, 0, 1) eq q<$> } keys %$captured) {
                    $captured_for_each_scope[$sub_depth] = {};
                }
            }
            return;
        }

        $captured_for_each_scope[$sub_depth] = {};

        my $maybe_reg_opt = $tokens->[$i+2] or return;
        if ($maybe_reg_opt->{type} == REG_OPT) {
            if ($assign_ctx ne 'UNLIMITED' && $maybe_reg_opt->{data} =~ /g/) {
                push @violations, {
                    filename => $file,
                    line     => $token->{line},
                    description => DESC,
                    explanation => EXPL,
                    policy => __PACKAGE__,
                };
            }
        }

        return;
    }

    $reg_not_ctx = 0;

    return;
}

1;

