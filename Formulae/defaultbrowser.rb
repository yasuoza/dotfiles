class Defaultbrowser < Formula
  desc "Command-line tool for getting & setting the default browser"
  homepage "https://github.com/kerma/defaultbrowser"
  url "https://github.com/kerma/defaultbrowser/archive/1.1.tar.gz"
  sha256 "56249f05da912bbe828153d775dc4f497f5a8b453210c2788d6a439418ac2ea3"
  head "https://github.com/kerma/defaultbrowser.git"
  license "MIT"

  depends_on :macos

  patch do
    url "https://github.com/saifulwebid/defaultbrowser/commit/e9541fa7d6aa0f9977d65fd2e777a7422ca73032.diff"
    sha256 "333a1fddbbc98a879a0ad476dcc5c223a22459b39610c828e6b5b9d8e720c3d6"
  end

  def install
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    # defaultbrowser outputs a list of browsers by default;
    # safari is pretty much guaranteed to be in that list
    assert_match "safari", shell_output("#{bin}/defaultbrowser")
  end
end
