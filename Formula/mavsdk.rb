class Mavsdk < Formula
  desc "API and library for MAVLink compatible systems written in C++11"
  homepage "https://mavsdk.mavlink.io"
  url "https://github.com/mavlink/MAVSDK.git",
    :tag      => "v0.25.0",
    :revision => "0ad7baf3ec2e92c05e212679e4b38319e3d89c01"

  bottle do
    cellar :any
    sha256 "3ddc5fe48ddcc2264c242f524f8277628d485724e2ad159ad691a82b51ce1ff2" => :catalina
    sha256 "619db79cab731beece5cbd367d789ff8747efcbd9f0b94915f02c6debd749099" => :mojave
    sha256 "f80177abb051de50313ef7cc6ad247e11447ea308da89401cc93c83d1fbe501a" => :high_sierra
    sha256 "4c00e15969b24b24369583342c5a84d383fcc7fbe0eb317f634e328383ec9bc0" => :x86_64_linux
  end

  depends_on "cmake" => :build

  def install
    system "cmake", *std_cmake_args,
                    "-Bbuild/default",
                    "-DBUILD_BACKEND=ON",
                    "-H."
    system "cmake", "--build", "build/default", "--target", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <mavsdk/mavsdk.h>
      #include <mavsdk/plugins/info/info.h>
      int main() {
          mavsdk::Mavsdk mavsdk;
          mavsdk.version();
          mavsdk::System& system = mavsdk.system();
          auto info = std::make_shared<mavsdk::Info>(system);
          return 0;
      }
    EOS
    system ENV.cxx, "-std=c++11", testpath/"test.cpp", "-o", "test",
                  "-I#{include}/mavsdk",
                  "-L#{lib}",
                  "-lmavsdk",
                  "-lmavsdk_info"
    system "./test"

    assert_equal "Usage: backend_bin [-h | --help]",
                 shell_output("#{bin}/mavsdk_server --help").split("\n").first
  end
end
