{ stdenv
, fetchurl

, util-linux_lib
, zlib
}:

let
  version = "1.4.10";
in
stdenv.mkDerivation rec {
  name = "xapian-core-${version}";

  src = fetchurl {
    url = "https://oligarchy.co.uk/xapian/${version}/${name}.tar.xz";
    multihash = "QmaVhmdcwDRtKcG5zjpFtr9kvN5KZvZjWjZNkkkh9HrYj2";
    sha256 = "68669327e08544ac88fe3473745dbcae4e8e98d5060b436c4d566f1f78709bb8";
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
