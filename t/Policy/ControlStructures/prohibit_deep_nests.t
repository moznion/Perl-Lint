use strict;
use warnings;
use Perl::Lint::Policy::ControlStructures::ProhibitDeepNests;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'ControlStructures::ProhibitDeepNests';

filters {
    params => [qw/eval/], # TODO wrong!
};

for my $block (blocks) {
    my $violations = fetch_violations($class_name, $block->input, $block->params);
    is scalar @$violations, $block->failures, $block->dscr;
}

done_testing;

__DATA__

===
--- dscr: 6 for loops
--- failures: 1
--- params:
--- input
for $element1 ( @list1 ) {
    foreach $element2 ( @list2 ) {
        for $element3 ( @list3 ) {
            foreach $element4 ( @list4 ) {
               for $element5 ( @list5 ) {
                  for $element6 ( @list6 ) {
                  }
               }
            }
        }
    }
}

===
--- dscr: 6 if blocks
--- failures: 1
--- params:
--- input
if ($condition1) {
  if ($condition2) {
    if ($condition3) {
      if ($condition4) {
        if ($condition5) {
          if ($condition6) {
          }
        }
      }
    }
  }
}

===
--- dscr: 6 if blocks, not nested
--- failures: 0
--- params:
--- input
if ($condition1) {
  if ($condition2) {}
  if ($condition3) {}
  if ($condition4) {}
  if ($condition5) {}
  if ($condition6) {}
}

===
--- dscr: 6 for loops, not nested
--- failures: 0
--- params:
--- input
for     $element1 ( @list1 ) {
  foreach $element2 ( @list2 ) {}
  for     $element3 ( @list3 ) {}
  foreach $element4 ( @list4 ) {}
  for     $element5 ( @list5 ) {}
  foreach $element6 ( @list6 ) {}
}

===
--- dscr: 6 mixed nests
--- failures: 1
--- params:
--- input
if ($condition) {
  foreach ( @list ) {
    until ($condition) {
      for (my $i=0; $<10; $i++) {
        if ($condition) {
          while ($condition) {
          }
        }
      }
    }
  }
}

is( pcritique($policy, \$code), 1, '');

===
--- dscr: Configurable
--- failures: 0
--- params: {prohibit_deep_nests => {max_nests => 6}}
--- input
if ($condition) {
  foreach ( @list ) {
    until ($condition) {
      for (my $i=0; $<10; $i++) {
        if ($condition) {
          while ($condition) {
          }
        }
      }
    }
  }
}

===
--- dscr: With postfixes
--- failures: 0
--- params:
--- input
if ($condition) {
    s/foo/bar/ for @list;
    until ($condition) {
      for (my $i=0; $<10; $i++) {
          die if $condition;
        while ($condition) {
        }
      }
   }
}

===
--- dscr: 5 if blocks and one hash access
--- failures: 0
--- params:
--- input
if ($condition1) {
  if ($condition2) {
    if ($condition3) {
      if ($condition4) {
        if ($condition5) {
            $foo{bar};
        }
      }
    }
  }
}

===
--- dscr: 5 if blocks and one hash reference access
--- failures: 0
--- params:
--- input
if ($condition1) {
  if ($condition2) {
    if ($condition3) {
      if ($condition4) {
        if ($condition5) {
            $foo->{bar};
        }
      }
    }
  }
}

===
--- dscr: 5 if blocks and one eval block
--- failures: 0
--- params:
--- input
if ($condition1) {
  if ($condition2) {
    if ($condition3) {
      if ($condition4) {
        if ($condition5) {
            eval { print "hello" };
        }
      }
    }
  }
}

===
--- dscr: 5 if blocks and one anon sub block
--- failures: 0
--- params:
--- input
if ($condition1) {
  if ($condition2) {
    if ($condition3) {
      if ($condition4) {
        if ($condition5) {
            my $foo = sub {
            };
        }
      }
    }
  }
}
