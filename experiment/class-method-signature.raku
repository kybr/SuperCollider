#!/usr/bin/env raku

my class Foo {
  proto foo($this, :$that) { }
  method bar { &foo.signature }
}

Foo.bar.say;

my class Parent {
    method stuff(|c) {}
}

my class Child is Parent {
    proto defaults($a, $b = 2, :$c = 3) {}
    method stuff(|c) {}
}
