{ stdenv
, fetchurl
, lib

, libsepol
, pcre2_lib
}:

let
  release = "20190315";
  version = "2.9";
in
stdenv.mkDerivation rec {
  name = "libselinux-${version}";

  src = fetchurl {
    url = "https://github.com/SELinuxProject/selinux/releases/download/"
      + "${release}/${name}.tar.gz";
    sha256 = "1bccc8873e449587d9a2b2cf253de9b89a8291b9fbc7c59393ca9e5f5f4d2693";
  };

  buildInputs = [
    libsepol
    pcre2_lib
  ];

  CC_WRAPPER_CFLAGS = [
    "-Wno-error"
  ];

  preBuild = ''
    makeFlagsArray+=(
      "PREFIX=$dev"
      "SHLIBDIR=$dev/lib"
    )
  '';

  buildFlags = [
    "USE_PCRE2=y"
    "all"
  ];

  installTargets = [
    "install"
  ];

  postInstall = ''
    mkdir -p "$bin"
    mv "$dev"/sbin "$bin"

    mkdir -p "$lib"/lib
    mv -v "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  postFixup = ''
    rm -rv "$dev"/share
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
    "man"
  ];

  meta = with lib; {
    description = "SELinux userland library";
    homepage = http://userspace.selinuxproject.org;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
