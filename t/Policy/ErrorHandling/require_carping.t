#!perl

use strict;
use warnings;
use utf8;
use Perl::Lint;
use Perl::Lint::Policy::ErrorHandling::RequireCarping;
use t::Policy::Util qw/fetch_violations/;
use Test::More;

my $class_name = 'ErrorHandling::RequireCarping';

subtest 'Unspectacular die' => sub {
    my $src = <<'...';
die 'A horrible death' if $condtion;
if ($condition) {
   die 'A horrible death';
}
open my $fh, '<', $path or die "Can't open file $path";
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 3;
    # TODO
};

subtest 'Unspectacular warn' => sub {
    my $src = <<'...';
warn 'A horrible warning' if $condtion;
if ($condition) {
   warn 'A horrible warning';
}
open my $fh, '<', $path or warn "Can't open file $path";
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 3;
};

subtest 'Carping' => sub {
    my $src = <<'...';
carp 'A horrible death' if $condtion;
if ($condition) {
   carp 'A horrible death';
}
open my $fh, '<', $path or
  carp "Can't open file $path";
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 0;
};

subtest 'No croaking' => sub {
    my $src = <<'...';
die 'A horrible death';
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 1;
};

subtest 'Complain about cases without arguments' => sub {
    my $src = <<'...';
die;
die
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 2;
};

subtest 'Complain about cases with empty list arguments' => sub {
    my $src = <<'...';
die ( );
die ( )
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 2;
};

subtest 'Complain about cases with non-string arguments' => sub {
    my $src = <<'...';
die $error;
die @errors;
die %errors_by_id;
die $errors[0];
die $errors_by_id{"Cheese fondue overflow"};
die $marvin_gaye->whats_goin_on();
die $george_washington->cross("Delaware River\n");
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 7;
};

subtest q{Don't complain if message ends with "\n" in double quotes} => sub {
    my $src = <<'...';
die "A horrible death\n";
die "A horrible death\n"
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 0;
};

subtest q{Don't complain if message ends with literal "\n"} => sub {
    my $src = <<'...';
die "A horrible death
";
die 'A horrible death
';
die q{A horrible death
};
die qq{A horrible death
};
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 0;
};

subtest q{Don't complain if message is a heredoc, which must end in "\n"} => sub {
    my $src = <<'...';
die <<'eod' ;
A horrible death
eod

die <<"eod"
A horrible death
eod
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 0;
};

subtest q{Complain if message ends with "\n" in single quotes} => sub {
    my $src = <<'...';
die 'A horrible death\n' ;
die 'A horrible death\n'    # last statement doesn't need a terminator
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 2;
};

subtest q{Don't complain if message ends with "\n" in interpolated quotelike operator} => sub {
    my $src = <<'...';
die qq{A horrible death\n} ;
die qq#A horrible death\n# ;
die qq/A horrible death\n/  # last statement doesn't need a terminator
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 0;
};

subtest q{Complain if message ends with "\n" in non-interpolated quotelike operator} => sub {
    my $src = <<'...';
die q{A horrible death\n} ;
die q#A horrible death\n# ;
die q/A horrible death\n/   # last statement doesn't need a terminator
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 3;
};

