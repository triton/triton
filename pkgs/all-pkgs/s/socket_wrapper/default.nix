{ stdenv
, cmake
, fetchurl
, ninja
}:

stdenv.mkDerivation rec {
  name = "socket_wrapper-1.1.6";

  src = fetchurl {
    url = "mirror://samba/cwrap/${name}.tar.gz";
    sha256 = "b97265e98e4da58cd0b438c1f17cdfb65b5c4e4a8fe2aab9360042a812931220";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  meta = with stdenv.lib; {
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
