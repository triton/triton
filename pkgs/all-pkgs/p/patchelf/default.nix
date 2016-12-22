{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "patchelf-0.9";

  src = fetchurl {
    url = "https://nixos.org/releases/patchelf/${name}/${name}.tar.bz2";
    multihash = "QmaF3c5ELwpV9T9FyDd3iwwmsPeHoRZiQzj2JtV9PfKd8w";
    sha256 = "10sg04wrmx8482clzxkjfx0xbjkyvyzg88vq5yghx2a8l4dmrxm0";
  };

  setupHook = ./setup-hook.sh;

  meta = with stdenv.lib; {
    description = "Utility to modify the dynamic linker & RPATH of ELF executables";
    homepage = http://nixos.org/patchelf.html;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
