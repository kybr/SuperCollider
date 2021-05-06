module SuperCollider {

#| http://doc.sccode.org/Classes/Object.html
role Object { }
#= https://github.com/supercollider/supercollider/blob/develop/SCClassLibrary/Common/Core/Object.sc

#| http://doc.sccode.org/Classes/AbstractFunction.html
role AbstractFunction does Object { }
#= https://github.com/supercollider/supercollider/blob/develop/SCClassLibrary/Common/Core/AbstractFunction.sc

#| https://doc.sccode.org/Classes/UGen.html
class UGen {
    has $.name;
    has $.value;
    has $.rate; # simple numbers have rate 'ir'?
    #has $.position; # ???
    has %.inputs; # no inputs or simple number inputs means leaf node
}
#= https://github.com/supercollider/supercollider/blob/develop/SCClassLibrary/Common/Audio/UGen.sc

#| https://doc.sccode.org/Classes/Control.html
#| https://doc.sccode.org/Classes/AudioControl.html
#| https://doc.sccode.org/Classes/NamedControl.html
class Control is UGen { }


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

    # fail if graph does not return a Node? Array?
    $!graph.returns.say;

    # note the signature of the graph; we need that to design the proxy object
    $!graph.signature.raku.say;

    # this should maybe...
    # - return a binary data structure
    # - code-gen a per-sample function
    # - ?

  }

  method add {
    "calling the synthdef graph...".say;

    #say $!graph.raku;
    my %hash;
    my @list;
    for $!graph.signature.params {
        if .positional {
           @list.push: Control.new(
                   :name(.usage-name),
                   :value(.default ~~ Block ?? .default.() !! Any));
        }
        elsif .named {
            %hash{.usage-name} = Control.new(
                    :name(.usage-name),
                    :value(.default ~~ Block ?? .default.() !! Any));
        }
    }
    my $capture = Capture.new: :@list, :%hash;
    $capture.raku.say;
    my $structure = $!graph(|$capture); # call the graph
    say $structure;

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

sub inputs(Signature $signature, Capture $capture) {
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

sub ugen($name, $rate, :$value, :%inputs) {
    UGen.new: :$name, :$rate, :$value, :%inputs
}

#| https://doc.sccode.org/Classes/Out.html
class Out is UGen is export {
  proto defaults($bus, $channelsArray) { }
  method ar(|capture) { ugen('Out', 'ar', inputs => inputs(&defaults.signature, capture)) }
  method kr(|capture) { ugen('Out', 'kr', inputs => inputs(&defaults.signature, capture)) }
}

#| https://doc.sccode.org/Classes/SinOsc.html
class SinOsc is UGen is export {
  proto defaults($freq = 440.0, $phase = 0.0, $mul = 1.0, $add = 0.0) { }
  method ar(|capture) { ugen('SinOsc', 'ar', inputs => inputs(&defaults.signature, capture)) }
  method kr(|capture) { ugen('SinOsc', 'kr', inputs => inputs(&defaults.signature, capture)) }
}


#| https://doc.sccode.org/Classes/Line.html
class Line is UGen is export {
  proto defaults($start = 0.0, $end = 1.0, $dur = 1.0, $mul = 1.0, $add = 0.0, $doneAction = 0) { }
  method ar(|capture) { ugen('Line', 'ar', inputs => inputs(&defaults.signature, capture)) }
  method kr(|capture) { ugen('Line', 'kr', inputs => inputs(&defaults.signature, capture)) }
}


#| http://doc.sccode.org/Classes/MouseX.html
class MouseX is UGen is export {
  proto defaults($minval = 0, $maxval = 1, $warp = 0, $lag = 0.2) { }
  method kr(|capture) { ugen('MouseX', 'kr', inputs => inputs(&defaults.signature, capture)) }
}


#| http://doc.sccode.org/Classes/PinkNoise.html
class PinkNoise is UGen is export {
  proto defaults($mul = 0, $add = 0.2) { }
  method ar(|capture) { ugen('PinkNoise', 'ar', inputs => inputs(&defaults.signature, capture)) }
  method kr(|capture) { ugen('PinkNoise', 'kr', inputs => inputs(&defaults.signature, capture)) }
}

#| http://doc.sccode.org/Classes/Done.html
#| how does Done work? does something automatically hook done up to the ugen it is passed to?
class Done is UGen is export {
    method ugen($value) {
        UGen.new: name => 'Done', rate => 'kr', :$value
    }
    method none { self.ugen(0) } # do nothing when the UGen is finished
    method pauseSelf { self.ugen(1) } # pause the enclosing synth, but do not free it
    method freeSelf { self.ugen(2) } # free the enclosing synth
    method freeSelfAndPrev { self.ugen(3) } # free both this synth and the preceding node
    method freeSelfAndNext { self.ugen(4) } # free both this synth and the following node
    method freeSelfAndFreeAllInPrev { self.ugen(5) } # free this synth; if the preceding node is a group then do g_freeAll on it, else free it
    method freeSelfAndFreeAllInNext { self.ugen(6) } # free this synth; if the following node is a group then do g_freeAll on it, else free it
    method freeSelfToHead { self.ugen(7) } # free this synth and all preceding nodes in this group
    method freeSelfToTail { self.ugen(8) } # free this synth and all following nodes in this group
    method freeSelfPausePrev { self.ugen(9) } # free this synth and pause the preceding node
    method freeSelfPauseNext { self.ugen(10) } # free this synth and pause the following node
    method freeSelfAndDeepFreePrev { self.ugen(11) } # free this synth and if the preceding node is a group then do g_deepFree on it, else free it
    method freeSelfAndDeepFreeNext { self.ugen(12) } # free this synth and if the following node is a group then do g_deepFree on it, else free it
    method freeAllInGroup { self.ugen(13) } # free this synth and all other nodes in this group (before and after)
    method freeGroup { self.ugen(14) } # free the enclosing group and all nodes within it (including this synth)
    method freeSelfResumeNext { self.ugen(15) } # free this synth and resume the following node
}


#
# handling operators among Nodes
#

class BinaryOpUGen is UGen is export {
  proto defaults($selector, $a, $b) { }
  # what is the rate of a BinaryOpUGen?
  method make(|capture) { ugen('BinaryOpUGen', '??', inputs => inputs(&defaults.signature, capture)) }
}


multi sub infix:<*>(UGen $a, UGen $b) is export {
  BinaryOpUGen.make('*', $a, $b)
}

multi sub infix:<*>(Numeric $a, UGen $b) is export {
  BinaryOpUGen.make('*', $a, $b)
}

multi sub infix:<*>(UGen $a, Numeric $b) is export {
  BinaryOpUGen.make('*', $a, $b)
}

multi sub infix:<+>(UGen $a, UGen $b) is export {
  BinaryOpUGen.make('*', $a, $b)
}

multi sub infix:<+>(Numeric $a, UGen $b) is export {
  BinaryOpUGen.make('*', $a, $b)
}

multi sub infix:<+>(UGen $a, Numeric $b) is export {
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
