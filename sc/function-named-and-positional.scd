
// http://doc.sccode.org/Reference/Functions.html
// http://doc.sccode.org/Classes/Function.html
// http://doc.sccode.org/Classes/FunctionDef.html
(

f = {
	|a = 1, b = 2, c = 3|
	a + b + c;
};

f.().postln;
f.(0).postln;
f.(0, a: -1).postln;
f.(c: 0, b: 0, a: 0).postln;
f.(0, c: 0, b: 0).postln;
f.(0, 0, b: 0).postln;
f.(0, 0, 0).postln;
f.(0, a: 0, 0).postln; // fails!
// no positional arguments after a named argument

)