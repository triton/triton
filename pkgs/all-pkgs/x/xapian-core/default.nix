{ stdenv
, fetchurl

, util-linux_lib
, zlib
}:

let
  version = "1.4.5";
in
stdenv.mkDerivation rec {
  name = "xapian-core-${version}";

  src = fetchurl {
    url = "https://oligarchy.co.uk/xapian/${version}/${name}.tar.xz";
    multihash = "QmNsVt49CYc1VL9usMVFtpa4sooBzfsUzJyFgyybodqTqN";
    sha256 = "85b5f952de9df925fd13e00f6e82484162fd506d38745613a50b0a2064c6b02b";
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
