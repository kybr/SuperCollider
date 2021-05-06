#!/usr/bin/env raku

sub thing($this, :$that = 5) { }

&thing.signature.say;
\(&thing.signature).say;

# my $c = Capture.new: &thing.signature.hash;
# $c.say;

# from lizmat on #raku on freenode
#my $c = Capture.new(list => (42,666));
#sub a(|c) { dd c };
#a |$c;
my $c = Capture.new(list => (42,666), hash => { a => "foo", b => "bar" });
sub a(|c) { dd c };
a |$c; # also with nameds
a(|$c); # also with nameds
