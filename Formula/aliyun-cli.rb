class AliyunCli < Formula
  desc "Universal Command-Line Interface for Alibaba Cloud"
  homepage "https://github.com/aliyun/aliyun-cli"
  url "https://github.com/aliyun/aliyun-cli/archive/v3.0.42.tar.gz"
  sha256 "83957942c9c0ebf0e529f0b0e0bd9662db7a4eff85f9842d5610c794007b081e"

  bottle do
    cellar :any_skip_relocation
    sha256 "1c2b7f5f0cbfb9206d79e48a45cd9de6857686a58aa92425f336c1ce9d26b68a" => :catalina
    sha256 "9a48fcc341da2fbe78ff83100f00b2d5ad26efade8d630e80f575a0b8a4c032d" => :mojave
    sha256 "8711e480dc709fc05201c3ecaeb2a5427f59718b7e190a0aa5442b24045f748d" => :high_sierra
    sha256 "d38f17a733b41c422774139499699ef5e7067c39034ea52c53542a5c02d9059c" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV["GO111MODULE"] = "off"
    ENV["GOPATH"] = buildpath
    ENV["PATH"] = "#{ENV["PATH"]}:#{buildpath}/bin"
    (buildpath/"src/github.com/aliyun/aliyun-cli").install buildpath.children
    cd "src/github.com/aliyun/aliyun-cli" do
      system "make", "metas"
      system "go", "build", "-o", bin/"aliyun", "-ldflags",
                            "-X 'github.com/aliyun/aliyun-cli/cli.Version=#{version}'", "main/main.go"
      prefix.install_metafiles
    end
  end

  test do
    version_out = shell_output("#{bin}/aliyun version")
    assert_match version.to_s, version_out

    help_out = shell_output("#{bin}/aliyun --help")
    assert_match "Alibaba Cloud Command Line Interface Version #{version}", help_out
    assert_match "", help_out
    assert_match "Usage:", help_out
    assert_match "aliyun <product> <operation> [--parameter1 value1 --parameter2 value2 ...]", help_out

    oss_out = shell_output("#{bin}/aliyun oss")
    assert_match "Object Storage Service", oss_out
    assert_match "aliyun oss [command] [args...] [options...]", oss_out
  end
end
