class Typedb < Formula
  desc "Strongly-typed database with a rich and logical type system"
  homepage "https://vaticle.com/"
  url "https://github.com/vaticle/typedb/releases/download/2.14.3/typedb-all-mac-2.14.3.zip"
  sha256 "41a574d4d0fafcdfd678599b488dfb3aa7e2c4664e111dbd479bdf0a4dbd12a7"
  license "AGPL-3.0-or-later"

  bottle do
    rebuild 2
    sha256 cellar: :any_skip_relocation, all: "1a5bb362fcac01b2f2a1e533857ad5afa7195abfa419f92e8b498a72efd78646"
  end

  depends_on "openjdk"

  def install
    libexec.install Dir["*"]
    mkdir_p var/"typedb/data"
    inreplace libexec/"server/conf/config.yml", "server/data", var/"typedb/data"
    mkdir_p var/"typedb/logs"
    inreplace libexec/"server/conf/config.yml", "server/logs", var/"typedb/logs"
    bin.install libexec/"typedb"
    bin.env_script_all_files(libexec, Language::Java.java_home_env)
  end

  test do
    assert_match "A STRONGLY-TYPED DATABASE", shell_output("#{bin}/typedb server --help")
  end
end
