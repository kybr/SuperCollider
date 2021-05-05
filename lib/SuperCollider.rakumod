module SuperCollider {

#| http://doc.sccode.org/Classes/Object.html
role Object {

}
#= https://github.com/supercollider/supercollider/blob/develop/SCClassLibrary/Common/Core/Object.sc

#| http://doc.sccode.org/Classes/AbstractFunction.html
role AbstractFunction does Object {}
#= https://github.com/supercollider/supercollider/blob/develop/SCClassLibrary/Common/Core/AbstractFunction.sc


class Ugen does AbstractFunction {}


# recipe for building a synth
#
class SynthDef is export {
  has Str $!name;  # the name of this definition
  has Block $!block; # execute to construct an audio graph

  # make is so you can construct with a simple SynthDef(...)
  #
  method CALL-ME($name, $block) {
    SynthDef.new: :$name, :$block
  }

  submethod BUILD(:$!name, :$!block) {
    self.raku.say;
    say $!name;

    # fail if $block does not return a Node? Array?
    $!block.returns.say;

    # note the signature of the block; we need that to design the proxy object
    $!block.signature.raku.say;
  }

  method add {
    "calling the synthdef block...".say;

    $!block(0) # call the block

    # this should maybe...
    # - return a binary data structure
    # - code-gen a per-sample function
    # - ?
  }
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


class Out is Ugen is export {
  has Int $.bus;
  has Ugen $.node; # channelsArray

# https://doc.sccode.org/Classes/Out.html

  method ar(|c) {
    # Out.new: c
  }

  submethod BUILD {
    "Out.new".say;
  }
}


class SinOsc is Ugen is export {

# https://doc.sccode.org/Classes/SinOsc.html

  #method ar($frequency, $phase = 0, $multiply = 1, $add = 0) {
  method ar(|c) {
    SinOsc.new
  }

  submethod BUILD { self.raku.say }
}


class Line is Ugen is export {
  method kr($start = 0.0, $end = 1.0, $dur = 1.0, $mul = 1.0, $add = 0.0, $doneAction = 0) {
    Line.new
  }

  submethod BUILD { "Line.new".say; }
}


class MouseX is Ugen is export {
  # http://doc.sccode.org/Classes/MouseX.html

  method kr(|c) {
    # mul, add
    MouseX.new:
  }

  submethod BUILD { self.raku.say }
}


class PinkNoise is Ugen is export {
  # http://doc.sccode.org/Classes/PinkNoise.html

  method ar(|c) {
    PinkNoise.new
  }

  submethod BUILD { self.raku.say }
}


class Done is export {
  method freeSelf {
    Done.new
  }

  submethod BUILD { "Done.new".say; }
}


#
# handling operators among Nodes
#

class BinOp is Ugen is export {
  has Str $.op;
  has $.left;
  has $.right;

  submethod BUILD(:$!op, :$!left, :$!right) {
    self.raku.say;
    #$!left.raku.say;
  }
}


multi sub infix:<*>(Ugen $left, Ugen $right --> BinOp) is export {
  BinOp.new: op => '*', :$left, :$right
}

multi sub infix:<*>(Numeric $left, Ugen $right --> BinOp) is export {
  BinOp.new: op => '*', :$left, :$right
}

multi sub infix:<*>(Ugen $left, Numeric $right --> BinOp) is export {
  BinOp.new: op => '*', :$left, :$right
}

multi sub infix:<+>(Ugen $left, Ugen $right --> BinOp) is export {
  BinOp.new: op => '+', :$left, :$right
}

multi sub infix:<+>(Numeric $left, Ugen $right --> BinOp) is export {
  BinOp.new: op => '+', :$left, :$right
}

multi sub infix:<+>(Ugen $left, Numeric $right --> BinOp) is export {
  BinOp.new: op => '+', :$left, :$right
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
    if $t ~~ Ugen {
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
