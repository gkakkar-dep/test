class Libadwaita < Formula
  desc "Building blocks for modern adaptive GNOME applications"
  homepage "https://gnome.pages.gitlab.gnome.org/libadwaita/"
  url "https://download.gnome.org/sources/libadwaita/1.2/libadwaita-1.2.1.tar.xz"
  sha256 "326f142a4f0f3de5a63f0d5e7a9de66ea85348a4726cbfd13930dcf666d22779"
  license "LGPL-2.1-or-later"

  # libadwaita doesn't use GNOME's "even-numbered minor is stable" version
  # scheme. This regex is the same as the one generated by the `Gnome` strategy
  # but it's necessary to avoid the related version scheme logic.
  livecheck do
    url :stable
    regex(/libadwaita-(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 arm64_ventura:  "9db1460faf1cc8266a0f13c8294b170d846e7512a6ace62026d5ca7c640cb0a0"
    sha256 arm64_monterey: "d909dfd2586415138caea0f2b10329db7594149c8aea5f929ecf76ef832fcf82"
    sha256 arm64_big_sur:  "832452f785166f98c3f5a7c1cc59d092969798cb9d714d3dcb4c53a421e60868"
    sha256 ventura:        "e7b55558cd6a97c5693a8c9ed43c2a000f06810fe6604533bb46662fb63fd468"
    sha256 monterey:       "811f8e0e8a02a50bec50d8bcc0cb7a83d1e465bfdd5f90d56aec085e34ab9c0a"
    sha256 big_sur:        "b0df701b7b5040bcd65c060aaab97ef3e2ebde28cc2c4e41764cd4db89e35214"
    sha256 x86_64_linux:   "af2ba8cfcd2daf6b7a3bf6179f4d34d5106ead47ba06cfa1ff0d0e305d6abd46"
  end

  depends_on "gettext" => :build
  depends_on "gobject-introspection" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => [:build, :test]
  depends_on "vala" => :build
  depends_on "gtk4"

  def install
    system "meson", "setup", "build", "-Dtests=false", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    # Remove when `jpeg-turbo` is no longer keg-only.
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["jpeg-turbo"].opt_lib/"pkgconfig"

    (testpath/"test.c").write <<~EOS
      #include <adwaita.h>

      int main(int argc, char *argv[]) {
        g_autoptr (AdwApplication) app = NULL;
        app = adw_application_new ("org.example.Hello", G_APPLICATION_FLAGS_NONE);
        return g_application_run (G_APPLICATION (app), argc, argv);
      }
    EOS
    flags = shell_output("#{Formula["pkg-config"].opt_bin}/pkg-config --cflags --libs libadwaita-1").strip.split
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test", "--help"

    # include a version check for the pkg-config files
    assert_match version.to_s, (lib/"pkgconfig/libadwaita-1.pc").read
  end
end
