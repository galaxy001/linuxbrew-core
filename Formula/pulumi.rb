class Pulumi < Formula
  desc "Cloud native development platform"
  homepage "https://pulumi.io/"
  url "https://github.com/pulumi/pulumi.git",
      :tag      => "v2.2.1",
      :revision => "d01a84eee899af57a871125720ce227619bbb303"

  bottle do
    cellar :any_skip_relocation
    sha256 "d34217b06b53ef5e6a45a43345ce7beab4e8de8790803df1b5b3baaabefac1a1" => :catalina
    sha256 "3ea6c9744c70e979d1d830c66af1669f9352d00c6ce41b42be1b726cea65c86d" => :mojave
    sha256 "9a5d2a44994d778f4333fb2cc6980b11705d3941b8aab447fb56e99e0ce280bf" => :high_sierra
    sha256 "176334acf23bc601a46aa931b10e22fecb965f27de0ab78f7ac49b2df7091db3" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    ENV["GO111MODULE"] = "on"

    dir = buildpath/"src/github.com/pulumi/pulumi"
    dir.install buildpath.children

    cd dir do
      cd "./sdk" do
        system "go", "mod", "download"
      end
      cd "./pkg" do
        system "go", "mod", "download"
      end
      system "make", "brew"
      bin.install Dir["#{buildpath}/bin/*"]
      prefix.install_metafiles

      # Install bash completion
      output = Utils.popen_read("#{bin}/pulumi gen-completion bash")
      (bash_completion/"pulumi").write output

      # Install zsh completion
      output = Utils.popen_read("#{bin}/pulumi gen-completion zsh")
      (zsh_completion/"_pulumi").write output
    end
  end

  test do
    ENV["PULUMI_ACCESS_TOKEN"] = "local://"
    ENV["PULUMI_TEMPLATE_PATH"] = testpath/"templates"
    system "#{bin}/pulumi", "new", "aws-typescript", "--generate-only",
                                                     "--force", "-y"
    assert_predicate testpath/"Pulumi.yaml", :exist?, "Project was not created"
  end
end
