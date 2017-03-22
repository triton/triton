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
  name = "systemd-dist-v233-9-g265d78708";

  src = fetchFromGitHub {
    version = 2;
    owner = "triton";
    repo = "systemd";
    rev = "265d787083158f2ed8f17f902c2a219bd0c79bcd";
    sha256 = "6c087a06de3865eb82f936158ccf39981df6c2a42b108118fd2900ba82ad9e5f";
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
