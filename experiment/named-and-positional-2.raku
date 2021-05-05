#!/usr/bin/env raku

# the arguments of a SuperCollider function are both named and positional
# or so it seems when you look at how they are _called_.

# named parameters
multi power(:$base, :$exponent) {
  return $base ** $exponent;
}

# position parameters
multi power($base, $exponent) {
  return $base ** $exponent;
}

# catch all with a Capture
multi power(|c) {
  "got here"
}

say power base => 2, exponent => 7;  
say power 2, 7;  
say power 2, exponent => 7;  
