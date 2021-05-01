#!/usr/bin/env raku

#use trace;
use lib 'lib';
use SuperCollider;

# (
# SynthDef(\simple, { |out, freq = 800, sustain = 1, amp = 0.9|
#   Out.ar(out,
#     SinOsc.ar(freq, 0, 0.2) * Line.kr(amp, 0, sustain, doneAction: Done.freeSelf)
#   )
# }).add;
# 
# a = Synth(\simple);
# )
#
{
SynthDef("simple", -> $out, $freq = 800, $sustain = 1, $amp = 0.9 {
  Out.ar($out,
    SinOsc.ar($freq, 0, 0.2) * Line.kr($amp, 0, $sustain, doneAction => Done.freeSelf)
  )
}).add;

my $a = Synth("simple");
}

say "==========================================================================";

# {
#   var x = SinOsc.ar(MouseX.kr(1, 100));
#   SinOsc.ar(300 * x + 800, 0, 0.1)
#   +
#   PinkNoise.ar(0.1 * x + 0.1)
# }.play;
#
{
{
  my $x = SinOsc.ar(MouseX.kr(1, 100));
  SinOsc.ar(300 * $x + 800, 0, 0.1)
  +
  PinkNoise.ar(0.1 * $x + 0.1)
}.play;
}

say "==========================================================================";



# { ({RHPF.ar(OnePole.ar(BrownNoise.ar, 0.99), LPF.ar(BrownNoise.ar, 14)
# * 400 + 500, 0.03, 0.003)}!2)
# + ({RHPF.ar(OnePole.ar(BrownNoise.ar, 0.99), LPF.ar(BrownNoise.ar, 20)
# * 800 + 1000, 0.03, 0.005)}!2) }.play
