{ stdenv
, buildSetupHook
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "patchelf-0.9";

  src = fetchurl {
    url = "http://nixos.org/releases/patchelf/${name}/${name}.tar.bz2";
    sha256 = "10sg04wrmx8482clzxkjfx0xbjkyvyzg88vq5yghx2a8l4dmrxm0";
  };

  setupHook = buildSetupHook {
    name = "patchelf";
    src = ./setup-hook;
  };

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
