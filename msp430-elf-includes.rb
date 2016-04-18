require 'formula'

class Msp430ElfIncludes < Formula
  homepage 'http://www.ti.com/tool/msp430-gcc-opensource'
  url 'http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSPGCC/latest/exports/msp430-gcc-support-files.zip'
  sha256 '84c8571cc6eab96df04685d5bd5f7884a0617435826c79d4dd50b5723b1353d9'

  depends_on 'msp430-elf-gcc'

  def install
    FileUtils.mkdir_p "#{include}/msp430"
    FileUtils.mkdir_p "#{lib}/msp430/ldscripts"
    FileUtils.cp Dir.glob('*.h'), "#{include}/msp430"
    FileUtils.cp Dir.glob('*.ld'), "#{lib}/msp430/ldscripts"
  end
end
