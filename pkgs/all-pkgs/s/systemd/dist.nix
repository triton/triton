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
  name = "systemd-dist-v232-9-gc81d700";

  src = fetchFromGitHub {
    version = 2;
    owner = "triton";
    repo = "systemd";
    rev = "c81d700315da4d223bfb1556811b738c7b14a3d6";
    sha256 = "aae114f24cc3af0410caacb4de388f99a725f958e827d55c99e6e440dbac8793";
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
