#!/usr/bin/env raku

class Foo {
  proto foo($this, :$that) { }
  method bar { &foo.signature }
}

Foo.bar.say
