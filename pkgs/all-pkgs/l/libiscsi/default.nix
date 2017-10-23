{ stdenv
, autoconf
, automake
, fetchFromGitHub
, libtool

, libgcrypt
, rdma-core
}:

let
  date = "2017-06-14";
  rev = "f9d54c5e457104fed8886841f0617ee5efc4fb46";
in
stdenv.mkDerivation rec {
  name = "libiscsi-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "sahlberg";
    repo = "libiscsi";
    inherit rev;
    sha256 = "72bf9647998c5d96929510ee7e704b4ba46350006fbe335bc0363000f5dabbb0";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
  ];

  buildInputs = [
    libgcrypt
    rdma-core
  ];

  preConfigure = ''
    ./autogen.sh
  '';

  configureFlags = [
    "--disable-werror"
    "--enable-manpages"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
