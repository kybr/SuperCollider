module SuperCollider {

#| http://doc.sccode.org/Classes/Object.html
role Object { }
#= https://github.com/supercollider/supercollider/blob/develop/SCClassLibrary/Common/Core/Object.sc

#| http://doc.sccode.org/Classes/AbstractFunction.html
role AbstractFunction does Object { }
#= https://github.com/supercollider/supercollider/blob/develop/SCClassLibrary/Common/Core/AbstractFunction.sc

#| https://doc.sccode.org/Classes/UGen.html
class UGen does AbstractFunction { }
#= https://github.com/supercollider/supercollider/blob/develop/SCClassLibrary/Common/Audio/UGen.sc

# recipe for building a synth
#
class SynthDef is export {
  has Str $.name;  # the name of this definition
  has Block $.graph; # execute to construct an audio graph

  # make is so you can construct with a simple SynthDef(...)
  #
  method CALL-ME($name, $graph) {
    SynthDef.new: :$name, :$graph
  }

  method compileDataStructure {
    # Use the given graph (a Raku Block) to construct a SynthDef data structure.
    # It is a binary format described here:
    #   https://doc.sccode.org/Reference/Synth-Definition-File-Format.html
    # We might do this by executing the given block and inspecting the result or
    # perhaps we can use introspection to inspect the given block and build the
    # binary from that. How does SuperCollider do it? What is the more Raku way
    # to do it? Perhaps a Grammar?

    # https://en.wikipedia.org/wiki/Topological_sorting

    my $buf = buf8.new(3, 6, 254);

    self.raku.say;
    say $!name;

    # fail if $graph does not return a Node? Array?
    $!graph.returns.say;

    # note the signature of the graph; we need that to design the proxy object
    $!graph.signature.raku.say;

  }

  method add {
    "calling the synthdef graph...".say;

    say $!graph.raku;
    say $!graph(0); # call the graph

    # this should maybe...
    # - return a binary data structure
    # - code-gen a per-sample function
    # - ?

    self
  }
}

multi add(SynthDef $s) is export {
  $s.add
}

sub synthdef($name, $graph) is export {
  SynthDef($name, $graph)
}


# a proxy object for a server instance
#
class Synth is export {
  has Str $.name;

# https://doc.sccode.org/Classes/Synth.html

  method CALL-ME($name) {
    Synth.new: :$name
  }

  submethod BUILD(:$name) {
    "Synth.new".say;
  }
}

sub synth($name) is export {
  Synth($name)
}

#
# Unit Generators
#

sub controls(Signature $signature, Capture $capture) {
  my %hash;

  # the names and defaults
  for $signature.params {
    if .default ~~ Block {
      %hash{.usage-name} = .default.();
    }
  }

  for $capture.pairs {
    if .key ~~ Int {
      %hash{ $signature.params[.key].usage-name } = .value
    }
    if .key ~~ Str {
      %hash{ .key } = .value
    }
  }

  %hash
}


#| https://doc.sccode.org/Classes/Out.html
class Out is UGen is export {
  proto defaults($bus, $channelsArray) { }
  method ar(|capture) { ('Out', 'ar', controls(&defaults.signature, capture)) }
  method kr(|capture) { ('Out', 'kr', controls(&defaults.signature, capture)) }
}

#| https://doc.sccode.org/Classes/SinOsc.html
class SinOsc is UGen is export {
  proto defaults($freq = 440.0, $phase = 0.0, $mul = 1.0, $add = 0.0) { }
  method ar(|capture) { ('SinOsc', 'ar', controls(&defaults.signature, capture)) }
  method kr(|capture) { ('SinOsc', 'kr', controls(&defaults.signature, capture)) }
}


#| https://doc.sccode.org/Classes/Line.html
class Line is UGen is export {
  proto defaults($start = 0.0, $end = 1.0, $dur = 1.0, $mul = 1.0, $add = 0.0, $doneAction = 0) { }
  method ar(|capture) { ('Line', 'ar', controls(&defaults.signature, capture)) }
  method kr(|capture) { ('Line', 'kr', controls(&defaults.signature, capture)) }
}


#| http://doc.sccode.org/Classes/MouseX.html
class MouseX is UGen is export {
  proto defaults($minval = 0, $maxval = 1, $warp = 0, $lag = 0.2) { }
  method kr(|capture) { ('MouseX', 'kr', controls(&defaults.signature, capture)) }
}


#| http://doc.sccode.org/Classes/PinkNoise.html
class PinkNoise is UGen is export {
  proto defaults($mul = 0, $add = 0.2) { }
  method ar(|capture) { ('PinkNoise', 'ar', controls(&defaults.signature, capture)) }
  method kr(|capture) { ('PinkNoise', 'kr', controls(&defaults.signature, capture)) }
}

#| http://doc.sccode.org/Classes/Done.html
class Done is UGen is export {
  method none { ('Done', 0) } #do nothing when the UGen is finished
  method pauseSelf { ('Done', 1) } #pause the enclosing synth, but do not free it
  method freeSelf { ('Done', 2) } #free the enclosing synth
  method freeSelfAndPrev { ('Done', 3) } #free both this synth and the preceding node
  method freeSelfAndNext { ('Done', 4) } #free both this synth and the following node
  method freeSelfAndFreeAllInPrev { ('Done', 5) } #free this synth; if the preceding node is a group then do g_freeAll on it, else free it
  method freeSelfAndFreeAllInNext { ('Done', 6) } #free this synth; if the following node is a group then do g_freeAll on it, else free it
  method freeSelfToHead { ('Done', 7) } #free this synth and all preceding nodes in this group
  method freeSelfToTail { ('Done', 8) } #free this synth and all following nodes in this group
  method freeSelfPausePrev { ('Done', 9) } #free this synth and pause the preceding node
  method freeSelfPauseNext { ('Done', 10) } #free this synth and pause the following node
  method freeSelfAndDeepFreePrev { ('Done', 11) } #free this synth and if the preceding node is a group then do g_deepFree on it, else free it
  method freeSelfAndDeepFreeNext { ('Done', 12) } #free this synth and if the following node is a group then do g_deepFree on it, else free it
  method freeAllInGroup { ('Done', 13) } #free this synth and all other nodes in this group (before and after)
  method freeGroup { ('Done', 14) } #free the enclosing group and all nodes within it (including this synth)
  method freeSelfResumeNext { ('Done', 15) } #free this synth and resume the following node
}


#
# handling operators among Nodes
#

class BinaryOpUGen is UGen is export {
  proto defaults($selector, $a, $b) { }
  method make(|capture) { ('BinaryOpUGen', '??', controls(&defaults.signature, capture)) }
}


multi sub infix:<*>(UGen $a, UGen $b --> BinaryOpUGen) is export {
  BinaryOpUGen.make('*', $a, $b)
}

multi sub infix:<*>(Numeric $a, UGen $b --> BinaryOpUGen) is export {
  BinaryOpUGen.make('*', $a, $b)
}

multi sub infix:<*>(UGen $a, Numeric $b --> BinaryOpUGen) is export {
  BinaryOpUGen.make('*', $a, $b)
}

multi sub infix:<+>(UGen $a, UGen $b --> BinaryOpUGen) is export {
  BinaryOpUGen.make('*', $a, $b)
}

multi sub infix:<+>(Numeric $a, UGen $b --> BinaryOpUGen) is export {
  BinaryOpUGen.make('*', $a, $b)
}

multi sub infix:<+>(UGen $a, Numeric $b --> BinaryOpUGen) is export {
  BinaryOpUGen.make('*', $a, $b)
}


#
# functions
#

multi rrand($low, $high) is export {
  return ($high - $low).rand + $low;
}

multi rrand($high = 1) is export {
    $high.rand
}


#
# add sugar!
#

use MONKEY-TYPING;

augment class Block {

  # in SuperCollider {...}.play
  # 1. creates a SynthDef
  # 2. creates a Synth
  # 3. plays that Synth
  #
  method play {
    "play called".say;

    # 1. evaluate the block
    my $t = self.();

    # 2. check the return type
    if $t ~~ UGen {
      "we got a Node".say
    }

    # 3. ?
  }

  # in SuperCollider you can call .value or value(...) on basically anything
  # on a function, it's like calling that function
  #
  method value {
    
  }
}


}
