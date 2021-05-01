# SuperCollider

a Raku module that mimics the SuperCollider language


```raku
SynthDef("simple", -> $out, $freq = 800, $sustain = 1, $amp = 0.1 {
  Out.ar($out,
    SinOsc.ar($freq, 0, 0.2) * Line.kr($amp, 0, $sustain, doneAction => Done.freeSelf)
  )
}).add;

my $a = Synth("simple");
```
