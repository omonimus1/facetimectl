class Facetimectl < Formula
  desc "Fast CLI for FaceTime on macOS - make calls from the terminal"
  homepage "https://github.com/omonimus1/facetimectl"
  url "https://github.com/omonimus1/facetimectl/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "REPLACE_WITH_ACTUAL_SHA256"
  license "MIT"
  head "https://github.com/omonimus1/facetimectl.git", branch: "master"

  depends_on xcode: ["14.0", :build]
  depends_on :macos => :sonoma

  def install
    system "make", "build"
    bin.install "bin/facetimectl"
  end

  test do
    # Test that the binary exists and runs
    assert_match "facetimectl", shell_output("#{bin}/facetimectl --help 2>&1", 1)
  end
end
