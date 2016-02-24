{ stdenv
, fetchurl
, which

, kmod
, zlib
}:

stdenv.mkDerivation rec {
  name = "pciutils-3.4.1"; # with database from 2016-01

  src = fetchurl {
    url = "mirror://kernel/software/utils/pciutils/${name}.tar.xz";
    sha256 = "0am8hiv435h2dayclnkdk8qjlpj08m4djf6sv15n9l84av658mc6";
  };

  nativeBuildInputs = [
    which
  ];

  buildInputs = [
    kmod
    zlib
  ];

  preBuild = ''
    makeFlagsArray+=(
      "SHARED=yes"
      "PREFIX=$out"
    )
  '';

  installTargets = [
    "install"
    "install-lib"
  ];

  # Get rid of update-pciids as it won't work.
  postInstall = ''
    rm $out/sbin/update-pciids $out/man/man8/update-pciids.8
  '';

  meta = with stdenv.lib; {
    homepage = http://mj.ucw.cz/pciutils.html;
    description = "A collection of programs for inspecting and manipulating configuration of PCI devices";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

