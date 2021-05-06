# SuperCollider

a [Raku][] client for the [SuperCollider][] server.


```Raku
use SuperCollider;

{
SynthDef("simple", -> $out, $freq = 800, $sustain = 1, $amp = 0.9 {
  Out.ar($out,
    SinOsc.ar($freq, 0, 0.2) * Line.kr($amp, 0, $sustain, doneAction => Done.freeSelf)
  )
}).add;

my $a = Synth("simple");

{
  my $x = SinOsc.ar(MouseX.kr(1, 100));
  SinOsc.ar(300 * $x + 800, 0, 0.1)
  +
  PinkNoise.ar(0.1 * $x + 0.1)
}.play;
}
```

or

```Raku
{
add synthdef "simple", -> $out, $freq = 800, $sustain = 1, $amp = 0.9 {
  Out.ar: $out, SinOsc.ar($freq, 0, 0.2) * Line.kr($amp, 0, $sustain, doneAction => Done.freeSelf)
};

my $a = synth "simple";

play {
  my $x = SinOsc.ar: MouseX.kr(1, 100);
  SinOsc.ar(300 * $x + 800, 0, 0.1)
  +
  PinkNoise.ar(0.1 * $x + 0.1)
}
}
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

{
  var x = SinOsc.ar(MouseX.kr(1, 100));
  SinOsc.ar(300 * x + 800, 0, 0.1)
  +
  PinkNoise.ar(0.1 * x + 0.1)
}.play;
)
```


Where the [SuperCollider][] syntax cannot be or should not be mimicked, we chose a reasonable way to do it the [Raku][] way.


## Why?

This is a fun experiment. Learning [Raku][], I noticed that it has syntax (and a flexibility of syntax) in common with [SuperCollider][]. The two languages feature sets overlap to some degree.

My hunch is that [SuperCollider][] user code with minimal changes will compile and run as [Raku][]. I do not intend to complete the entire SuperCollider class/type system, just the unit generators, SynthDef, Synth, and code that supports them.

I admire the capabilities of [SuperCollider][], but I would much rather invest my time and effort on [Raku][].



## Status

Everything is stubs. It "runs" but it does not do anything useful. It is currently just a way to expose the similarities and differencies between [Raku][] and [SuperCollider][].


## Notes

It is necessary to [augment](https://docs.raku.org/syntax/augment) Block in order to get the frequently-used `{...}.play` syntax. Also, serveral useful functions are methods of numbers (e.g., `60.midicps`) and those must be injected as well.


#### positional after optional

```Raku
my $graph = -> $out, $freq = 440, $dur = 0.5, $amp = 0.6 { };
```

> Cannot put positional parameter $dur after an optional parameter

Comma gives us this linting message. 
We get the error above when writing the unit generator graph function (UGGF?) we hand to the SynthDef. This is fine (I think) because the default values are there to be 






[Raku]: https://raku.org/
[SuperCollider]: https://supercollider.github.io/

