#!/usr/bin/env raku

my $capture = \(1, 2, 3, four => 5, six => 7);

sub does-capture (|capture) { capture.raku; }
sub does-pass ($capture) { $capture.raku; }
class Foo {
  method does-capture(|capture) { capture.raku }
  method does-pass($capture) { $capture.raku }
}

say does-capture $capture; # capture of a capture
say does-pass $capture; # capture
say does-capture |$capture; # capture
#say does-pass |$capture; # Too many positionals passed; expected 1 argument but got 3
#Foo.does-capture $capture; # does not work; methods seem to require ()
#Foo.does-pass $capture; # does not work; methods seem to require ()
say Foo.does-capture($capture); # capture of a capture
say Foo.does-pass($capture);  # capture
say Foo.does-capture |$capture; # WRONG; interpreted as a junction
#say Foo.does-pass |$capture; # Too few positionals passed; expected 2 arguments but got 1
say Foo.does-capture(|$capture); # capture
#say Foo.does-pass(|$capture); # Too many positionals passed; expected 2 arguments but got 4


