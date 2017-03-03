require 'formula'

class Msp430ElfGcc < Formula
  homepage 'http://gcc.gnu.org'

  url 'http://ftpmirror.gnu.org/gcc/gcc-4.9.2/gcc-4.9.2.tar.bz2'
  mirror 'ftp://gcc.gnu.org/pub/gcc/releases/gcc-4.9.2/gcc-4.9.2.tar.bz2'
  sha256 '2020c98295856aa13fda0f2f3a4794490757fc24bcca918d52cc8b4917b972dd'

  head 'svn://gcc.gnu.org/svn/gcc/branches/gcc-4_9-branch'

  depends_on 'msp430-elf-binutils'

  fails_with :clang
  fails_with :llvm

  def install
    target = 'msp430-elf'
    binutils = Formulary.factory "#{target}-binutils"
    ENV['PATH'] += ":#{binutils.bin}:#{bin}"

    languages = %w[c c++]

    args = [
      "--target=#{target}",
      "--prefix=#{prefix}",
      "--enable-languages=#{languages.join(',')}",
      "--program-prefix=msp430-elf-",
      "--disable-nls",
      "--with-newlib",
      "--with-as=#{binutils.bin}/#{target}-as",
      "--with-ld=#{binutils.bin}/#{target}-ld",
      "--enable-version-specific-runtime-libs",
      "CFLAGS=-std=gnu89",
    ]

    mkdir 'build'
    chdir 'build' do
      system '../configure', *args
      system 'make', 'all-host'
      system 'make', 'install-host'
    end

    newlib = Formulary.factory "#{target}-newlib"
    newlib.brew do
      system 'mkdir', '-p', "#{HOMEBREW_LOGS}/#{newlib.name}"
      newlib_args = [
        "--target=#{target}",
        "--prefix=#{prefix}",
        "--disable-newlib-supplied-syscalls",
        "--enable-newlib-reent-small",
        "--disable-newlib-fseek-optimization",
        "--disable-newlib-wide-orient",
        "--enable-newlib-nano-formatted-io",
        "--disable-newlib-io-float",
        "--enable-newlib-nano-malloc",
        "--disable-newlib-unbuf-stream-opt",
        "--enable-lite-exit",
        "--enable-newlib-global-atexit",
        "--disable-nls",
      ]

      system "./configure", *newlib_args

      system "make"
      system 'make', 'installdirs'
      system 'make', 'install-host'
      system 'make', 'install-target-newlib'
      system 'make', 'install-target-libgloss'
    end

    chdir 'build' do
      system 'make', 'all-target'
      system 'make', 'install-target'
    end

    info.rmtree
    share.rmtree

    def caveats; <<-EOS.unindent
      Installing this package along side gcc has been known to result in linking errors.
      The following is a workaround for dealing with those linking errors:
        brew unlink gcc
        mkdir /usr/local/lib/gcc
        brew link gcc
        brew link msp430-elf-gcc
      EOS
    end
  end
end
