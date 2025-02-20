class ImagemagickAT6 < Formula
  desc "Tools and libraries to manipulate images in many formats"
  homepage "https://www.imagemagick.org/"
  # Please always keep the Homebrew mirror as the primary URL as the
  # ImageMagick site removes tarballs regularly which means we get issues
  # unnecessarily and older versions of the formula are broken.
  url "https://dl.bintray.com/homebrew/mirror/imagemagick%406-6.9.11-11.tar.xz"
  mirror "https://www.imagemagick.org/download/releases/ImageMagick-6.9.11-11.tar.xz"
  sha256 "2237ab782f3c04b31d018a4f0483094d48a0042c7e6273325604d47d6fcec7ac"
  head "https://github.com/imagemagick/imagemagick6.git"

  bottle do
    sha256 "0f201307da4e82ee2ecd698417309feba85681bb311c5079cf34d0e2adf514c1" => :catalina
    sha256 "850ba6891fe73033871e69640f82a82e66a218e5f09ba32c2249058fd84f5e52" => :mojave
    sha256 "bbfc1facb8d4179d0a345fad56321c25c4635b60621a05e529ef62df6d9b2dd5" => :high_sierra
    sha256 "6df23ba57d71ee1da60fae214482139b6b23e15281fe723905321a4a5f05a2cb" => :x86_64_linux
  end

  keg_only :versioned_formula

  depends_on "pkg-config" => :build

  depends_on "freetype"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "libtool"
  depends_on "little-cms2"
  depends_on "openjpeg"
  depends_on "webp"
  depends_on "xz"

  skip_clean :la

  def install
    # Avoid references to shim
    inreplace Dir["**/*-config.in"], "@PKG_CONFIG@", Formula["pkg-config"].opt_bin/"pkg-config"

    args = %W[
      --disable-osx-universal-binary
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-opencl
      --disable-openmp
      --enable-shared
      --enable-static
      --with-freetype=yes
      --with-modules
      --with-webp=yes
      --with-openjp2
      --without-gslib
      --with-gs-font-dir=#{HOMEBREW_PREFIX}/share/ghostscript/fonts
      --without-fftw
      --without-pango
      --without-x
      --without-wmf
    ]

    # versioned stuff in main tree is pointless for us
    inreplace "configure", "${PACKAGE_NAME}-${PACKAGE_VERSION}", "${PACKAGE_NAME}"
    system "./configure", *args
    system "make", "install"
  end

  test do
    assert_match "PNG", shell_output("#{bin}/identify #{test_fixtures("test.png")}")
    # Check support for recommended features and delegates.
    features = shell_output("#{bin}/convert -version")
    %w[Modules freetype jpeg png tiff].each do |feature|
      assert_match feature, features
    end
  end
end
