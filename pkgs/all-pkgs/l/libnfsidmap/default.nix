{ stdenv
, autoconf
, fetchurl

, openldap
}:

let
  version = "0.27";
in
stdenv.mkDerivation rec {
  name = "libnfsidmap-${version}";

  src = fetchurl {
    url = "https://fedorapeople.org/~steved/libnfsidmap/${version}/${name}.tar.bz2";
    multihash = "Qme1VnaXZZ3bjcEpc8mxFnpPvCZKvfh6GDHhasxkxAa1NY";
    sha256 = "25a285b649e519e7437571f3437b837b7d2d51d6da8d6b5770950812235be22d";
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
