class Fastfetch < Formula
  desc "Like neofetch, but much faster because written in C"
  homepage "https://github.com/LinusDierheimer/fastfetch"
  url "https://github.com/LinusDierheimer/fastfetch/archive/refs/tags/1.9.1.tar.gz"
  sha256 "0b6d31bc213282b26a7c2fc9706d41e1669a7ea8875154ba6aed1ba428c92b3d"
  license "MIT"
  head "https://github.com/LinusDierheimer/fastfetch.git", branch: "dev"

  bottle do
    sha256 arm64_ventura:  "413d533adf5b137af7f17d1aaa406b9f44a9e70573e74e68b8662f2db0863f0f"
    sha256 arm64_monterey: "7f0cae97b16833b2a8782e77fce5a6010370e674585f5549bfaaff8b608406cf"
    sha256 arm64_big_sur:  "9871c140d2298306b980ca3f39ec74a3bb947d0cb1010a82bf692a7c1003ab3d"
    sha256 ventura:        "d686cd6db111b2d7287dbaa2901ca5dc6b7b599cc31f6ac86446d79a091dec9c"
    sha256 monterey:       "58a20c8d21345557c6bdea88368c035e57b436b9ed83f617c66318248fe4d34b"
    sha256 big_sur:        "30f73fcd74fc6a3424945e369d526f236fe4a335acb890a4a86ecaf11d484e37"
    sha256 x86_64_linux:   "3c8fbefc8fd8e3f487d6d3e1d3739d571149b61dcc785183ca1b5466bebecd7c"
  end

  depends_on "chafa" => :build
  depends_on "cmake" => :build
  depends_on "glib" => :build
  depends_on "imagemagick" => :build
  depends_on "pkg-config" => :build
  depends_on "vulkan-loader" => :build

  uses_from_macos "zlib" => :build

  def install
    system "cmake", "-S", ".", "-B", "build", "-DCMAKE_INSTALL_SYSCONFDIR=#{etc}", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_match "fastfetch", shell_output("#{bin}/fastfetch --version")
    assert_match "OS", shell_output("#{bin}/fastfetch --structure OS --logo none --hide-cursor false")
  end
end
