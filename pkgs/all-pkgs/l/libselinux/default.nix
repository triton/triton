{ stdenv
, fetchurl
, lib
, python2
, swig

, libsepol
, pcre
}:

let
  release = "20161014";
  version = "2.6";
in
stdenv.mkDerivation rec {
  name = "libselinux-${version}";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/wiki/SELinuxProject/selinux/"
      + "files/releases/${release}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "4ea2dde50665c202253ba5caac7738370ea0337c47b251ba981c60d24e1a118a";
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
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
