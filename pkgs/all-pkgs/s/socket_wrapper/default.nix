{ stdenv
, cmake
, fetchurl
, lib
, ninja
}:

stdenv.mkDerivation rec {
  name = "socket_wrapper-1.1.9";

  src = fetchurl {
    url = "mirror://samba/cwrap/${name}.tar.gz";
    sha256 = "2c1d790f578c36b521c0e113fcbcf41d633336b3c60d6c6a1378f920495eebb4";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  meta = with lib; {
    description = "a library passing all socket communications through unix sockets";
    homepage = "https://git.samba.org/?p=socket_wrapper.git;a=summary";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
