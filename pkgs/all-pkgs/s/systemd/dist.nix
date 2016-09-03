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
  name = "systemd-dist-v231-10-gb6932fc";

  src = fetchFromGitHub {
    version = 1;
    owner = "triton";
    repo = "systemd";
    rev = "ca0a4ad1275b9a0aa104db025804bddbf334daf2";
    sha256 = "41ccd0dc1dee53d4c979fa08ad4a76f223011ab3baeeb4761d94db62287eb78d";
  };

  nativeBuildInputs = [
    autoconf
    automake
    gnum4
    gperf
    intltool
    libtool
  ];

  buildInputs = [
    libcap
    libgcrypt
    libgpg-error
    util-linux_lib
  ];

  preConfigure = ''
    ./autogen.sh
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
