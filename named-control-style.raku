#!/usr/bin/env raku

use lib 'lib';
use SuperCollider;

# https://doc.sccode.org/Classes/NamedControl.html
# - we don't have to specify a formal argument list
# - we use two chars ($^) instead of the one (\) that SuperCollider uses
#
{
SynthDef("simple", {
  Out.ar($^out.ar,
    SinOsc.ar($^freq.kr(800), 0, 0.2) *
    Line.kr($^amp.kr(0.9), 0, $^sustain.kr(1), doneAction => Done.freeSelf)
  )
}).add.svg;

my $a = Synth("simple");
}

#`[
(
SynthDef("simple", {
  Out.ar(\out.ar,
          SinOsc.ar(\freq.kr(800), 0, 0.2) * Line.kr(\amp.kr(0.9), 0, \sustain.kr(1), doneAction: Done.freeSelf)
            )
  }).add;

a = Synth("simple");
)
]
