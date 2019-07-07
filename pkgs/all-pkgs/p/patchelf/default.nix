{ stdenv
, autoreconfHook
, fetchFromGitHub
, fetchurl

, type ? "full"
}:

let
  inherit (stdenv.lib)
    optionalString;
in
stdenv.mkDerivation rec {
  name = "patchelf-0.10";

  src = fetchurl {
    url = "https://nixos.org/releases/patchelf/${name}/${name}.tar.bz2";
    multihash = "QmWVR5rMR4Gos2CLm4EHmEBwsiphh2x7oHwjviMbhLdbDG";
    sha256 = "f670cd462ac7161588c28f45349bc20fb9bd842805e3f71387a320e7a9ddfcf3";
  };

  setupHook = ./setup-hook.sh;

  postInstall = optionalString (type != "full") ''
    rm -r "$out"/share
  '';

  allowedReferences = [
    "out"
  ] ++ stdenv.cc.runtimeLibcxxLibs;

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
      ++ x86_64-linux;
  };
}
