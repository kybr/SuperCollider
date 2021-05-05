#!/usr/bin/env raku

# SuperCollider's SynthDef captures the ugen graph functions parameter names and values
# for later use. Can Raku do that? Probably. We need introspection.

# Question:
# Given a block with positional (or named) arguments with default values,
# - can i extract their names?
# - and their order?
# - and default values?
# - and their named-ness or positional-ness?
# and moreover, can we call the block using...
# - named parameters?

# this is not a thing. it's an error. that's not how you *declare* named parameters
# my $named = -> out => 0, freq => 800, sustain => 1, amp => 0.9 { };
# that's how you *pass* named parameters.

sub show-signature($s) {
  # https://docs.raku.org/type/Parameter
  # https://docs.raku.org/type/Signature
  for $s.params {
    .usage-name.say;
    "positional".say if .positional;
    "named".say if .named;
    "default value is { .default.() } ".say;
    "==========================================".say;
  }
}

{
  # anonymous sub
  my &f = sub ($x = 1, $y = 1) {
    $x ** 2 + $y ** 2
  };
  show-signature &f.signature;
  say f 2, 2;
  # say f :2x, :2y; # does not work
  " . . . . . . . . . . . . . ".say;
}

{
  # anonymous sub
  my &f = sub (:$x = 1, :$y = 1) {
    $x ** 2 + $y ** 2
  };
  show-signature &f.signature;
  # say f 2, 2; # does not work!
  say f :2x, :2y;
  " . . . . . . . . . . . . . ".say;
}

{
  # pointy block
  my &f = -> $x = 1, $y = 1 {
    $x ** 2 + $y ** 2
  };
  show-signature &f.signature;
  say f 2, 2;
  #say f :2x, :2y;
  " . . . . . . . . . . . . . ".say;
}

{
  # pointy block with named parameter with default value
  my &f = -> :$x = 1, :$y = 1 {
    $x ** 2 + $y ** 2
  };
  show-signature &f.signature;
  # say f 2, 2; # does not work
  say f :2x, :2y;
  " . . . . . . . . . . . . . ".say;
}

# > Cannot put positional parameter $dur after an optional parameter
my $graph = -> $out, $freq = 440, $dur = 0.5, $amp = 0.6 { };