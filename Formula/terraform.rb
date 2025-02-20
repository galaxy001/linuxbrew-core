class Terraform < Formula
  desc "Tool to build, change, and version infrastructure"
  homepage "https://www.terraform.io/"
  url "https://github.com/hashicorp/terraform/archive/v0.12.25.tar.gz"
  sha256 "e4962e0ff928af9ba47e20976c2d9144020ef39930549c00bb79a9874759bf92"
  head "https://github.com/hashicorp/terraform.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "aed44cc014be831a8148b0e3d469c7b49439ca9a576d09cd3bed032d568765f4" => :catalina
    sha256 "ec4b54ad081e4915ec38fddb08b01b58c15e68f1eb10efa39e36553c1ba047db" => :mojave
    sha256 "f7cab3c4023c625e47e00f2ead49b68fee1c01a2cfdc4e34e46757df0f10c080" => :high_sierra
    sha256 "c9d7549418b15eea48aeb6bf90bf240b41d04de7eeb185e769f354038d6ff73d" => :x86_64_linux
  end

  depends_on "go@1.13" => :build
  depends_on "gox" => :build

  conflicts_with "tfenv", :because => "tfenv symlinks terraform binaries"

  def install
    ENV["GOPATH"] = buildpath
    ENV["GO111MODULE"] = "on" unless OS.mac?
    ENV.prepend_create_path "PATH", buildpath/"bin"

    dir = buildpath/"src/github.com/hashicorp/terraform"
    dir.install buildpath.children - [buildpath/".brew_home"]

    cd dir do
      # v0.6.12 - source contains tests which fail if these environment variables are set locally.
      ENV.delete "AWS_ACCESS_KEY"
      ENV.delete "AWS_SECRET_KEY"

      os = OS.mac? ? "darwin" : "linux"
      ENV["XC_OS"] = os
      ENV["XC_ARCH"] = "amd64"
      system "make", "tools", "bin"

      bin.install "pkg/#{os}_amd64/terraform"
      prefix.install_metafiles
    end
  end

  test do
    minimal = testpath/"minimal.tf"
    minimal.write <<~EOS
      variable "aws_region" {
        default = "us-west-2"
      }

      variable "aws_amis" {
        default = {
          eu-west-1 = "ami-b1cf19c6"
          us-east-1 = "ami-de7ab6b6"
          us-west-1 = "ami-3f75767a"
          us-west-2 = "ami-21f78e11"
        }
      }

      # Specify the provider and access details
      provider "aws" {
        access_key = "this_is_a_fake_access"
        secret_key = "this_is_a_fake_secret"
        region     = var.aws_region
      }

      resource "aws_instance" "web" {
        instance_type = "m1.small"
        ami           = var.aws_amis[var.aws_region]
        count         = 4
      }
    EOS
    system "#{bin}/terraform", "init"
    system "#{bin}/terraform", "graph"
  end
end
