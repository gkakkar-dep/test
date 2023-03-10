class Teleport < Formula
  desc "Modern SSH server for teams managing distributed infrastructure"
  homepage "https://gravitational.com/teleport"
  url "https://github.com/gravitational/teleport/archive/v11.3.1.tar.gz"
  sha256 "707b4226410fd81b8fdfc3e06b45d0cd573872fe9eb74caebf1d73f78dbe681d"
  license "Apache-2.0"
  head "https://github.com/gravitational/teleport.git", branch: "master"

  # We check the Git tags instead of using the `GithubLatest` strategy, as the
  # "latest" version can be incorrect. As of writing, two major versions of
  # `teleport` are being maintained side by side and the "latest" tag can point
  # to a release from the older major version.
  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any,                 arm64_ventura:  "f19b1d83d9eb4a3cabb9e32929a6f6d85fb04305adeb3371b15f435ac7d2f885"
    sha256 cellar: :any,                 arm64_monterey: "3027e7c33163261aa7bd1d706de4b581f7676245f93d7611b102e1b4bdbb054a"
    sha256 cellar: :any,                 arm64_big_sur:  "66bca40edeaf6a17723f34f8e697c474df5332e8cff65ca37cce19ecfc5b18df"
    sha256 cellar: :any,                 ventura:        "19586a3b43d9ee2bfd7def5cfb6e3c1aebad8cec81c07c38f96b206fa12e31b6"
    sha256 cellar: :any,                 monterey:       "de1873f479acfaf8819a6e916cdc1b2e7507b0b4a658ffca443bd424879c753c"
    sha256 cellar: :any,                 big_sur:        "654371fdf09c565aab64867abc9862039247d892244deb96166cc11923f7c634"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "784ef9c0c2125161c7583858c9e7cf8871de4d6a32f59e7642f3db16173005dd"
  end

  depends_on "go" => :build
  depends_on "pkg-config" => :build
  depends_on "libfido2"

  uses_from_macos "curl" => :test
  uses_from_macos "netcat" => :test
  uses_from_macos "zip"

  conflicts_with "etsh", because: "both install `tsh` binaries"

  # Keep this in sync with https://github.com/gravitational/teleport/tree/v#{version}
  resource "webassets" do
    url "https://github.com/gravitational/webassets/archive/5c619e15216a9a3b06ef517d44292f0443f8674f.tar.gz"
    sha256 "e3070df51ff01cc3297cbc7998b4cfb2e26db9d602a58233c89e89dfcfdd5d0d"
  end

  def install
    (buildpath/"webassets").install resource("webassets")
    ENV.deparallelize { system "make", "full", "FIDO2=dynamic" }
    bin.install Dir["build/*"]
  end

  test do
    curl_output = shell_output("curl \"https://api.github.com/repos/gravitational/teleport/contents/webassets?ref=v#{version}\"")
    assert_match JSON.parse(curl_output)["sha"], resource("webassets").url
    assert_match version.to_s, shell_output("#{bin}/teleport version")
    assert_match version.to_s, shell_output("#{bin}/tsh version")
    assert_match version.to_s, shell_output("#{bin}/tctl version")

    mkdir testpath/"data"
    (testpath/"config.yml").write <<~EOS
      version: v2
      teleport:
        nodename: testhost
        data_dir: #{testpath}/data
        log:
          output: stderr
          severity: WARN
    EOS

    fork do
      exec "#{bin}/teleport start --roles=proxy,node,auth --config=#{testpath}/config.yml"
    end

    sleep 10
    system "curl", "--insecure", "https://localhost:3080"

    status = shell_output("#{bin}/tctl --config=#{testpath}/config.yml status")
    assert_match(/Cluster\s*testhost/, status)
    assert_match(/Version\s*#{version}/, status)
  end
end
