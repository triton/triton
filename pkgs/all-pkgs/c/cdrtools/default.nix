{ stdenv
, fetchurl
, gettext

, acl
, libcap
}:

stdenv.mkDerivation rec {
  name = "cdrtools-3.02a06";

  src = fetchurl {
    url = "mirror://sourceforge/cdrtools/${name}.tar.bz2";
    sha256 = "ed79ab99414352ea9305163660b52b6a82394466bae03aebdbe2150997835eb1";
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

  meta = with stdenv.lib; {
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
