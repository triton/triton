{ stdenv
, fetchurl

, util-linux_lib
, zlib
}:

let
  version = "1.4.7";
in
stdenv.mkDerivation rec {
  name = "xapian-core-${version}";

  src = fetchurl {
    url = "https://oligarchy.co.uk/xapian/${version}/${name}.tar.xz";
    multihash = "QmXy9Ljnbuj1yqSnNUc4x9Vo9iJdztpiEM2mWK9drMEFvE";
    sha256 = "13f08a0b649c7afa804fa0e85678d693fd6069dd394c9b9e7d41973d74a3b5d3";
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
