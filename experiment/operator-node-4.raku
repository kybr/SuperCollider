#!/usr/bin/env raku

class Node {}

use MONKEY-TYPING;

augment class Block {
  method play {
    "play called".say;
    my $t = self.();
    if $t ~~ Node {
      "we got a Node".say
    }
  }
}

class BinOp is Node is export {
  has Str $.op;
  has $.left;
  has $.right;

  submethod BUILD(:$!op, :$!left, :$!right) {
    self.raku.say;
  }
}

class SinOsc is Node is export {
  method ar(|c) { SinOsc.new }
  submethod BUILD { self.raku.say }
}

multi sub infix:<*>(Node $left, Node $right --> BinOp) {
  BinOp.new: op => '*', :$left, :$right
}

multi sub infix:<*>(Numeric $left, Node $right --> BinOp) {
  BinOp.new: op => '*', :$left, :$right
}

multi sub infix:<*>(Node $left, Numeric $right --> BinOp) {
  BinOp.new: op => '*', :$left, :$right
}

multi sub infix:<+>(Node $left, Node $right --> BinOp) {
  BinOp.new: op => '+', :$left, :$right
}

multi sub infix:<+>(Numeric $left, Node $right --> BinOp) {
  BinOp.new: op => '+', :$left, :$right
}

multi sub infix:<+>(Node $left, Numeric $right --> BinOp) {
  BinOp.new: op => '+', :$left, :$right
}

say so {SinOsc.ar() * 3 + 1}.play;

