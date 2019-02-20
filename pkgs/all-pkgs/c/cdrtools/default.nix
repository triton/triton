{ stdenv
, fetchurl
, gettext
, lib

, acl
, libcap
}:

stdenv.mkDerivation rec {
  name = "cdrtools-3.02a09";

  src = fetchurl {
    url = "mirror://sourceforge/cdrtools/alpha/${name}.tar.bz2";
    sha256 = "aa28438f458ef3f314b79f2029db27679dae1d5ffe1569b6de57742511915e81";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    acl
    libcap
  ];

  postPatch = /* Fix hardcoded paths */ ''
    sed -i RULES/rules.prg \
      -e 's,/bin/ln -s,ln -s,' \
      -e 's,/bin/ln,ln,' \
      -e 's,/bin/rm,rm,' \
      -e 's,/bin/mv,mv,'
  '';

  configurePhase = "true";

  preBuild = ''
    makeFlagsArray+=(
      "INS_BASE=/"
      "DESTDIR=$out"
    )
  '';

  # cdda2wav fails if > -j1, it tries to link/copy files out of order.
  buildParallel = false;

  meta = with lib; {
    description = "Portable CD/DVD/BluRay command line recording software";
    homepage = http://sourceforge.net/projects/cdrtools/;
    license = with licenses; [
      cddl # cddl-Schily
      gpl2
      lgpl21
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
