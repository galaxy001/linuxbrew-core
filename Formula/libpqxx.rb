class Libpqxx < Formula
  desc "C++ connector for PostgreSQL"
  homepage "https://pqxx.org/development/libpqxx/"
  url "https://github.com/jtv/libpqxx/archive/6.4.5.tar.gz"
  sha256 "86921fdb0fe54495a79d5af2c96f2c771098c31e9b352d0834230fd2799ad362"
  revision 5

  bottle do
    cellar :any
    sha256 "9f7a06c5aec1200b4c27e754fa0f751cf5084065b4dd268f870d60eca30257c5" => :catalina
    sha256 "461042302eadaee751e2792402f25bf190386fd9f443a4b5f00be2acb8d47474" => :mojave
    sha256 "9f1202b31703fb3b716668de6e9b48543faf517e6e419cb68b61d92bad20cb47" => :high_sierra
    sha256 "aa8205b8d395b76a4ce19e0040823f583815c779c03903c432684f1d7ecd6aae" => :x86_64_linux
  end

  depends_on "pkg-config" => :build
  depends_on "python@3.8" => :build
  depends_on "xmlto" => :build
  depends_on "libpq"
  depends_on "postgresql"

  unless OS.mac?
    depends_on "doxygen" => :build
    depends_on "xmlto" => :build
  end

  def install
    ENV.prepend_path "PATH", Formula["python@3.8"].opt_libexec/"bin"
    ENV["PG_CONFIG"] = Formula["libpq"].opt_bin/"pg_config"

    system "./configure", "--prefix=#{prefix}", "--enable-shared"
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <pqxx/pqxx>
      int main(int argc, char** argv) {
        pqxx::connection con;
        return 0;
      }
    EOS
    system ENV.cxx, "-std=c++11", "test.cpp", "-L#{lib}", "-lpqxx",
           "-I#{include}", "-o", "test"
    # Running ./test will fail because there is no runnning postgresql server
    # system "./test"
  end
end
