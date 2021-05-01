#!/usr/bin/env raku

use MONKEY-TYPING;

sub mtof($v) { 8.175799 * 2 ** ($v / 12) }

augment class Int { method midicps { mtof self } }
augment class Rat { method midicps { mtof self } }
augment class FatRat { method midicps { mtof self } }
augment class Num { method midicps { mtof self } }
augment class Complex { method midicps { mtof self } }

say mtof 60;
60.midicps.say;
60.001.midicps.say;
60.000000000001.midicps.say; # FatRat?
60e0.midicps.say;
60i.midicps.say;
