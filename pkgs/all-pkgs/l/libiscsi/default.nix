{ stdenv
, autoconf
, automake
, fetchFromGitHub
, libtool

, libgcrypt
, rdma-core
}:

let
  version = "1.18.0";
in
stdenv.mkDerivation rec {
  name = "libiscsi-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "sahlberg";
    repo = "libiscsi";
    rev = version;
    sha256 = "d68ede939cb16c5bd183a18f0f7c4210cdc625e1f3f79ea91ed8fb83b78a3301";
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

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
