#!/usr/bin/env qjs

// minimal prelude to run; totally non-functional. we return numbers from ugens to 
// avoid the problem of operator overloading, but it will be a problem.
//

let SynthDef = (name, block) => {
  return {add: () => {}} // a thing on which we may call add
}

let Out = {
  ar: (bus, synth) => { return 0 }
}

let SinOsc = {
  ar: (freq, phase = 0, mul = 1, add = 0) => { return 0 }
}

let Line = {
  kr: (start = 0.0, end = 1.0, dur = 1.0, object = {}) => { return 0 }
}

let Done = { freeSelf: 0 }
let Synth = (name) => {}

// SuperCollider-like code
//
{
SynthDef("simple", (out, freq = 800, sustain = 1, amp = 0.9) => {
  return Out.ar(out,
    SinOsc.ar(freq, 0, 0.2) * Line.kr(amp, 0, sustain, {doneAction: Done.freeSelf})
  )
}).add();

a = Synth("simple");
}
