#!/usr/bin/env raku

class Node {}

multi sub infix:<*>(Node $left, Node $right) {
  "Node * Node"
}

multi sub infix:<*>(Numeric $left, Node $right) {
  "Numeric * Node"
}

multi sub infix:<*>(Node $left, Numeric $right) {
  "Node * Numeric"
}

multi sub infix:<+>(Node $left, Node $right) {
  "Node + Node"
}

multi sub infix:<+>(Numeric $left, Node $right) {
  "Numeric + Node"
}

multi sub infix:<+>(Node $left, Numeric $right) {
  "Node + Numeric"
}

say Node.new * Node.new;
say Node.new * 3.4;
say 12.1 * Node.new;

say Node.new + Node.new;
say Node.new + 3.4;
say 12.1 + Node.new;
