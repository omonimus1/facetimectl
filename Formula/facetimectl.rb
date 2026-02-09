class Facetimectl < Formula
  desc "Fast CLI for FaceTime on macOS - make calls from the terminal"
  homepage "https://github.com/omonimus1/facetimectl"
  url "https://github.com/omonimus1/facetimectl/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "7a3eb5097d324d9df17301b57c6187c8957075729e6a88a2f9eb64d74f59bf39"
  license "MIT"
  head "https://github.com/omonimus1/facetimectl.git", branch: "master"

  depends_on xcode: ["16.0", :build]
  depends_on macos: :sonoma

  def install
    system "swift", "build", "--disable-sandbox", "-c", "release", "--product", "facetimectl"
    bin.install ".build/release/facetimectl"
  end

  test do
    # Test that the binary exists and runs
    assert_match "facetimectl", shell_output("#{bin}/facetimectl --help 2>&1", 1)
  end
end
