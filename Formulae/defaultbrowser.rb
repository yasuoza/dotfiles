class Defaultbrowser < Formula
  desc "Command-line tool for getting & setting the default browser"
  homepage "https://github.com/kerma/defaultbrowser"
  url "https://github.com/kerma/defaultbrowser/archive/1.1.tar.gz"
  sha256 "56249f05da912bbe828153d775dc4f497f5a8b453210c2788d6a439418ac2ea3"
  head "https://github.com/kerma/defaultbrowser.git"
  license "MIT"

  depends_on :macos

  def install
    system "make", "install", "PREFIX=#{prefix}"
  end

  patch do
    url "https://patch-diff.githubusercontent.com/raw/kerma/defaultbrowser/pull/26.patch"
    sha256 "4b99933196b99b62e2b39b01f7604cce6f89f5efa757625a2dd9967112d05dda"
  end

  test do
    # defaultbrowser outputs a list of browsers by default;
    # safari is pretty much guaranteed to be in that list
    assert_match "safari", shell_output("#{bin}/defaultbrowser")
  end
end
