
```SuperCollider
SynthDef("sinosc", {
  Out.ar(0, SinOsc.ar())
}).writeDefFile("/tmp");
```

```js
[
  {
    "name": "sinosc",
    "consts": [440, 0],
    "paramValues": [],
    "paramIndices": [],
    "units": [
      ["SinOsc", 2, 0, [[-1, 0], [-1, 1]], [2]],
      ["Out", 2, 0, [[-1, 1], [0, 0]], []]
    ],
    "variants": []
  }
]
```

<hr />

Here we use the `mul:` and `add:` on the `SinOsc`. The seems to mean that we
get a `MulAdd`.

```SuperCollider
SynthDef("test-constants", {
  Out.ar(1, SinOsc.ar(2, 3, 4, 5))
}).writeDefFile("/tmp");
```

```js
[
  {
    "name": "test-constants",
    "consts":
      [2, 3, 4, 5, 1],
    // 0  1  2  3  4  index
    "paramValues": [],
    "paramIndices": [],
    "units": [
      ["SinOsc", 2, 0,
        [[-1, 0], // parameter 0 comes from constant at index 0 which is 2
        [-1, 1]], // parameter 1 comes from constant at index 1 which is 3
        [2]], // one audio-rate output
      ["MulAdd", 2, 0,
        [[0, 0],  // parameter 0 comes from outlet 0 of ugen 0
        [-1, 2],  // parameter 1 comes from constant at index 2 which is 4
        [-1, 3]], // parameter 2 comes from constant at index 3 which is 5
        [2]], // one audio-rate output
      ["Out", 2, 0,
        [[-1, 4], // parameter 0 comes from constant at index 4 which is 1
        [1, 0]],  // parameter 1 comes from outlet 0 of ugen 1
        []] // zero outputs
    ],
    "variants": []
  }
]
```

<hr />

```SuperCollider
SynthDef("abc", {
  | out = 0, modulation |
  Out.ar(out, SinOsc.ar(SinOsc.ar(0.7) + SinOsc.ar(modulation)))
}).writeDefFile("/tmp");
```


```
[
  {
    "name": "abc",
    "consts": [0.699999988079071, 0],
    "paramValues": [0, 0],
    "paramIndices": [
      {"name": "out", "index": 0, "length": 1},
      {"name": "modulation", "index": 1, "length": 1}
    ],
    "units": [
      /* 0 */ ["Control", 1, 0,
        [], // zero inputs
        [1, 1]], // two audio-rate outputs
      /* 1 */ ["SinOsc", 2, 0,
        [[0, 1], // parameter 0 comes from outlet 1 of ugen 0
        [-1, 1]], // second parameter is a constant, 0
        [2]], // one audio-rate output
      /* 2 */ ["SinOsc", 2, 0,
        [[-1, 0], // parameter 0 comes from constant at index 0 which is 0.7
        [-1, 1]], // parameter 1 comes from constant at index 1 which is 0
        [2]], //
      /* 3 */ ["BinaryOpUGen", 2, 0,
        [[2, 0], // parameter 0 comes from outlet 0 of ugen 2
        [1, 0]], // parameter 1 comes from outlet 0 of ugen 1
        [2]],
      /* 4 */ ["SinOsc", 2, 0,
        [[3, 0], // parameter 0 comes from outlet 0 of ugen 3
        [-1, 1]],
        [2]],
      /* 5 */ ["Out", 2, 0,
        [[0, 0],
        [4, 0]],
        []]
    ],
    "variants": []
  }
]
```

```
int32 - index of unit generator or -1 for a constant
if (unit generator index == -1)
  int32 - index of constant
else
  int32 - index of unit generator output
```


<hr />


```SuperCollider
(
SynthDef("diamond-graph", {
	| out, max = 100, n = 300 |
	x = SinOsc.ar(MouseX.kr(1, max));
	a = SinOsc.ar(n * x + 800, 0, 0.1);
	b = PinkNoise.ar(0.1 * x + 0.1);
	Out.ar(out, a + b);
}).writeDefFile("/tmp");
)
```

