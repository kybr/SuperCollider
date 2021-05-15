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

void put(string message) { cout << message; }
void say(string message) { cout << message << endl; }
void die(string message) {
  cerr << message << endl;
  exit(1);
}
void announce(string message) {
  cout << "###############=- " << message << " -=#########################"
       << endl;
  ;
}

struct SynthDef {
  struct Parameter {
    string name;
    float value;
  };
  struct UGen {
    struct Input {
      int a, b;
      // XXX do better here
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

struct Decode {
  ifstream file;

  void load(string fileName) {
    file.open(fileName, ios::binary);
    if (file.fail()) die("FAIL");
  }

  ~Decode() { file.close(); }

  unsigned char u8_BROKEN_DO_NOT_TRUST_THE_STREAM_OPERATOR() {
    if (file.fail()) die("FAIL");
    if (file.eof()) die("EOF");
    unsigned char byte;
    file >> byte;
    printf("%02X ", byte & 255);
    if (file.fail()) die("FAIL");
    return byte;
  }

  unsigned char u8() {
    char c;
    file.read(&c, 1);
    if (file.fail()) die("FAIL");
    if (file.eof()) die("EOF");
    if (debug) printf("%02X ", 255 & c);
    return c;
  };
};

template <typename F>
auto gather(int N, F&& fn) {
  using T = decltype(fn());
  vector<T> vec;
  for (int i = 0; i < N; ++i)  //
    vec.push_back(move(fn()));
  return move(vec);
}

int main(int argc, char* argv[]) {
  Decode decode;
  decode.load(argc > 1 ? argv[1] : "");

  // turn on debugging
  debug = argc > 2;

  const char* rate[3] = {"ir", "kr", "ar"};

  auto u8 = [&]() -> unsigned char { return decode.u8(); };
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

  if (i8() != 'S' || i8() != 'C' || i8() != 'g' || i8() != 'f')  //
    die("SCgf not found");

  if (debug) say("SCgf");

  if (i32() != 2)  //
    die("incorrect version");

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
}
