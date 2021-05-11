#!/usr/bin/env raku

use Test;
use lib 'lib';

use SuperCollider;

plan 1;

dies-ok {
  my $x = MouseX.ar(1, 100);
}

done-testing;