subtest q{Don't complain if message is a list with a last element that ends with "\n"} => sub {
    my $src = <<'...';
die q{Don't },  $die, " a horrible death\n"     ;
die qq{Don't }, $die, qq/ a horrible death\n/   ;
die q{Don't },  $die, " a horrible death\n"   , ;
die q{Don't },  $die, " a horrible death\n"   , # last statement doesn't need a terminator
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 0;
};

subtest q{Don't complain if message is a parenthesised list with a last element that ends with "\n"} => sub {
    my $src = <<'...';
die ( q{Don't },  $die, " a horrible death\n"     )   ;
die ( qq{Don't }, $die, qq/ a horrible death\n/   )   ;
die ( qq{Don't }, $die, qq/ a horrible death\n/   ) , ;
die ( q{Don't },  $die, " a horrible death\n"   , ) # last statement doesn't need a terminator
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 0;
};

subtest q{Don't complain if message is a list with "sub" lists with a last (flattened list) element that ends with "\n"} => sub {
    my $src = <<'...';
# all these tests are necessary (different PPI trees)

# one element in a sub list
die q{Don't } , ( $die ) ,   " a horrible death\n"   ;
die q{Don't } ,   $die   , ( " a horrible death\n" ) ;

# sub list and a bare element
die q{Don't } , ( $die   ,   " a horrible death\n" ) ;

# two sub lists
die q{Don't } , ( $die ) , ( " a horrible death\n" ) ;


# sub sub lists
die ( ( q{Don't } ) ,   $die   ,   " a horrible death\n"       ) ;
die (   q{Don't }   ,   $die   , ( " a horrible death\n"     ) ) ;
die (   q{Don't }   , ( $die   , ( " a horrible death\n"   ) ) ) ;
die ( ( q{Don't }   , ( $die   , ( " a horrible death\n" ) ) ) ) ;

# play with extra commas
die ( ( q{Don't } , ( $die , ( " a horrible death\n" , ) , ) , ) , ) , ;
die ( ( q{Don't } , ( $die , ( " a horrible death\n" , ) , ) , ) , ) ,
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 0;
};

subtest q{Complain if message is a list with "sub" lists with a last (flattened list) element that doesn't end with "\n"} => sub {
    my $src = <<'...';
# all these tests are necessary: make sure that the policy knows when to
# stop looking.

# one element in a sub list
die q{Don't }   , ( $die ) ,   @a_horrible_death   ;
die q{Don't }   ,   $die   , ( @a_horrible_death ) ;

# sub list and a bare element
die q{Don't }   , ( $die   ,   @a_horrible_death ) ;

# two sub lists
die q{Don't }   , ( $die ) , ( @a_horrible_death ) ;


# sub sub lists
die ( ( q{Don't } ) ,   $die   ,   @a_horrible_death       ) ;
die (   q{Don't }   ,   $die   , ( @a_horrible_death     ) ) ;
die (   q{Don't }   , ( $die   , ( @a_horrible_death   ) ) ) ;
die ( ( q{Don't }   , ( $die   , ( @a_horrible_death ) ) ) ) ;

# play with extra commas
die ( ( q{Don't } , ( $die , ( @a_horrible_death , ) , ) , ) , ) , ;
die ( ( q{Don't } , ( $die , ( @a_horrible_death , ) , ) , ) , ) ,
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 10;
};

subtest q{Don't complain if message is a concatenation with a last element that ends with "\n"} => sub {
    my $src = <<'...';
die   q{Don't } . $die . " a horrible death\n"   ;
die ( q{Don't } . $die . " a horrible death\n" ) ;
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 0;
};

subtest q{Don't complain if followed by postfix operator and otherwise valid} => sub {
    my $src = <<'...';
die "A horrible death\n" if $self->is_a_bad_guy();
die "A horrible death\n" unless $self->rescued_from_the_sinking_ship();
die "A horrible death\n" while $deep_sense_of_guilt;
die "A horrible death\n" until $clear_conscience;
die "A horrible death\n" for @your_crimes;
die "A horrible death\n" foreach @{ $songs_sung_off_key };

die 'A horrible ', "death\n" if $self->is_a_bad_guy();
die 'A horrible ', "death\n" unless $self->rescued_from_the_sinking_ship();
die 'A horrible ', "death\n" while $deep_sense_of_guilt;
die 'A horrible ', "death\n" until $clear_conscience;
die 'A horrible ', "death\n" for @your_crimes;
die 'A horrible ', "death\n" foreach @{ $songs_sung_off_key };

die ( 'A horrible ', "death\n" ) if $self->is_a_bad_guy();
die ( 'A horrible ', "death\n" ) unless $self->rescued_from_the_sinking_ship();
die ( 'A horrible ', "death\n" ) while $deep_sense_of_guilt;
die ( 'A horrible ', "death\n" ) until $clear_conscience;
die ( 'A horrible ', "death\n" ) for @your_crimes;
die ( 'A horrible ', "death\n" ) foreach @{ $songs_sung_off_key };

die ( 'A horrible ' . "death\n" ) if $self->is_a_bad_guy();
die ( 'A horrible ' . "death\n" ) unless $self->rescued_from_the_sinking_ship();
die ( 'A horrible ' . "death\n" ) while $deep_sense_of_guilt;
die ( 'A horrible ' . "death\n" ) until $clear_conscience;
die ( 'A horrible ' . "death\n" ) for @your_crimes;
die ( 'A horrible ' . "death\n" ) foreach @{ $songs_sung_off_key };
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 0;
};

subtest q{Complain if followed by postfix operator with "\n" ending last operand and otherwise invalid.} => sub {
    my $src = <<'...';
die "A horrible death" if "Matagami\n";
die "A horrible death" unless "Enniscorthy\n";
die "A horrible death" while "Htargcm\n";
die "A horrible death" until "Akhalataki\n";
die "A horrible death" for "Fleac\n";
die "A horrible death" foreach "Uist\n";

die 'A horrible ', "death" if "Matagami\n";
die 'A horrible ', "death" unless "Enniscorthy\n";
die 'A horrible ', "death" while "Htargcm\n";
die 'A horrible ', "death" until "Akhalataki\n";
die 'A horrible ', "death" for "Fleac\n";
die 'A horrible ', "death" foreach "Uist\n";

die ( 'A horrible ', "death" ) if "Matagami\n";
die ( 'A horrible ', "death" ) unless "Enniscorthy\n";
die ( 'A horrible ', "death" ) while "Htargcm\n";
die ( 'A horrible ', "death" ) until "Akhalataki\n";
die ( 'A horrible ', "death" ) for "Fleac\n";
die ( 'A horrible ', "death" ) foreach "Uist\n";

die ( 'A horrible ' . "death" ) if "Matagami\n";
die ( 'A horrible ' . "death" ) unless "Enniscorthy\n";
die ( 'A horrible ' . "death" ) while "Htargcm\n";
die ( 'A horrible ' . "death" ) until "Akhalataki\n";
die ( 'A horrible ' . "death" ) for "Fleac\n";
die ( 'A horrible ' . "death" ) foreach "Uist\n";
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 24;
};

subtest q{Complain if message has a last element that ends with "\n" but has an operation in front} => sub {
    my $src = <<'...';
die   q{Don't } . $die . length " a horrible death\n"   ;
die ( q{Don't } . $die . length " a horrible death\n" ) ;
die   q{Don't } . $die . length(" a horrible death\n")  ;
die ( q{Don't } . $die . length(" a horrible death\n")) ;

die   q{Don't } . $die . func " a horrible death\n"   ;
die ( q{Don't } . $die . func " a horrible death\n" ) ;
die   q{Don't } . $die . func(" a horrible death\n")  ;
die ( q{Don't } . $die . func(" a horrible death\n")) ;
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 8;
};

subtest q{Complain if config doesn't allow newlines.} => sub {
    my $src = <<'...';
die "A horrible death\n" ;
...
    my $violations = fetch_violations($class_name, $src, {
        require_carping => {
            allow_messages_ending_with_newlines => 0,
        }
    });

    is scalar @$violations, 1;
};

subtest q{Complain if in main:: and option not set} => sub {
    my $src = <<'...';
package main;

die "A horrible death";
...
    my $violations = fetch_violations($class_name, $src);

    is scalar @$violations, 1;
};

subtest q{Don't complain if in main:: and option set (RT #56619)} => sub {
    my $src = <<'...';
package main;

die "A horrible death";
...
    my $violations = fetch_violations($class_name, $src, {
        require_carping => {
            allow_in_main_unless_in_subroutine => 1,
        }
    });

    is scalar @$violations, 0;
};

subtest q{Don't complain if implicitly in main:: and option set} => sub {
    my $src = <<'...';
die "A horrible death";
...
    my $violations = fetch_violations($class_name, $src, {
        require_carping => {
            allow_in_main_unless_in_subroutine => 1,
        }
    });

    is scalar @$violations, 0;
};

subtest q{Complain if in main:: but in subroutine} => sub {
    my $src = <<'...';
sub foo {
    die "Goodbye, cruel world!";
}
...
    my $violations = fetch_violations($class_name, $src, {
        require_carping => {
            allow_in_main_unless_in_subroutine => 1,
        }
    });

    is scalar @$violations, 1;
};

subtest q{Complain if in main:: but in anonymous subroutine} => sub {
    my $src = <<'...';
my $foo = sub {
    die "Goodbye, cruel world!";
};
...
    my $violations = fetch_violations($class_name, $src, {
        require_carping => {
            allow_in_main_unless_in_subroutine => 1,
        }
    });

    is scalar @$violations, 1;
};

# TODO
subtest q{Don't complain about obvious uses of references because they're likely being used as exception objects.} => sub {
    my $src = <<'...';
die \$frobnication_exception;
die \@accumulated_warnings;
die \%problem_data;

die
    [
        'process.html: missing standard section separator comments',
        'green.css: uses non-standard font "Broken 15"',
        'cat.jpg: missing copyright information in Exif metadata',
    ];

die
    {
        message     => 'Found duplicate entries',
        file        => $current_file,
        parser      => $self,
        occurrences => $occurrences,
        duplicated  => $entry_content,
    };

die Blrfl::Exception->new('Too many croutons', $salad);
...
    my $violations = fetch_violations($class_name, $src, {
        require_carping => {
            allow_in_main_unless_in_subroutine => 1,
        }
    });

    is scalar @$violations, 0;
};

done_testing;

