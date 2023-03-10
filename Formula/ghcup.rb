class Ghcup < Formula
  desc "Installer for the general purpose language Haskell"
  homepage "https://www.haskell.org/ghcup/"
  # There is a tarball at Hackage, but that doesn't include the shell completions.
  #
  # TODO: Try to switch `ghc@9.2` to `ghc` when ghcup.cabal allows Cabal>=3.8
  url "https://github.com/haskell/ghcup-hs/archive/refs/tags/v0.1.19.2.tar.gz"
  sha256 "47c85ca6ced22f62831c9f14b7ff5feec3d6d5ba24af089ac223ed1c8d0fe47d"
  license "LGPL-3.0-only"
  head "https://github.com/haskell/ghcup-hs.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "ee4f1a86557ac6b88f8f3e269b52179d63e1f8b7406b516ac0168d31101ba371"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "c989798db8fde98e1076517843503841c5ac7f0fea5cf622d60a5acc99640ae3"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "633c6862e2fa5e15d11785f1d518aae31b5fd0e99f498292f107ae29dd62baff"
    sha256 cellar: :any_skip_relocation, ventura:        "2cf2a2a43980b834ad9bd78c8bb6f68de6f9bdabb7d0eacf3ddc7690b20144fd"
    sha256 cellar: :any_skip_relocation, monterey:       "72b80bdf221fcb1cc8d2a98943fb386e046b809273b465f52cccde0eae5b2221"
    sha256 cellar: :any_skip_relocation, big_sur:        "9c0116c13ec9256796e28a2bfdea41dcb3b067b37b0391916fc1af9abc62fe4a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "9de0ef449d87c12cca1f3c5585176fa2ab7e72b351fcfad685e1bad9803b52e0"
  end

  depends_on "cabal-install" => :build
  depends_on "ghc@9.2" => :build
  uses_from_macos "ncurses"
  uses_from_macos "zlib"

  def install
    system "cabal", "v2-update"
    # `+disable-upgrade` disables the self-upgrade feature.
    system "cabal", "v2-install", *std_cabal_v2_args, "--flags=+disable-upgrade"

    bash_completion.install "scripts/shell-completions/bash" => "ghcup"
    fish_completion.install "scripts/shell-completions/fish" => "ghcup.fish"
    zsh_completion.install "scripts/shell-completions/zsh" => "_ghcup"
  end

  test do
    assert_match "ghc", shell_output("#{bin}/ghcup list")
  end
end
