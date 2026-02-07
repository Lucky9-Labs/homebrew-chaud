# typed: false
# frozen_string_literal: true

class Chaud < Formula
  desc "CLI for managing git worktrees with Claude Code integration"
  homepage "https://github.com/Lucky9-Labs/chaud"
  url "https://github.com/Lucky9-Labs/chaud/archive/refs/tags/v0.0.2.tar.gz"
  sha256 "bf8ed91269e1941799d381989e91f86813493f50348509788dbf473aa05368a4"
  license "MIT"
  head "https://github.com/Lucky9-Labs/chaud.git", branch: "main"

  depends_on "jq"
  depends_on "yq"

  def install
    # Install main script
    bin.install "chaud"

    # Install library files
    (libexec/"lib").install Dir["lib/*.sh"]

    # Install workflow templates
    (share/"chaud/workflows").install Dir["workflows/*.yml"]

    # Patch the script to find libraries in the correct location
    inreplace bin/"chaud" do |s|
      s.gsub! 'CHAUD_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"',
              "CHAUD_SCRIPT_DIR=\"#{libexec}\""
    end
  end

  def caveats
    <<~EOS
      To get started:
        chaud config init     # Set up configuration
        chaud --help          # See available commands

      For cloud features, set environment variables:
        export GITHUB_TOKEN=ghp_...
        export ANTHROPIC_API_KEY=sk-...
    EOS
  end

  test do
    assert_match "chaud", shell_output("#{bin}/chaud --version")
    assert_match "0.0.2", shell_output("#{bin}/chaud --version")

    # Test config path works
    ENV["CHAUD_CONFIG_DIR"] = testpath/".chaud"
    assert_match "config.yaml", shell_output("#{bin}/chaud config path")
  end
end
