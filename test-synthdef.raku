#!/usr/bin/env raku

use lib 'lib';
use SuperCollider;

{
SynthDef("simple", -> $out, $freq = 800, $sustain = 1, $amp = 0.9 {
  Out.ar($out,
    SinOsc.ar($freq, 0, 0.2) * Line.kr($amp, 0, $sustain, doneAction => Done.freeSelf)
  )
}).add.svg;

my $a = Synth("simple");
}

# let's test sigil-less arguments; seems to work for this example
{
  SynthDef("simple", -> \out, \freq = 800, \sustain = 1, \amp = 0.9 {
    Out.ar(out,
        SinOsc.ar(freq, 0, 0.2) * Line.kr(amp, 0, sustain, doneAction => Done.freeSelf)
        )
  }).add.svg;

  my \a = Synth("simple");
}
