{ stdenv
, fetchurl
, lib

, libsepol
, pcre2_lib
}:

let
  release = "20191204";
  version = "3.0";
in
stdenv.mkDerivation rec {
  name = "libselinux-${version}";

  src = fetchurl {
    url = "https://github.com/SELinuxProject/selinux/releases/download/"
      + "${release}/${name}.tar.gz";
    sha256 = "2ea2b30f671dae9d6b1391cbe8fb2ce5d36a3ee4fb1cd3c32f0d933c31b82433";
  };

  buildInputs = [
    libsepol
    pcre2_lib
  ];

  postPatch = ''
    sed \
      -e 's,-Werror ,,g' \
      -i utils/Makefile \
      -i src/Makefile
  '';

  preBuild = ''
    makeFlagsArray+=(
      "PREFIX=$out"
      "SHLIBDIR=$out/lib"
    )
  '';

  buildFlags = [
    "USE_PCRE2=y"
    "all"
  ];

  installTargets = [
    "install"
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
