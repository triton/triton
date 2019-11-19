{ stdenv
, autoreconfHook
, cc
, fetchFromGitHub
, fetchurl

, type ? "full"
}:

let
  inherit (stdenv.lib)
    optionalString;
in
stdenv.mkDerivation rec {
  name = "patchelf-0.9";

  src = fetchurl {
    url = "https://nixos.org/releases/patchelf/${name}/${name}.tar.bz2";
    multihash = "QmaF3c5ELwpV9T9FyDd3iwwmsPeHoRZiQzj2JtV9PfKd8w";
    sha256 = "10sg04wrmx8482clzxkjfx0xbjkyvyzg88vq5yghx2a8l4dmrxm0";
  };

  nativeBuildInputs = [
    cc
  ];

  setupHook = ./setup-hook.sh;

  outputs = [
    "bin"
  ];

  passthru = {
    dist = stdenv.mkDerivation rec {
      name = "patchelf-2017-06-15";

      src = fetchFromGitHub {
        version = 3;
        owner = "nixos";
        repo = "patchelf";
        rev = "29c085fd9d3fc972f75b3961905d6b4ecce7eb2b";
        sha256 = "be6f1c5a71638b15dec3d218541265230d055a00e597d21a7a98f7b698dbecfd";
      };

      nativeBuildInputs = [
        autoreconfHook
      ];

      preBuild = ''
        echo '#!/bin/sh' >tar
        echo 'arg1="$1"; arg2="$2"; shift 2' >>tar
        echo 'set -x' >>tar
        echo 'exec tar "$arg1" "$arg2" --sort=name --owner=0 --group=0 --numeric-owner --no-acls --no-selinux --no-xattrs --mode=go=rX,u+rw,a-s --clamp-mtime --mtime=@$SOURCE_DATE_EPOCH "$@"' >>tar
        chmod +x tar
      '';

      buildFlags = [
        "dist-xz"
        "XZ_OPT=-ve9"
        "TAR=./tar"
      ];

      installPhase = ''
        mkdir -p "$out"
        mv patchelf*.tar* "$out"
      '';
    };
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
      ++ powerpc64le-linux
      ++ x86_64-linux;
  };
}
