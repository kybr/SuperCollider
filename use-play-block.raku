#!/usr/bin/env raku

use lib 'lib';
use SuperCollider;

# {
#   var x = SinOsc.ar(MouseX.kr(1, 100));
#   SinOsc.ar(300 * x + 800, 0, 0.1) +
#       PinkNoise.ar(0.1 * x + 0.1)
# }.play;
#


# this snippet serves as an example of
# - using the {;}.play sugar
# - SinOsc, MouseX, and PinkNoise
# - BinaryOpUGen on * and +
# - minimal graph; has diamond. not just a tree
{
  {
    my $x = SinOsc.ar(MouseX.kr(1, 100));
    SinOsc.ar(300 * $x + 800, 0, 0.1) +
        PinkNoise.ar(0.1 * $x + 0.1)
  }.play;
}

# here's the thing with sigil-less "variables"
# {
#   {
#     my \x = SinOsc.ar(MouseX.kr(1, 100));
#     SinOsc.ar(300 * x + 800, 0, 0.1) +
#         PinkNoise.ar(0.1 * x + 0.1)
#   }.play;
# }