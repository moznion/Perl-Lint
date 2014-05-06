use strict;
for my $foo (@list) { do_something() }
foreach my $foo (@list) { do_something() }
while (my $foo $condition) { do_something() }
until (my @foo = ($condition)) {
    {
        method => do_something(),
    }
}
unless (my $foo = $condition) { do_something() }
if (my $foo = $condition) { do_something() }
# these are terrible uses of "if" but do not violate the policy
my $foo = $hash{if};
my $foo = $obj->if();
