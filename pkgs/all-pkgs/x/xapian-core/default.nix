{ stdenv
, fetchurl

, util-linux_lib
, zlib
}:

let
  version = "1.4.9";
in
stdenv.mkDerivation rec {
  name = "xapian-core-${version}";

  src = fetchurl {
    url = "https://oligarchy.co.uk/xapian/${version}/${name}.tar.xz";
    multihash = "QmWouVd4m14W9ynUM194bU9ijRPfFe91Xm8M27gQKza3Nq";
    sha256 = "cde9c39d014f04c09b59d9c21551db9794c10617dc69ab4c9826352a533df5cc";
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
