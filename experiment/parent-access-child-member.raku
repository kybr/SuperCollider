#!/usr/bin/env raku

class Parent {
  method show {
    self.inputs
  }
}

class Child is Parent {
  method inputs { :($a, $b = 2, :$c = 3) }
}

Child.show.say;
