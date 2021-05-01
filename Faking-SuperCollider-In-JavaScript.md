



To Jack.

So, you want to implement the SuperCollider language in JavaScript? First, try mimicry. Take a snippet of SuperCollider, a little piece of code, and try to run it in a JavaScript interpreter. When it fails to compile, think why and then create a prelude\* that might make the SuperCollider code work, as is. For instance, look at the code below and think what it might take to compile it as JavaScript:

```SuperCollider
(
SynthDef(\simple, { |out, freq = 800, sustain = 1, amp = 0.9|
  Out.ar(out,
    SinOsc.ar(freq, 0, 0.2) * Line.kr(amp, 0, sustain, doneAction: Done.freeSelf)
  )
}).add;

a = Synth(\simple);
)
```

If (when) this process fails, you have a choice. 1) You can start to change the SuperCollider code minimally so that it is actually valid JavaScript and not valid SuperCollider---Here, you are letting go of your dream to some degree. You will ask your users to make these changes to their SuperCollider code when moving to your system. Or, 2) You can write a SuperCollider interpreter in JavaScript. Start with the Lex and Yacc specification in the SuperCollider repository and port this to a [PEG.js](https://pegjs.org/) grammar. This is going to be a lot of work, but it might be a better choice if you do not already know JavaScript.

There is a third option. JavaScript is insanely flexible. There are libraries that let you extend the JavaScript language in ways that might help you compile SuperCollider as-is. Here are some links in that vein:

- <https://www.sweetjs.org/>
- <https://babeljs.io/>
  - <https://github.com/charlieroberts/jsdsp>
- <https://2ality.com/2011/12/fake-operator-overloading.html>



Here is a somewhat changed listing. It is no longer valid SuperCollider; It is _almost_ valid JavaScript:

```js
(
SynthDef("simple", (out, freq = 800, sustain = 1, amp = 0.9) => {
  return Out.ar(out,
    SinOsc.ar(freq, 0, 0.2) * Line.kr(amp, 0, sustain, {doneAction: Done.freeSelf})
  )
}).add();

a = Synth("simple");
)
```

1. `\simple` cannot work in vanilla JavaScript; Just use a `"string"` which is still valid in SuperCollider
2. `|list, of, args|` becomes `(list, of, args) => {...}`
3. You have to explicitly say `return` to return something in JavaScript
4. `doneAction: Done.freeSelf` is almost JavaScript. We put it in `{}` and it becomes an object
5. `.add` is not a valid method call. JavaScript makes you say `.add()`

There's still a big problem. There's no operator overloading in JavaScript, so the `SinOsc * Line` is not going to work. We either [write a Babel.js plugin like Charlie did](https://github.com/charlieroberts/jsdsp) or we live with something like this:

```js
(
SynthDef("simple", (out, freq = 800, sustain = 1, amp = 0.9) => {
  return Out.ar(out,
    BinOp('*', SinOsc.ar(freq, 0, 0.2), Line.kr(amp, 0, sustain, {doneAction: Done.freeSelf}))
  )
}).add();

a = Synth("simple");
)
```

SuperCollider has a bunch of operators, so you will have to do something about that.



\* What is a _prelude_? It is just all the support code you would need to make a snippet work. For instance, in the most recent listing above, we must define all the objects/functions: `SynthDef`, `Out`, `Synth`, etc. We know from inspecting the code that `SynthDef` is a function that takes a string and a function definition and returns something with an `.add()` method. `Line` is a thing with a method `kr(...)` that accepts a combination of positional and named arguments (where the latter are implemented as object blocks `{...}`).



I started a project to make SuperCollider work as Raku: <https://github.com/kybr/SuperCollider>. As you can see, Raku is _very_ close to SuperCollider already. Raku supports operator overloading, so the operators will not be a problem. You can see that I am willing to deviate from the SuperCollider language.



