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
void die(string message) {
  cerr << message << endl;
  exit(1);
}

//
// the SynthDef data structure
//

struct SynthDef {
  struct Parameter {
    string name;
    float value;
  };

  struct UGen {
    struct Input {
      int a, b;  // XXX do better here
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

template <typename T>
auto gist(vector<T> const& list) -> string {
  string s;
  for (auto e : list) s += gist(e);
  return s;
}

template <>  // string
auto gist(vector<string> const& list) -> string {
  string s;
  for (auto e : list) s += e + " ";
  return s;
}
template <>  // float

auto gist(vector<float> const& list) -> string {
  string s;
  for (auto e : list) s += to_string(e) + " ";
  return s;
}

string gist(SynthDef::UGen::Input const& v) {
  string s;
  // s += "Input:";
  s += to_string(v.a) + "/" + to_string(v.b) + " ";
  return s;
}

string gist(SynthDef::Parameter const& v) {
  string s;
  // s += string("Parameter:");
  s += v.name + "=" + to_string(v.value) + " ";
  return s;
}

string gist(SynthDef::Variant const& v) {
  string s;
  // s += "Variant:";
  s += v.name;
  s += "/";
  s += gist(v.value);
  return s;
}

string gist(SynthDef::UGen const& v) {
  string s;
  // s += "UGen: ";
  s += "  " + v.name + "." + v.rate + " ";
  s += to_string(v.special_index) + " ";
  s += gist(v.input);
  s += gist(v.output);
  s += "\n";
  return s;
}

string gist(SynthDef const& v) {
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

// calls a given lambda N times, gathering the result into a vector
//
template <typename F>
auto gather(int N, F&& fn) {
  using T = decltype(fn());
  vector<T> vec;
  for (int i = 0; i < N; ++i) vec.push_back(fn());
  return vec;
}

int main(int argc, char* argv[]) {
  if (argc < 2) die("not enough arguments");
  debug = argc > 2;

  ifstream file;
  file.open(argv[1], ios::binary);
  if (file.fail()) die("could not open file");

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
      return {str(), synth.parameter_value[i32()]};
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

  // you have a list of SynthDef!
  //
  for (auto s : synthdef) {
    say(gist(s));
  }
}