```js
[
  {
    "name": "diamond-graph",
    "consts": [1, 0, 0.20000000298023224, 800, 0.10000000149011612],
    "paramValues": [0, 100, 300],
    "paramIndices": [
      {"name": "out", "index": 0, "length": 1},
      {"name": "max", "index": 1, "length": 1},
      {"name": "n", "index": 2, "length": 1}
    ],
    "units": [
      ["Control", 1, 0, [], [1, 1, 1]],
      ["MouseX", 1, 0, [[-1, 0], [0, 1], [-1, 1], [-1, 2]], [1]],
      ["SinOsc", 2, 0, [[1, 0], [-1, 1]], [2]],
      ["MulAdd", 2, 0, [[2, 0], [0, 2], [-1, 3]], [2]],
      ["SinOsc", 2, 0, [[3, 0], [-1, 1]], [2]],
      ["MulAdd", 2, 0, [[2, 0], [-1, 4], [-1, 4]], [2]],
      ["PinkNoise", 2, 0, [], [2]],
      ["BinaryOpUGen", 2, 2, [[6, 0], [5, 0]], [2]],
      ["MulAdd", 2, 0, [[4, 0], [-1, 4], [7, 0]], [2]],
      ["Out", 2, 0, [[0, 0], [8, 0]], []]
    ],
    "variants": []
  }
]
```

```txt
00000000: 5343 6766 0000 0002 0001 0d64 6961 6d6f  SCgf.......diamo
00000010: 6e64 2d67 7261 7068 0000 0005 3f80 0000  nd-graph....?...
00000020: 0000 0000 3e4c cccd 4448 0000 3dcc cccd  ....>L..DH..=...
00000030: 0000 0003 0000 0000 42c8 0000 4396 0000  ........B...C...
00000040: 0000 0003 036f 7574 0000 0000 036d 6178  .....out.....max
00000050: 0000 0001 016e 0000 0002 0000 000a 0743  .....n.........C
00000060: 6f6e 7472 6f6c 0100 0000 0000 0000 0300  ontrol..........
00000070: 0001 0101 064d 6f75 7365 5801 0000 0004  .....MouseX.....
00000080: 0000 0001 0000 ffff ffff 0000 0000 0000  ................
00000090: 0000 0000 0001 ffff ffff 0000 0001 ffff  ................
000000a0: ffff 0000 0002 0106 5369 6e4f 7363 0200  ........SinOsc..
000000b0: 0000 0200 0000 0100 0000 0000 0100 0000  ................
000000c0: 00ff ffff ff00 0000 0102 064d 756c 4164  ...........MulAd
000000d0: 6402 0000 0003 0000 0001 0000 0000 0002  d...............
000000e0: 0000 0000 0000 0000 0000 0002 ffff ffff  ................
000000f0: 0000 0003 0206 5369 6e4f 7363 0200 0000  ......SinOsc....
00000100: 0200 0000 0100 0000 0000 0300 0000 00ff  ................
00000110: ffff ff00 0000 0102 064d 756c 4164 6402  .........MulAdd.
00000120: 0000 0003 0000 0001 0000 0000 0002 0000  ................
00000130: 0000 ffff ffff 0000 0004 ffff ffff 0000  ................
00000140: 0004 0209 5069 6e6b 4e6f 6973 6502 0000  ....PinkNoise...
00000150: 0000 0000 0001 0000 020c 4269 6e61 7279  ..........Binary
00000160: 4f70 5547 656e 0200 0000 0200 0000 0100  OpUGen..........
00000170: 0200 0000 0600 0000 0000 0000 0500 0000  ................
00000180: 0002 064d 756c 4164 6402 0000 0003 0000  ...MulAdd.......
00000190: 0001 0000 0000 0004 0000 0000 ffff ffff  ................
000001a0: 0000 0004 0000 0007 0000 0000 0203 4f75  ..............Ou
000001b0: 7402 0000 0002 0000 0000 0000 0000 0000  t...............
000001c0: 0000 0000 0000 0008 0000 0000 0000 0a    ...............
```


```txt
⏿ ./decode-synthdef-file diamond-graph.scsyndef
SynthDef: diamond-graph
  constant: 1.000000 0.000000 0.200000 800.000000 0.100000
  parameter_value: 0.000000 100.000000 300.000000
  parameter_name: out=0.000000 max=100.000000 n=300.000000
  Control.kr 0 kr kr kr
  MouseX.kr 0 -1/0 0/1 -1/1 -1/2 kr
  SinOsc.ar 0 1/0 -1/1 ar
  MulAdd.ar 0 2/0 0/2 -1/3 ar
  SinOsc.ar 0 3/0 -1/1 ar
  MulAdd.ar 0 2/0 -1/4 -1/4 ar
  PinkNoise.ar 0 ar
  BinaryOpUGen.ar 2 6/0 5/0 ar
  MulAdd.ar 0 4/0 -1/4 7/0 ar
  Out.ar 0 0/0 8/0
  variant:
```
