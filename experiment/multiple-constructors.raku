#!/usr/bin/env raku

# https://docs.raku.org/type/Capture
# https://docs.raku.org/type/Signature

class Ugen { }

multi handle(Ugen $g, Str $rate, Capture $capture, Signature $signature) {
  # build a hash of sources. use the sources proto above to map
  # positional arguments to names and to validate named arguments.
  ($g.^name, $rate, $capture.pairs, $signature)
}

class SinOsc is Ugen {
  # the signature of this proto encodes the names, order, and default
  # values of the controls of this generator. use it to validate captures.
  proto defaults($freq = 440.0, $phase = 0.0, $mul = 1.0, $add = 0.0) { }

  method ar(|capture) { handle self, 'ar', capture, &defaults.signature}
  method kr(|capture) { handle self, 'kr', capture, &defaults.signature}
}

my $s = SinOsc.ar: 880, mul => 0.1;
say $s.raku;

my $z = SinOsc.kr: mul => 0.1, 800;
say $z.raku;