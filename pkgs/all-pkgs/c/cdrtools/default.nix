{ stdenv
, fetchurl
, gettext
, lib

, acl
, libcap
}:

stdenv.mkDerivation rec {
  name = "cdrtools-3.02a07";

  src = fetchurl {
    url = "mirror://sourceforge/cdrtools/alpha/${name}.tar.bz2";
    sha256 = "49c1a67fa7ad3d7c0b05d41d18cb6677b40d4811faba111f0c01145d3ef0491b";
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
  parallelBuild = false;

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
