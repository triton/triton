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
  name = "systemd-dist-v231-11-g76c65dc";

  src = fetchFromGitHub {
    version = 2;
    owner = "triton";
    repo = "systemd";
    rev = "76c65dc2825d0a6ce433270b60a7eedf888ea926";
    sha256 = "f0fd25e1533261166dc51986ba04f4a14ded169055435136341b2ebe5c1d4012";
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
