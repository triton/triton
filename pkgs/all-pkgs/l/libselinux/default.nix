{ stdenv
, fetchurl
, lib
, python2
, swig

, libsepol
, pcre
}:

let
  release = "20160223";
  version = "2.5";
in
stdenv.mkDerivation rec {
  name = "libselinux-${version}";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/wiki/SELinuxProject/selinux/"
      + "files/releases/${release}/${name}.tar.gz";
    sha256 = "94c9e97706280bedcc288f784f67f2b9d3d6136c192b2c9f812115edba58514f";
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
    sed -i src/Makefile \
      -e 's|$(LIBDIR)/libsepol.a|${libsepol}/lib/libsepol.a|'
  '';

  preBuild = ''
    # Build fails without this precreated
    mkdir -pv $out/include

    makeFlagsArray+=(
      "PREFIX=$out"
      "DESTDIR=$out"
    )
  '';

  installTargets = [
    "install"
    "install-pywrap"
  ];

  meta = with lib; {
    description = "SELinux userland library";
    homepage = http://userspace.selinuxproject.org;
    license = licenses.gpl2;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
