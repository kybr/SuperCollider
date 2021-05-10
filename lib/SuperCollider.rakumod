module SuperCollider {

#| http://doc.sccode.org/Classes/Object.html
role Object { }
#= https://github.com/supercollider/supercollider/blob/develop/SCClassLibrary/Common/Core/Object.sc

#| http://doc.sccode.org/Classes/AbstractFunction.html
role AbstractFunction does Object { }
#= https://github.com/supercollider/supercollider/blob/develop/SCClassLibrary/Common/Core/AbstractFunction.sc


sub resolve(Signature $signature, Capture $capture) {...}
sub synthdef($name, $graph) {...}
class Out {...}


#| https://doc.sccode.org/Classes/UGen.html
class UGen {
  has $.type;
  has $.rate; # simple numbers have rate 'ir'?

  # XXX consider making this an array; i think positions matter more than names
  has %.inputs; # no inputs or simple number inputs means leaf node

  #has $.position; # ???
  has $.name;
  has $.value;

  method make($rate, $capture) {
    my $type = self.^name.split('::')[*-1]; # remove the module name from the class name
    my %inputs = resolve(self.inputs, $capture); # calls down to child for signature
    # "making $type.$rate".say;
    UGen.new: :$rate, :$type, :%inputs
  }

  # XXX check if rate is supported!

  method ar(|c) { self.make('ar', c) }
  method kr(|c) { self.make('kr', c) }
  method ir(|c) { self.make('ir', c) }

  method play {
    my $s = synthdef "default", -> $bus, {
      Out.ar($bus, self)
    };
    $s.add.svg;
  }
}
#= https://github.com/supercollider/supercollider/blob/develop/SCClassLibrary/Common/Audio/UGen.sc


#| https://doc.sccode.org/Classes/Control.html
#| https://doc.sccode.org/Classes/AudioControl.html
#| https://doc.sccode.org/Classes/NamedControl.html
class Control is UGen { }
class Constant is UGen { }

sub constant-ugen(Numeric $n) {
  Constant.new:
      type => 'Constant',
      rate => 'ir',
      value => $n # XXX had a typo here (vaue) and it was a rough bug
}

#| create a UGen inputs hash, resolving the call capture with the proper signature
sub resolve(Signature $signature, Capture $capture) {
  my %inputs;

  # extract the names, order, default values / required-ness
  # from the given signature; maybe we should pre-compute this
  # for each UGen at start up? or perhaps cache it after one
  # instance is created?
  #
  for $signature.params {
    #"{.^name} has parameter {.name} with {.default.^name}".say;

    if .default ~~ Block {
      %inputs{.usage-name} = .default.()
    }
    elsif .default ~~ Code {
      # parameter does not have a default; required!
      %inputs{.usage-name} = "required"
    }
    else {
      die "what is happening?"
    }
  }

  # process the given capture looking for unknown and out of bounds
  # parameters; Raku is amazing!
  #
  for $capture.pairs {
    if .key ~~ Int {

      if .key >= $signature.params.elems {
        "trying to resolve this capture...".say;
        $capture.raku.say;
        "with this signature...".say;
        $signature.raku.say;
        die "input value {.value} passed as argument {.key} is out of bounds";
      }

      my $key = $signature.params[.key].usage-name;
      %inputs{$key} = .value;

    } elsif .key ~~ Str {
      defined %inputs{.key} or die "parameter {.key} unknown";
      %inputs{.key} = .value;
    }
    else {
      die;
    }
  }

  # check to see if there are any required parameters that were not
  # passed; say each one.
  my $it's-all-good = True;
  for %inputs.pairs {
    if .value eq "required" {
      $it's-all-good = False;
      say "{.key} not covered";
    }
  }
  $it's-all-good or die "required parameter not covered";

  # replace Numeric constants with Constant
  for %inputs.pairs {
    if .value ~~ Numeric {
      # XXX consider a lookup so we can merge constants?
      %inputs{.key} = constant-ugen .value
    }
  }

  %inputs
}


sub dot(UGen $ugen, Str $output is rw) {
  my $name = "";

  with $ugen {
    if defined .type { $name ~= "{.type}\\n" }
    if defined .rate { $name ~= "{.rate}\\n" }
    if defined .name { $name ~= "{.name}\\n" }
    if defined .value { $name ~= "{.value}\\n" }
  }

  my $id = "id_" ~ 999999999.rand.Int; # instance id
  my $declaration = "  $id [label=\"$name\"];\n";

  $output ~= $declaration;
  for $ugen.inputs.pairs {
    my $label = "[label=\"{.key}\"]";
    if .value ~~ UGen {
      $output ~= "  $id -> {dot .value, $output} $label;\n";
    }
    else {
      $output ~= "  $id -> \"{.value}\" $label;\n"
    }
  }

  $id # the id of this UGen
}


#| https://doc.sccode.org/Classes/SynthDef.html
#| https://doc.sccode.org/Tutorials/Mark_Polishook_tutorial/07_SynthDefs.html
class SynthDef is export {
  has Str $.name;  # the name of this definition
  has Block $.graph; # execute to construct an audio graph
  has UGen $.structure; # evaluated graph

  # make is so you can construct with a simple SynthDef(...)
  #
  method CALL-ME($name, $graph) {
    SynthDef.new: :$name, :$graph
  }

  method create-blob {
    # we'll need something like this
    my $buf = buf8.new(3, 6, 254);
  }

  method generate-c {
    # code-gen a per-sample c function
  }

  method create-structure {
    # Use the given graph (a Raku Block) to construct a SynthDef data structure.
    # It is a binary format described here:
    #   https://doc.sccode.org/Reference/Synth-Definition-File-Format.html
    # We might do this by executing the given block and inspecting the result or
    # perhaps we can use introspection to inspect the given block and build the
    # binary from that. How does SuperCollider do it? What is the more Raku way
    # to do it? Perhaps a Grammar?

    # https://en.wikipedia.org/wiki/Topological_sorting

    # fail if graph does not return a Node? Array?
    say "graph returns type {$!graph.returns.raku}";

    # note the signature of the graph; we need that to design the proxy object
    say "graph signature is {$!graph.signature.raku}";

    my %hash;
    my @list;
    for $!graph.signature.params {
      if .positional {
        @list.push: Control.new(
                :type('Control'),
                :rate('kr'),
                :name(.usage-name),
                :value(.default ~~ Block ?? .default.() !! Any));
      }
      elsif .named {
        %hash{.usage-name} = Control.new(
                :type('Control'),
                :rate('kr'),
                :name(.usage-name),
                :value(.default ~~ Block ?? .default.() !! Any));
      }
    }
    my $capture = Capture.new: :@list, :%hash;
    #say "calling graph with {$capture.raku}";
    $!structure = $!graph(|$capture); # the slip (|) operator de-structures the capture
    Nil
  }

  method svg {
    my $guts = "";
    dot $!structure, $guts;
    my $file-name = "/tmp/{9999999999.rand.Int}.dot";
    my $graphviz = "digraph g_{99999999999.rand.Int} \{\n$guts\n\}";
    spurt $file-name, $graphviz;
    say "making $file-name.svg";
    shell "dot -Tsvg $file-name > $file-name.svg";
    shell "open $file-name.svg";
  }

  method add {
    my $structure = self.create-structure;
    say $structure;
    # output graphviz
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


#| https://doc.sccode.org/Classes/Out.html
class Out is UGen is export {
   method inputs { :($bus, $channelsArray) }
   method rates { <ar kr> }
}


#| https://doc.sccode.org/Classes/SinOsc.html
class SinOsc is UGen is export {
  method inputs { :($freq = 440.0, $phase = 0.0, $mul = 1.0, $add = 0.0) }
  method rates { <ar kr> }
}


#| https://doc.sccode.org/Classes/Line.html
class Line is UGen is export {
  method inputs { :($start = 0.0, $end = 1.0, $dur = 1.0, $mul = 1.0, $add = 0.0, $doneAction = 0) }
  method rates { <ar kr> }
}


#| http://doc.sccode.org/Classes/MouseX.html
class MouseX is UGen is export {
  method inputs { :($minval = 0, $maxval = 1, $warp = 0, $lag = 0.2) }
  method rates { <kr> }
}


#| http://doc.sccode.org/Classes/PinkNoise.html
class PinkNoise is UGen is export {
  method inputs { :($mul = 1.0, $add = 0.0) }
  method rates { <ar kr> }
}


#| https://doc.sccode.org/Classes/WhiteNoise.html
class WhiteNoise is UGen is export {
  method inputs { :($mul = 1.0, $add = 0.0) }
  method rates { <ar kr> }
}


#| https://doc.sccode.org/Classes/Pan2.html
class Pan2 is UGen is export {
  method inputs { :($in, $pos = 0.0, $level = 1.0) }
  method rates { <ar kr> }
}


#| https://doc.sccode.org/Classes/BufDur.html
class BufDur is UGen is export {
  method inputs { :($bufnum) }
  method rates { <kr ir> }
}


#| https://doc.sccode.org/Classes/BufRateScale.html
class BufRateScale is UGen is export {
  method inputs { :($bufnum) }
  method rates { <kr ir> }
}


#| https://doc.sccode.org/Classes/PlayBuf.html
class PlayBuf is UGen is export {
  method inputs { :($numChannels, $bufnum = 0, $rate = 1.0, $trigger = 1.0, $startPos = 0.0, $loop = 0.0, $doneAction = 0) }
  method rates { <ar kr> }
}


#| http://doc.sccode.org/Classes/Done.html
class Done is UGen is export {
  method inputs { :($src) }
  method rates { <kr> }

  # this next part is just a bunch of enums, basically. these are conflated into the Done class :|
  #
  method none { 0 } # do nothing when the UGen is finished
  method pauseSelf { 1 } # pause the enclosing synth, but do not free it
  method freeSelf { 2 } # free the enclosing synth
  method freeSelfAndPrev { 3 } # free both this synth and the preceding node
  method freeSelfAndNext { 4 } # free both this synth and the following node
  method freeSelfAndFreeAllInPrev { 5 } # free this synth; if the preceding node is a group then do g_freeAll on it, else free it
  method freeSelfAndFreeAllInNext { 6 } # free this synth; if the following node is a group then do g_freeAll on it, else free it
  method freeSelfToHead { 7 } # free this synth and all preceding nodes in this group
  method freeSelfToTail { 8 } # free this synth and all following nodes in this group
  method freeSelfPausePrev { 9 } # free this synth and pause the preceding node
  method freeSelfPauseNext { 10 } # free this synth and pause the following node
  method freeSelfAndDeepFreePrev { 11 } # free this synth and if the preceding node is a group then do g_deepFree on it, else free it
  method freeSelfAndDeepFreeNext { 12 } # free this synth and if the following node is a group then do g_deepFree on it, else free it
  method freeAllInGroup { 13 } # free this synth and all other nodes in this group (before and after)
  method freeGroup { 14 } # free the enclosing group and all nodes within it (including this synth)
  method freeSelfResumeNext { 15 } # free this synth and resume the following node
}


#
# handling operators among Nodes
#

class BinaryOpUGen is UGen is export {
  method inputs { :($selector, $a, $b) }
  method rates { <ar kr ir> }
}

sub determine-rate(UGen $a, UGen $b) {
  return 'ar' if $a.rate eq 'ar';
  return 'ar' if $b.rate eq 'ar';
  return 'kr' if $a.rate eq 'kr';
  return 'kr' if $b.rate eq 'kr';
  return 'ir' if $a.rate eq 'ir';
  return 'ir' if $b.rate eq 'ir';
  return '??'
}

sub make-binop($op, $a, $b --> UGen) {
  given determine-rate($a, $b) {
    when 'ar' { return BinaryOpUGen.ar($op, $a, $b) }
    when 'kr' { return BinaryOpUGen.kr($op, $a, $b) }
    when 'ir' { return BinaryOpUGen.ir($op, $a, $b) }
  }
}

multi sub infix:<*>(UGen $a, UGen $b) is export { make-binop('*', $a, $b)}
multi sub infix:<*>(UGen $a, Numeric $b) is export { make-binop('*', $a, constant-ugen $b)}
multi sub infix:<*>(Numeric $a, UGen $b) is export { make-binop('*', constant-ugen($a), $b)}

multi sub infix:</>(UGen $a, UGen $b) is export { make-binop('/', $a, $b)}
multi sub infix:</>(UGen $a, Numeric $b) is export { make-binop('/', $a, constant-ugen $b)}
multi sub infix:</>(Numeric $a, UGen $b) is export { make-binop('/', constant-ugen($a), $b)}

multi sub infix:<+>(UGen $a, UGen $b) is export { make-binop('+', $a, $b)}
multi sub infix:<+>(UGen $a, Numeric $b) is export { make-binop('+', $a, constant-ugen $b)}
multi sub infix:<+>(Numeric $a, UGen $b) is export { make-binop('+', constant-ugen($a), $b)}

multi sub infix:<->(UGen $a, UGen $b) is export { make-binop('-', $a, $b)}
multi sub infix:<->(UGen $a, Numeric $b) is export { make-binop('-', $a, constant-ugen $b)}
multi sub infix:<->(Numeric $a, UGen $b) is export { make-binop('-', constant-ugen($a), $b)}

multi sub infix:<!>($a, $b) is export is DEPRECATED("Use Raku's xx operator instead!") {
  $a xx $b
}
# XXX many, many other operators....


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
  method play {
    # evaluate the block; if it returned a UGen, call .play on it
    my $t = self.(); # XXX what if it returns nothing?
    if $t ~~ UGen {
      $t.play # call .play on a UGen
    }
  }

  # in SuperCollider you can call .value or value(...) on basically anything
  # on a function, it's like calling that function
  #
  method value {}
}

sub midicps($v) is export { 8.175799 * 2 ** ($v / 12) }
# XXX more "operators" here!

augment class Int { method midicps { midicps self } }
augment class Rat { method midicps { midicps self } }
augment class FatRat { method midicps { midicps self } }
augment class Num { method midicps { midicps self } }
augment class Complex { method midicps { midicps self } }

}