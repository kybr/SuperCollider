#!/usr/bin/env raku

#`[
my class Parent {
  method show {
    # self.defaults.signature # this does not work
  }
}

my class Child is Parent {
    method defaults($a, $b = 2, :$c = 3) {}
}
]

# from raydiak on #raku on freenode
class Parent {
  method show {
    self.WHAT.^methods.first(*.name eq "defaults").signature
  }
}

class Child is Parent {
  proto defaults ($a, $b = 2, :$c = 3) {}
}

Child.show.say;