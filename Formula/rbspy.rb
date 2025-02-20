class Rbspy < Formula
  desc "Sampling profiler for Ruby"
  homepage "https://rbspy.github.io/"
  url "https://github.com/rbspy/rbspy/archive/v0.3.9.tar.gz"
  sha256 "5c78e84d36187698306df9e28dabdd4518ccc9cf3d842965838b80b1ac3a734a"

  bottle do
    cellar :any_skip_relocation
    sha256 "e9ef4b13bb8e0d760df3268edbca197564d7573858672d82d78e92182d67d077" => :catalina
    sha256 "3ccd7c51b5873ce28368ae43a9ce15e60345ac4b9af1d281059454b7122d27c8" => :mojave
    sha256 "aab79afbda88f0a46aa4bc8fdf7b38b06651ba831fb77d171dfa6ace3f601e02" => :high_sierra
    sha256 "e489b742b0d4c41de85e28cacb4b5bb3143cd397b7872dd5b8897b14de5aa0b5" => :x86_64_linux
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", "--locked", "--root", prefix, "--path", "."
  end

  test do
    recording = <<~EOS
      H4sICCOlhlsAA2JyZXdfdGVzdF9yZXN1bHQAvdHBCsIwDAbgu08hOQ/nHKgM8S08iYy0Vlds0
      5J2Dhl7d3eZTNxN8Rb4yf9BwiL4xzKbtRAZpYLi2AKh7QfYyfmlJhm1oz0kwMpg1HdVeoxVH9
      d0I9dQn6AIztRxSKg2JgGjSZGDYtklr0ZEnCgKleNYenZXRrtg8dkI6SEoDmnlrEoFqyYNaL1
      R70uDuBqJQogpcWL7K3I9IqWU/yCz8WF3FvXkk37P5t0pAa/PUOTbfLvpZk/I+tcWQgIAAA==
    EOS

    (testpath/"recording.gz").write Base64.decode64(recording.delete("\n"))
    system "#{bin}/rbspy", "report", "-f", "summary", "-i", "recording.gz",
                           "-o", "result"

    expected_result = "100.00   100.00  aaa - short_program.rb"
    assert_includes File.read("result"), expected_result
  end
end
