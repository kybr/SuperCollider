#!/usr/bin/env raku

class Foo {
  method instance {
    # self.Int.fmt('%X') # coming from C++, i assumed...
    self.WHICH # https://docs.raku.org/language/mop#index-entry-syntax_WHICH-WHICH
  }
}

Foo.new.instance.say
