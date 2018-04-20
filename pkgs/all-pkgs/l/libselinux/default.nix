{ stdenv
, fetchurl
, lib
, python2
, swig

, libsepol
, pcre
}:

let
  release = "20180419";
  version = "2.8-rc1";
in
stdenv.mkDerivation rec {
  name = "libselinux-${version}";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/wiki/SELinuxProject/selinux/"
      + "files/releases/${release}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "2229b6ef6cee73d335fb3d9f763e167fe182e70cd045e18f975bd2f9d0d9d6dd";
  };

  nativeBuildInputs = [
    python2
    swig
  ];

  buildInputs = [
    libsepol
    pcre
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
    "all"
    "pywrap"
  ];

  installTargets = [
    "install"
    "install-pywrap"
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
