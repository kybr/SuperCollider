#!/usr/bin/env raku

use lib 'lib';
use SuperCollider;

SynthDef("help", -> $out {
  Out.ar($out, SinOsc.ar(rrand(400, 800), 0, 0.2) * Line.kr(1, 0, 1, doneAction => Done.freeSelf))
}).add;

SynthDef("withargs", -> $out, $freq = 800, $sustain = 1, $amp = 0.1 {
  Out.ar($out,
    SinOsc.ar($freq, 0, 0.2) * Line.kr($amp, 0, $sustain, doneAction => Done.freeSelf)
  )
}).add;

my $a = Synth("help");
my $b = Synth("withargs");
