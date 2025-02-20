require "language/node"

class AskCli < Formula
  desc "CLI tool for Alexa Skill Kit"
  homepage "https://www.npmjs.com/package/ask-cli"
  url "https://registry.npmjs.org/ask-cli/-/ask-cli-2.6.0.tgz"
  sha256 "53d2f22cb9048b90be165860ebd4e925fe7b86094af717d8c13d3ca16bdf46f3"

  bottle do
    cellar :any_skip_relocation
    sha256 "3cf2959971e9f55a1eef0785e6b4088cb809b8ef4fa9e5fc87505a76c7d43ea6" => :catalina
    sha256 "f03e8d98526e6d13250b83e9198f4ef5903369ba0f160a68af3ad9db6bb7208b" => :mojave
    sha256 "5e2d1ffbc8ba316de0c928db1a1400ac076d1368d1a115ecd5520c2146cdbf72" => :high_sierra
    sha256 "afceb5452d0649417caa8d8014d36d474361486a11314e6e5a4ff4e65e73cbdd" => :x86_64_linux
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.write_exec_script libexec/"bin/ask"
  end

  test do
    output = shell_output("#{bin}/ask deploy 2>&1", 1)
    assert_match "no such file or directory, open '#{testpath}/.ask/cli_config'", output
    system "#{bin}/ask", "lambda", "--help"
  end
end
