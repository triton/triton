{ stdenv
, fetchurl

, util-linux_lib
, zlib
}:

let
  version = "1.4.6";
in
stdenv.mkDerivation rec {
  name = "xapian-core-${version}";

  src = fetchurl {
    url = "https://oligarchy.co.uk/xapian/${version}/${name}.tar.xz";
    multihash = "QmeNjfQDDWekoGAwNN8fJi33rbcNR6qKAAsHZ33SCTjBoJ";
    sha256 = "1e0ef1c1d3e2119874d545b7edbb60e6e17d7d18fb802eb890d9ef7bb0bbd898";
  };

  buildInputs = [
    util-linux_lib
    zlib
  ];

  configureFlags = [
    #"--enable-64bit-docid"  breaks notmuch
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms; 
      x86_64-linux;
  };
}
