// SuperCollider .scsyndef file decoder
// Karl Yerkes
// 2021-05-15
// Find the SynthDef File Format here:
//   http://doc.sccode.org/Reference/Synth-Definition-File-Format.html
//
#include <fstream>
#include <functional>
#include <iostream>
#include <string>
#include <vector>

using namespace std;

bool debug = false;

//
// helper functions
//

void say(string message) { cout << message << endl; }
void print(string message) { cout << message; }
void die(string message) {
  cerr << message << endl;
  exit(1);
}

// calls a given lambda N times, gathering the result into a vector
//
template <typename F>
auto gather(int N, F&& fn) {
  using T = decltype(fn());
  vector<T> v;
  for (int i = 0; i < N; i++) v.push_back(fn());
  return v;
}

auto join(string const& delimiter, vector<string> const& list) -> string {
  return delimiter;
}

//
// the SynthDef data structure
//

struct SynthDef {
  struct Parameter {
    string name;
    int index;  // float value;
  };

  struct UGen {
    struct Input {
      int ugen, outlet;
    };

    string name;
    string rate;
    short special_index;
    vector<Input> input;
    vector<string> output;
  };

  struct Variant {
    string name;
    vector<float> value;
  };

  string name;
  vector<float> constant;
  vector<float> parameter_value;
  vector<Parameter> parameter_name;
  vector<UGen> ugen;
  vector<Variant> variant;
};

//
// ways to make strings out of SynthDef parts and pieces
//

template <typename T>  // general case for list of things
auto gist(vector<T> const& list) -> string {
  string s;
  for (auto e : list) s += gist(e);
  return s;
}

auto gist(vector<string> const& list) -> string {
  string s;
  // XXX make this like join(list, delimiter)
  for (auto e : list) s += e + " ";
  return s;
}

auto gist(vector<float> const& list) -> string {
  string s;
  // XXX make this like join(list, delimiter)
  for (auto e : list) s += to_string(e) + " ";
  return s;
}

auto gist(SynthDef::UGen::Input const& v) -> string {
  string s;
  // s += "Input:";
  s += to_string(v.ugen) + ":" + to_string(v.outlet) + " ";
  return s;
}

auto gist(SynthDef::Parameter const& v) -> string {
  string s;
  // s += string("Parameter:");
  s += v.name + "=" + to_string(v.index) + " ";
  return s;
}

auto gist(SynthDef::Variant const& v) -> string {
  string s;
  // s += "Variant:";
  s += v.name;
  s += "/";
  s += gist(v.value);
  return s;
}

auto gist(SynthDef::UGen const& v) -> string {
  string s;
  // s += "UGen: ";
  s += "  " + v.name + "." + v.rate + "(";
  s += gist(v.input);
  s += ") -> ";
  s += gist(v.output);
  s += "si=" + to_string(v.special_index);
  s += "\n";
  return s;
}

auto gist(SynthDef const& v) -> string {
  string s;
  s += "SynthDef: ";
  s += v.name + "\n";
  s += "  constant: " + gist(v.constant) + "\n";
  s += "  parameter_value: " + gist(v.parameter_value) + "\n";
  s += "  parameter_name: " + gist(v.parameter_name) + "\n";
  s += gist(v.ugen);
  s += "  variant:" + gist(v.variant) + "\n";
  return s;
}

//
// main
//

int main(int argc, char* argv[]) {
  if (argc < 2) die("not enough arguments");

  debug = argc > 2;  // turn on debugging?

  // open a .scsyndef
  //
  ifstream file;
  file.open(argv[1], ios::binary);
  if (file.fail()) die("could not open file");

  // used later to change a rate index into a string
  //
  const char* rate[3] = {"ir", "kr", "ar"};

  //
  // functions for decoding a byte stream
  //

  auto u8 = [&]() -> unsigned char {
    char c;
    file.read(&c, 1);
    if (file.fail()) die("FAIL");
    if (file.eof()) die("EOF");
    if (debug) printf("%02X ", 255 & c);
    return c;
  };

  auto i8 = [&]() -> char { return u8(); };

  auto i16 = [&]() -> short {
    short s = u8() << 8 | u8();
    if (debug) printf("short: %d\n", s);
    return s;
  };

  auto i32 = [&]() -> int {
    int i = u8() << 24 | u8() << 16 | u8() << 8 | u8();
    if (debug) printf("int: %d\n", i);
    return i;
  };

  auto f32 = [&]() -> float {
    int i = u8() << 24 | u8() << 16 | u8() << 8 | u8();
    float f = reinterpret_cast<float&>(i);
    if (debug) printf("float: %f\n", f);
    return f;
  };

  auto str = [&]() -> string {
    unsigned char N = u8();
    string rv = "";
    for (unsigned char i = 0; i < N; i++)  //
      rv += u8();
    if (debug) printf("string: '%s' (%d)\n", rv.c_str(), N);
    return rv;
  };

  //
  // read the .scsyndef file
  //

  // verify magic number
  //
  if (i8() != 'S' || i8() != 'C' || i8() != 'g' || i8() != 'f')  //
    die("SCgf not found");
  if (debug) say("SCgf");

  // verify version
  //
  if (i32() != 2)  //
    die("incorrect version");

  // decode a SynthDef from a byte stream; it's lambdas all the way down!
  //
  auto synthdef = gather(i16(), [&]() -> SynthDef {
    SynthDef synth;

    synth.name = str();

    synth.constant = gather(i32(), f32);

    auto P = i32();  // named because we use it later!

    synth.parameter_value = gather(P, f32);

    synth.parameter_name = gather(i32(), [&]() -> SynthDef::Parameter {
      return {str(), i32()};  // synth.parameter_value[i32()]};
    });

    synth.ugen = gather(i32(), [&]() -> SynthDef::UGen {
      SynthDef::UGen ugen;

      ugen.name = str();

      ugen.rate = rate[i8()];

      int I = i32();
      int O = i32();

      ugen.special_index = i16();

      ugen.input = gather(I, [&]() -> SynthDef::UGen::Input {
        return {i32(), i32()};
      });

      ugen.output = gather(O, [&]() -> string { return rate[i8()]; });

      return ugen;
    });

    synth.variant = gather(i16(), [&]() -> SynthDef::Variant {
      SynthDef::Variant variant;

      variant.name = str();

      variant.value = gather(P, f32);

      return variant;
    });

    return synth;
  });

  //
  // the end
  //

  // you now have a list of SynthDef!
  //
  for (auto s : synthdef) say(gist(s));
}
