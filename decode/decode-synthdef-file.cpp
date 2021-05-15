#include <fstream>
#include <functional>
#include <iostream>
#include <string>
#include <vector>

using namespace std;

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

struct Input {
  int a, b;
};

struct UGen {
  string name;
  string rate;
  short special_index;
  vector<Input> inputs;
  vector<string> outputs;
};

struct Variant {
  string name;
  vector<float> values;
};

struct Parameter {
  string name;
  float value;
  void show() { printf("Parameter %s %f\n", name.c_str(), value); }
};

struct SynthDef {
  // name
  //
};

struct Decode {
  ifstream file;

  void load(string fileName) {
    file.open(fileName, ios::binary);
    if (file.fail()) die("FAIL");
  }

  ~Decode() { file.close(); }

  unsigned char u8_BROKEN() {
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
    // printf("%02ld:%02X ", file.gcount(), c);
    printf("%02X ", 255 & c);
    return c;
  };
};

// XXX we wish we could deduce T given F!!
// XXX we wish we could assert that F returns a T!
template <typename T, typename F>
vector<T> loop(int N, F&& fn) {
  vector<T> vec;
  for (int i = 0; i < N; ++i)  //
    vec.push_back(move(fn()));
  return move(vec);
}

int main(int argc, char* argv[]) {
  Decode decode;
  decode.load(argc > 1 ? argv[1] : "");

  const char* rate[3] = {"ir", "kr", "ar"};

  auto u8 = [&]() -> unsigned char { return decode.u8(); };
  auto i8 = [&]() -> char { return u8(); };

  auto i16 = [&]() -> short {
    short s = u8() << 8 | u8();
    printf("short: %d\n", s);
    return s;
  };

  auto i32 = [&]() -> int {
    int i = u8() << 24 | u8() << 16 | u8() << 8 | u8();
    printf("int: %d\n", i);
    return i;
  };

  auto f32 = [&]() -> float {
    int i = u8() << 24 | u8() << 16 | u8() << 8 | u8();
    float f = reinterpret_cast<float&>(i);
    // float f = *reinterpret_cast<float*>(&i);
    printf("float: %f\n", f);
    return f;
  };

  auto str = [&]() -> string {
    unsigned char N = u8();

    string rv = "";
    for (unsigned char i = 0; i < N; i++)  //
      rv += u8();
    printf("string: '%s' (%d)\n", rv.c_str(), N);
    return rv;
  };

  if (i8() != 'S' || i8() != 'C' || i8() != 'g' || i8() != 'f')  //
    die("SCgf not found");
  say("SCgf");

  if (i32() != 2)  //
    die("incorrect version");

  auto synthdefs = loop<SynthDef>(i16(), [&]() -> SynthDef {
    announce("SynthDef");

    auto name = str();

    auto constant_values = loop<float>(i32(), f32);

    auto P = i32();  // named because we use it later!

    auto initial_parameter_values = loop<float>(P, f32);

    auto parameter_names = loop<Parameter>(i32(), [&]() -> Parameter {
      return {str(), initial_parameter_values[i32()]};
    });

    auto ugen_spec = loop<UGen>(i32(), [&]() -> UGen {
      announce("UGen");
      UGen ugen;
      ugen.name = str();

      ugen.rate = rate[i8()];
      say("rate");

      put("number of inputs is ");
      int I = i32();
      put("number of outputs is ");
      int O = i32();

      put("special index is ");
      ugen.special_index = i16();

      ugen.inputs = loop<Input>(I, [&]() -> Input { return {i32(), i32()}; });

      ugen.outputs = loop<string>(O, [&]() -> string {
        string r = rate[i8()];
        put("output rate ");
        say(r);
        return r;
      });

      return ugen;
    });

    auto variant_spec = loop<Variant>(i16(), [&]() -> Variant {
      Variant variant;
      variant.name = str();
      variant.values = loop<float>(P, f32);
      return variant;
    });

    return SynthDef();
  });
}
