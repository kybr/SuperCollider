#!/usr/bin/env raku

# question:
# when a child class calls a parent method that uses self.^name, what string
# is returned? the name of the parent or the name of the child?

{
    my class Parent {
        method my-name {
            self.^name
        }
    }

    my class Child is Parent {}

    Child.my-name().say;
    say so Child.my-name() ~~ 'Child';
}

{
    my class Parent {
        method my-name {
            self.^name
        }
    }

    my class Child is Parent {
        method my-name {
            callsame
        }
    }

    Child.my-name().say;
    say so Child.my-name() ~~ 'Child';
}
