#!/usr/bin/env raku

use lib 'lib';
use SuperCollider;

# {
#   var x = SinOsc.ar(MouseX.kr(1, 100));
#   SinOsc.ar(300 * x + 800, 0, 0.1) +
#       PinkNoise.ar(0.1 * x + 0.1)
# }.play;
#
#{
#  {
#    my $x = SinOsc.ar(MouseX.kr(1, 100));
#    SinOsc.ar(300 * $x + 800, 0, 0.1) +
#        PinkNoise.ar(0.1 * $x + 0.1)
#  }.play;
#}

{
  {
    my \x = SinOsc.ar(MouseX.kr(1, 100));
    SinOsc.ar(300 * x + 800, 0, 0.1) +
        PinkNoise.ar(0.1 * x + 0.1)
  }.play;
}