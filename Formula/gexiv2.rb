class Gexiv2 < Formula
  desc "GObject wrapper around the Exiv2 photo metadata library"
  homepage "https://wiki.gnome.org/Projects/gexiv2"
  url "https://download.gnome.org/sources/gexiv2/0.12/gexiv2-0.12.0.tar.xz"
  sha256 "58f539b0386f36300b76f3afea3a508de4914b27e78f58ee4d142486a42f926a"
  revision 2

  bottle do
    sha256 "6f0882e317fe8bc6285dc2724163bfd0664db0b77f64cabe26f2c00bf9c68dd7" => :catalina
    sha256 "61965f1c0527ca5e682512da701a5ced6484d8696c58bcfa685b8e3eee216316" => :mojave
    sha256 "4f4c8959b173352c8b5a833574b977fcadca06e0e0e71d4d64fddd74712708c7" => :high_sierra
    sha256 "0d9cb39dc3e5e04637acb30c4fa34fce68ddfd792a4ade2fc20fcdbd96ae7f97" => :x86_64_linux
  end

  depends_on "gobject-introspection" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "python@3.8" => :build
  depends_on "vala" => :build
  depends_on "exiv2"
  depends_on "glib"

  # submitted upstream as https://gitlab.gnome.org/GNOME/gexiv2/merge_requests/10
  patch :DATA

  def install
    pyver = Language::Python.major_minor_version Formula["python@3.8"].opt_bin/"python3"

    mkdir "build" do
      system "meson", *std_meson_args, "-Dpython3_girdir=#{lib}/python#{pyver}/site-packages/gi/overrides", ".."
      system "ninja"
      system "ninja", "install"
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <gexiv2/gexiv2.h>
      int main() {
        GExiv2Metadata *metadata = gexiv2_metadata_new();
        return 0;
      }
    EOS

    flags = [
      "-I#{HOMEBREW_PREFIX}/include/glib-2.0",
      "-I#{HOMEBREW_PREFIX}/lib/glib-2.0/include",
      "-L#{lib}",
      "-lgexiv2",
    ]

    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end

__END__
diff --git a/gexiv2/meson.build b/gexiv2/meson.build
index 196b298..12abf92 100644
--- a/gexiv2/meson.build
+++ b/gexiv2/meson.build
@@ -2,6 +2,13 @@ pkg = import('pkgconfig')

 as_version = meson.project_version().split('.')

+libversion = '2.0.0'
+libversion_arr = libversion.split('.')
+darwin_version_major = libversion_arr[0].to_int()
+darwin_version_minor = libversion_arr[1].to_int()
+darwin_version_micro = libversion_arr[2].to_int()
+darwin_versions = [darwin_version_major + darwin_version_minor + 1, '@0@.@1@'.format(darwin_version_major + darwin_version_minor + 1, darwin_version_micro)]
+
 gexiv2_include_dir = join_paths(get_option('includedir'), 'gexiv2')

 config = configuration_data()
@@ -53,7 +60,8 @@ gexiv2 = library('gexiv2',
                  [version_header] +
                  enum_sources,
                  include_directories : include_directories('..'),
-                 version: '2.0.0',
+                 version: libversion,
+                 darwin_versions: darwin_versions,
                  dependencies : [gobject, exiv2, gio],
                  install : true)

diff --git a/meson.build b/meson.build
index 601afc1..b84255f 100644
--- a/meson.build
+++ b/meson.build
@@ -2,6 +2,7 @@ project(
     'gexiv2',
     ['c', 'cpp'],
     version : '0.12.0',
+    meson_version : '>=0.48',
     default_options : [
         'cpp_std=c++11'
     ]
