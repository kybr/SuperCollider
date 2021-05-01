#!/usr/bin/env raku

class Node {}

multi sub infix:<*>(Node $left, Node $right) {
  "Node * Node".say;
  Node.new;
}

multi sub infix:<*>(Numeric $left, Node $right) {
  "Numeric * Node".say;
  Node.new;
}

multi sub infix:<*>(Node $left, Numeric $right) {
  "Node * Numeric".say;
  Node.new;
}

multi sub infix:<+>(Node $left, Node $right) {
  "Node + Node".say;
  Node.new;
}

multi sub infix:<+>(Numeric $left, Node $right) {
  "Numeric + Node".say;
  Node.new;
}

multi sub infix:<+>(Node $left, Numeric $right) {
  "Node + Numeric".say;
  Node.new;
}

say 1 + Node.new * 3.4;

