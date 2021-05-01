#!/usr/bin/env raku

use MONKEY-TYPING;

augment class Int {
  method is-answer { self == 42 }
}
say 42.is-answer;

augment class Block {
  method play { "got here".say }
}

{;}.play;
