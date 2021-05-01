#!/usr/bin/env raku

class Node {}

multi sub infix:<*>(Node $a, Node $b) {
  "Node * Node"
}

multi sub infix:<*>(Node $a, Numeric $b) {
  "Node * Numeric"
}

multi sub infix:<*>(Numeric $a, Node $b) {
  "Numeric * Node"
}

say Node.new * Node.new;
say Node.new * 3.4;
say 12.1 * Node.new;
