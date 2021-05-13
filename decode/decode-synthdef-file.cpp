#include <fstream>
#include <functional>
#include <iostream>
#include <string>
#include <vector>

void die(std::string message) {
  std::cerr << message << std::endl;
  exit(1);
}

struct Decode {
  std::ifstream file;

  void load(std::string fileName) {
    file.open(fileName, std::ios::binary);
    if (file.fail()) die("FAIL");
  }

  ~Decode() { file.close(); }

  unsigned char u8() {
    if (file.fail()) die("FAIL");
    if (file.eof()) die("EOF");
    char unsigned byte;
    file >> byte;
    return byte;
  };
};

struct SynthDef {};

// XXX we wish we could deduce T given F!!
template <typename T, typename F>
std::vector<T> loop(int N, F&& fn) {
  std::vector<T> vec;
  for (int i = 0; i < N; ++i)  //
    vec.push_back(std::move(fn()));
  return std::move(vec);
}

int main(int argc, char* argv[]) {
  Decode decode;
  decode.load(argc > 1 ? argv[1] : "");

  auto i8 = [&]() -> char { return decode.u8(); };
  auto i16 = [&]() -> short { return i8() << 8 | i8(); };
  // auto i32 = [&]() -> int {
  //  return i8() << 24 | i8() << 16 | i8() << 8 | i8();
  //};
  auto i32 = [&]() -> int { return i16() << 16 | i16(); };
  auto f32 = [&]() -> float {
    // int v = i32();
    // return *((float*)(&v));
    // return *reinterpret_cast<float*>(&v);
    int i = i32();  // i8() << 0 | i8() << 8 | i8() << 16 | i8() << 24;
    float f;
    memcpy(&f, &i, sizeof f);
    return f;
    // https://stackoverflow.com/questions/13982340/is-it-safe-to-reinterpret-cast-an-integer-to-float

    union {
      int val;
      float f;
    } u;
    u.val = i;
    return u.f;
  };
  auto str = [&]() -> std::string {
    unsigned char n = decode.u8();
    std::string rv = "";
    for (int i = 0; i < n; ++i)  //
      rv += i8();
    return rv;
  };

  if (i8() != 'S' || i8() != 'C' || i8() != 'g' || i8() != 'f' || i32() != 2)
    die("SCgf 2 not found");

  auto synthdefs = loop<SynthDef>(i16(), [&]() {
    std::cout << str() << std::endl;
    // std::cout << i32() << std::endl;
    // die("got here");

    auto constants = loop<float>(i32(), [&]() { return f32(); });
    std::cout << "found " << constants.size() << " constants" << std::endl;
    for (float c : constants) std::cout << c << ' ';
    std::cout << std::endl;

    die("got here");

    return SynthDef();
  });
}
