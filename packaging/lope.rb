# lope's Homebrew formula, PREPARED, NOT PUBLISHED (the track's rule 5):
# a release lane fills the two digests from the release's own archives and
# opens it against wolffe-lang/homebrew-wolf on the maintainer's word.
#
# A prebuilt archive, as lobo's formula is and for lobo's reason: lope pins
# its compiler by EXACT identity (`wolf-toolchain.toml`, `version_line`),
# so a source formula saying `depends_on "wolf"` would break the day the
# wolf formula moved past 0.2.34. The archive is built from the pin by the
# release workflow. Shape: tenseleyFlow/homebrew-tap's gump.rb (caveats,
# test) and homebrew-wolf's lobo.rb (the archives).
class Lope < Formula
  desc "Frecency directory jumper in wolf: type a fragment, land where you meant"
  homepage "https://github.com/wolffe-lang/lope"
  license "GPL-3.0-or-later"
  version "0.1.0"

  on_macos do
    on_arm do
      url "https://github.com/wolffe-lang/lope/releases/download/v0.1.0/lope-0.1.0-aarch64-apple-darwin.tar.gz"
      sha256 "RELEASE-LANE-FILLS-THIS"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/wolffe-lang/lope/releases/download/v0.1.0/lope-0.1.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "RELEASE-LANE-FILLS-THIS"
    end
  end

  def install
    bin.install "lope"
    doc.install "README.md", "CHANGELOG.md"
  end

  def caveats
    <<~EOS
      Add to your shell config:

      Bash (~/.bashrc):
        eval "$(lope init bash)"

      Zsh (~/.zshrc):
        eval "$(lope init zsh)"

      Fish (~/.config/fish/config.fish):
        lope init fish | source

      Then restart your shell or source the config file.

      Usage:
        g foo        # jump to best match
        gi foo       # pick from the matches (fzf, or a numbered menu)
        foo          # no prefix needed
        g            # go home
        g -          # go back

      Import existing data:
        lope import  # imports from gump/zoxide/autojump/z/fasd
    EOS
  end

  test do
    assert_match "lope", shell_output("#{bin}/lope --help")
    assert_match "lope #{version}", shell_output("#{bin}/lope --version")
  end
end
