{ stdenv
, fetchurl
, python
, swig

, libsepol
, pcre
}:

let
  inherit (libsepol)
    se_release
    se_url;

  version = "2.5";
in
stdenv.mkDerivation rec {
  name = "libselinux-${version}";

  src = fetchurl {
    url = "${se_url}/${se_release}/libselinux-${version}.tar.gz";
    sha256 = "94c9e97706280bedcc288f784f67f2b9d3d6136c192b2c9f812115edba58514f";
  };

  nativeBuildInputs = [
    python
    swig
  ];

  buildInputs = [
    libsepol
    pcre
  ];

  NIX_CFLAGS_COMPILE = "-fstack-protector-all -std=gnu89";

  postPatch = ''
    sed -i -e 's|\$(LIBDIR)/libsepol.a|${libsepol}/lib/libsepol.a|' src/Makefile
  '';

  preBuild = ''
    # Build fails without this precreated
    mkdir -p $out/include

    makeFlagsArray+=(
      "PREFIX=$out"
      "DESTDIR=$out"
    )
  '';

  installTargets = [
    "install"
    "install-pywrap"
  ];

  meta = libsepol.meta // {
    description = "SELinux core library";
  };
}
