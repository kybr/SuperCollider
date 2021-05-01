# SuperCollider

a [Raku][] module that mimics the [SuperCollider][] language


```Raku
use lib 'lib';
use SuperCollider;


SynthDef("simple", -> $out, $freq = 800, $sustain = 1, $amp = 0.9 {
  Out.ar($out,
    SinOsc.ar($freq, 0, 0.2) * Line.kr($amp, 0, $sustain, doneAction => Done.freeSelf)
  )
}).add;

my $a = Synth("simple");
```

Compare that to the [SuperCollider][] user code:

```SuperCollider
(
SynthDef(\simple, { |out, freq = 800, sustain = 1, amp = 0.9|
  Out.ar(out,
    SinOsc.ar(freq, 0, 0.2) * Line.kr(amp, 0, sustain, doneAction: Done.freeSelf)
  )
}).add;

a = Synth(\simple);
)
```



Where the [SuperCollider][] syntax cannot be or should not be mimicked, we chose a reasonable way to do it the [Raku][] way.


## Why?

This is a fun experiment. Learning [Raku][], I noticed that it has syntax (and a flexibility of syntax) in common with [SuperCollder][]. The two languages feature sets overlap to some degree.

My hunch is that [SuperCollider][] user code with minimal changes will compile and run as [Raku][]. I do not intend to complete the entire SuperCollider class/type system, just the unit generators, SynthDef, Synth, and code that supports them.

I admire the capabilities of [SuperCollider][], but I would much rather invest my time and effort on [Raku][].



## Status

Everything is stubs. It "runs" but it does not do anything useful. It is currently just a way to expose the similarities and differencies between [Raku][] and [SuperCollider][].



[Raku]: https://raku.org/
[SuperCollider]: https://supercollider.github.io/

