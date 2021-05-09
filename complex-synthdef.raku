#!/usr/bin/env raku

use lib 'lib';
use SuperCollider;

# https://madskjeldgaard.dk/supercollider-tutorial-mass-producing-synthdefs/
my $bufplayerfunc = -> $numchans = 1 {
  # XXX have to put all required parameters first
  -> $buffer, $rate=1, $trigger=1, $start=0, $loop=0, $amp=1, $out=0 {
    # Buffer player
    my $sig = PlayBuf.ar(
            $numchans, # Number of channels passed into the function from the outer function
            $buffer,
            $rate * BufRateScale.kr($buffer),
            $trigger,
            $start * BufDur.kr($buffer),
            $loop
            );

    # Output
    Out.ar($out, $sig * $amp);
  }
};

for 1..64 -> $chan-num {
  my $name = "bufplayer" ~ $chan-num;
  SynthDef($name, $bufplayerfunc($chan-num)).add
}

SynthDef("bufplayer0", $bufplayerfunc(0)).add.svg;
