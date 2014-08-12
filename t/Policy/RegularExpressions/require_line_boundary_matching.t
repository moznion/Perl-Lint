use strict;
use warnings;
use Perl::Lint::Policy::RegularExpressions::RequireLineBoundaryMatching;
use t::Policy::Util qw/fetch_violations/;
use Test::Base::Less;

my $class_name = 'RegularExpressions::RequireLineBoundaryMatching';

filters {
    params => [qw/eval/],
};

for my $block (blocks) {
    my $violations = fetch_violations($class_name, $block->input, $block->params);
    is scalar @$violations, $block->failures, $block->dscr;
}

done_testing;

__DATA__

===
--- dscr: basic passes
--- failures: 0
--- params:
--- input
my $string =~ m{pattern}m;
my $string =~ m{pattern}gimx;
my $string =~ m{pattern}gmis;
my $string =~ m{pattern}mgxs;

my $string =~ m/pattern/m;
my $string =~ m/pattern/gimx;
my $string =~ m/pattern/gmis;
my $string =~ m/pattern/mgxs;

my $string =~ /pattern/m;
my $string =~ /pattern/gimx;
my $string =~ /pattern/gmis;
my $string =~ /pattern/mgxs;

my $string =~ s/pattern/foo/m;
my $string =~ s/pattern/foo/gimx;
my $string =~ s/pattern/foo/gmis;
my $string =~ s/pattern/foo/mgxs;

my $re = qr/pattern/m;

===
--- dscr: basic failures
--- failures: 17
--- params:
--- input
my $string =~ m{pattern};
my $string =~ m{pattern}gix;
my $string =~ m{pattern}gis;
my $string =~ m{pattern}gxs;

my $string =~ m/pattern/;
my $string =~ m/pattern/gix;
my $string =~ m/pattern/gis;
my $string =~ m/pattern/gxs;

my $string =~ /pattern/;
my $string =~ /pattern/gix;
my $string =~ /pattern/gis;
my $string =~ /pattern/gxs;

my $string =~ s/pattern/foo/;
my $string =~ s/pattern/foo/gix;
my $string =~ s/pattern/foo/gis;
my $string =~ s/pattern/foo/gxs;

my $re = qr/pattern/;

===
--- dscr: tr and y checking
--- failures: 0
--- params:
--- input
my $string =~ tr/[A-Z]/[a-z]/;
my $string =~ tr|[A-Z]|[a-z]|;
my $string =~ tr{[A-Z]}{[a-z]};

my $string =~ y/[A-Z]/[a-z]/;
my $string =~ y|[A-Z]|[a-z]|;
my $string =~ y{[A-Z]}{[a-z]};

my $string =~ tr/[A-Z]/[a-z]/cds;
my $string =~ y/[A-Z]/[a-z]/cds;

===
--- dscr: use re '/m' - RT #72151
--- failures: 0
--- params:
--- input
use re '/m';
my $string =~ m{pattern.};

===
--- dscr: use re "/m"
--- failures: 0
--- params:
--- input
use re "/m";
my $string =~ m{pattern.};

===
--- dscr: use re qw{ /m } - RT #72151
--- failures: 0
--- params:
--- input
use re qw{ /m };
my $string =~ m{pattern.};

===
--- dscr: use re qw{ /m } not in scope - RT #72151
--- failures: 2
--- params:
--- input
{
    {
        {
            use re qw{ /m };
            my $string =~ m{pattern.};
            {
                my $string =~ m{pattern.};
            }
        }
    }
    my $string =~ m{pattern.};
}
my $string =~ m{pattern.};

===
--- dscr: no re qw{ /m } - RT #72151
--- failures: 1
--- params:
--- input
use re qw{ /smx };
{
    no re qw{ /m };
    {
        use re qw{ /smx };
        my $string =~ m{pattern.};
    }
    my $string =~ m{pattern.};
}
my $string =~ m{pattern.};

