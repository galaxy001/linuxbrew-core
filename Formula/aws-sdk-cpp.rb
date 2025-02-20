class AwsSdkCpp < Formula
  desc "AWS SDK for C++"
  homepage "https://github.com/aws/aws-sdk-cpp"
  # aws-sdk-cpp should only be updated every 10 releases on multiples of 10
  url "https://github.com/aws/aws-sdk-cpp/archive/1.7.330.tar.gz"
  sha256 "0704fe4bcce804009ef207e679c6277c0ac0fe6ab7ff3710e18f7d49a47f8fd2"
  head "https://github.com/aws/aws-sdk-cpp.git"

  bottle do
    sha256 "5ee33d037d8ea5a58f997eae710d7643ad3aaa08ff4185dfea0641b66566cd86" => :catalina
    sha256 "a65980188b2db0f47664ec006d96f7e2a9d1a53bc9d59e11ff1e868044c31463" => :mojave
    sha256 "0d8103b4d82f1e7741a41c6b61dc58ec36c947cd332dd2e1d3dfe5ae2b287fad" => :high_sierra
    sha256 "abccb95454519908e5ff6081ccbc1214e79fceea0281b8802ab211aa21aa06c3" => :x86_64_linux
  end

  depends_on "cmake" => :build

  uses_from_macos "curl"

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make"
      system "make", "install"
    end

    lib.install Dir[lib/"mac/Release/*"].select { |f| File.file? f }
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <aws/core/Version.h>
      #include <iostream>

      int main() {
          std::cout << Aws::Version::GetVersionString() << std::endl;
          return 0;
      }
    EOS
    system ENV.cxx, "-std=c++11", "test.cpp", "-L#{lib}", "-laws-cpp-sdk-core",
           "-o", "test"
    system "./test"
  end
end
