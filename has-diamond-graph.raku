#!/usr/bin/env raku

use lib 'lib';
use SuperCollider;

{
  my $s = SynthDef("has-diamond-graph", -> $out {
    my $x = SinOsc.ar(MouseX.kr(1, 100));
    my $a = SinOsc.ar(300 * $x + 800, 0, 0.1);
    my $b = PinkNoise.ar(0.1 * $x + 0.1);
    Out.ar($out, $a + $b);
  });

  $s.add.svg;
}
