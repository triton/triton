{ stdenv
, autoconf
, fetchurl

, openldap
}:

stdenv.mkDerivation {
  name = "libnfsidmap-0.26";

  src = fetchurl {
    url = "https://fedorapeople.org/~steved/libnfsidmap/0.26/libnfsidmap-0.26.tar.bz2";
    multihash = "QmTMDVFBZ2buVwiZkS3FJeQDB44Joie37X4yVwnaZQWd85";
    sha256 = "391cd35a8aa48bcba1678b483c3e2525d0990eca963bb035962fcf1e3ee2a8bf";
  };

  nativeBuildInputs = [
    autoconf
  ];

  buildInputs = [
    openldap
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
