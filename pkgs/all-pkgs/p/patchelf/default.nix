{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "patchelf-0.9";

  src = fetchurl {
    url = "http://nixos.org/releases/patchelf/${name}/${name}.tar.bz2";
    sha256 = "10sg04wrmx8482clzxkjfx0xbjkyvyzg88vq5yghx2a8l4dmrxm0";
  };

  setupHook = ./setup-hook.sh;

  meta = with stdenv.lib; {
    homepage = http://nixos.org/patchelf.html;
    license = licenses.gpl3;
    description = "A small utility to modify the dynamic linker and RPATH of ELF executables";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
