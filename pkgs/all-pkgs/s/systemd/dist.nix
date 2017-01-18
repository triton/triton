{ stdenv
, autoconf
, automake
, fetchFromGitHub
, gnum4
, gperf
, intltool
, libtool
, libxslt

, libcap
, libgcrypt
, libgpg-error
, util-linux_lib
}:

stdenv.mkDerivation {
  name = "systemd-dist-v232-10-g04c9a10e4";

  src = fetchFromGitHub {
    version = 2;
    owner = "triton";
    repo = "systemd";
    rev = "04c9a10e492dcb2b87a61d2096f2009cb090d8a6";
    sha256 = "08c357b61499ebea3d7191a8cf45aa569135c5cf2b7eda2720ed79716c028469";
  };

  nativeBuildInputs = [
    autoconf
    automake
    gnum4
    gperf
    intltool
    libtool
  ];

  # All of these inputs are needed for the DISTFILES to generate correctly
  buildInputs = [
    libcap
    libgcrypt
    libgpg-error
    util-linux_lib
  ];

  preConfigure = ''
    ./autogen.sh

    # We don't actually want to depend on libraries just to have distfiles added correctly
    cp configure configure.old
    sed \
      -e 's,\(.*_\(TRUE\|FALSE\)=\).*,\1,g' \
      -e 's,test -z "''${[A-Za-z0-9_]*_\(TRUE\|FALSE\).*;,false;,g' \
      -i configure
  '';

  postConfigure = ''
    mv configure.old configure
  '';

  configureFlags = [
    "--disable-manpages"
  ];

  buildFlags = [
    "dist"
  ];

  installPhase = ''
    mkdir -p "$out"
    mv systemd-*.tar* "$out"
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
  };
}
