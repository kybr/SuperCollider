#!/usr/bin/env raku

class Parameter {
  has $.name;
  has $.value;
}

class Variant {
  has $.name;
  has $.values;
}

class UGen {
  has $.name;
  has $.rate;
  has $.special-index;
  has @.inputs;
  has @.outputs;
}

class ByteRead {
  has buf8 $.buffer;
  has Int $.index;

  # make this return a synthdef structure - UGen graph? hashes or hashes
  method load($file-name) {
    $!buffer = slurp $file-name, :bin;
    $!index = 0;
  }

  method i8 { my $b = $!buffer.read-int8($!index); $!index += 1; $b }
  method u8 { my $b = $!buffer.read-uint8($!index); $!index += 1; $b }
  method i16 { my $b = $!buffer.read-int16($!index, BigEndian); $!index += 2; $b }
  method i32 { my $b = $!buffer.read-int32($!index, BigEndian); $!index += 4; $b }
  method f32 { my $b = $!buffer.read-num32($!index, BigEndian); $!index += 4; $b }
  method str { (for ^self.u8 { self.i8.chr }).join }

  method verify-header {
    self.i8.chr eq 'S'
        && self.i8.chr eq 'C'
        && self.i8.chr eq 'g'
        && self.i8.chr eq 'f'
        && self.i32 == 2
  }

  method synth-def {
    my $name = self.str;
    say "Name: $name";

    my @constant-values = do for ^self.i32 { self.f32 }
    say "Constants: {@constant-values}";

    my \P = self.i32;

    my @initial-parameter-values = do for ^P { self.f32 }
    say @initial-parameter-values;

    my @parameters = do for ^self.i32 {
      Parameter.new:
          name => self.str,
          value => @initial-parameter-values[self.i32]
    }
    @parameters.raku.say;

    my @ugen-spec = do for ^self.i32 {
      my $name = self.str;
      my $rate = <ir kr ar>[self.i8];
      say "$name.$rate";

      my \I = self.i32;
      my \O = self.i32;
      my $special-index = self.i16;
      say "  ins:" ~ I ~ "/outs:" ~ O ~ " (op=$special-index)";

      # XXX this is the part that is unclear to me...
      my @inputs = do for ^I {
        my $index = self.i32; # index of unit generator?
        when $index == -1 {
          # index of constant?
          self.i32; # XXX what do i do with this
        }
        default {
          # index of unit generator output?
          self.i32; # XXX what do i do with this
        }
      }

      my @outputs = do for ^O { self.i8 }

      UGen.new: :$name, :$rate, :$special-index, :@inputs, :@outputs;
    }

    my @variant-spec = do for ^self.i16 {
      Variant.new:
        name => self.str,
        values => do for ^P { self.f32 }
    }
  }

  method synth-defs {
    do for ^self.i16 { self.synth-def }
  }
}

my $t = ByteRead.new;
$t.load('has-diamond-graph.scsyndef');
$t.verify-header or die { "bad header" };
my @synth-def-list = $t.synth-defs;
#@synth-def.say;
