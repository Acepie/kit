# typed: false
# frozen_string_literal: true

# This file was generated by GoReleaser. DO NOT EDIT.
class Kit < Formula
  desc "Kitful local dev."
  homepage "https://github.com/alexec/kit"
  version "0.0.28"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/alexec/kit/releases/download/v0.0.28/kit_0.0.28_Darwin_arm64.tar.gz"
      sha256 "763fb013cbb2194c500327767391f329557be5c6869680b7158e5913be7bebfd"

      def install
        bin.install "kit"
      end
    end
    if Hardware::CPU.intel?
      url "https://github.com/alexec/kit/releases/download/v0.0.28/kit_0.0.28_Darwin_x86_64.tar.gz"
      sha256 "90fcfa84877c3435500158e33335cc0b3825ffbb9a0e202657f68272ce0368ae"

      def install
        bin.install "kit"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/alexec/kit/releases/download/v0.0.28/kit_0.0.28_Linux_arm64.tar.gz"
      sha256 "36f60c7f165de53d2a58495c1c6d1af6dd57467b30510ed8d33f3e82e971d743"

      def install
        bin.install "kit"
      end
    end
    if Hardware::CPU.intel?
      url "https://github.com/alexec/kit/releases/download/v0.0.28/kit_0.0.28_Linux_x86_64.tar.gz"
      sha256 "4d6427425b993a2779aeea909f5c77bf5ed0691ea77e58716b608129084ea2eb"

      def install
        bin.install "kit"
      end
    end
  end
end
