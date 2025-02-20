class Fmt < Formula
  desc "Open-source formatting library for C++"
  homepage "https://fmtlib.github.io/"
  url "https://github.com/fmtlib/fmt/archive/6.2.1.tar.gz"
  sha256 "5edf8b0f32135ad5fafb3064de26d063571e95e8ae46829c2f4f4b52696bbff0"

  bottle do
    cellar :any_skip_relocation
    sha256 "3f9df7bcf9d9d5c6cd5ca13c5c4324c43f033399afa24e21199b15aa4027a0e6" => :catalina
    sha256 "eb7fd7d969215f3f499dfb9f9e895ad73d88023b658ba72db2128ee3b506a530" => :mojave
    sha256 "a8015422bca1c4b3b1488c377f2ae447d0c342db6be5d6398de1a01f2ca171b4" => :high_sierra
    sha256 "ee2e604e24dcd78272bd07213ef1f48287f8c02f9d252cac082aafdc5acce0bc" => :x86_64_linux
  end

  depends_on "cmake" => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <iostream>
      #include <string>
      #include <fmt/format.h>
      int main()
      {
        std::string str = fmt::format("The answer is {}", 42);
        std::cout << str;
        return 0;
      }
    EOS

    system ENV.cxx, "test.cpp", "-std=c++11", "-o", "test",
                  "-I#{include}",
                  "-L#{lib}",
                  "-lfmt"
    assert_equal "The answer is 42", shell_output("./test")
  end
end
