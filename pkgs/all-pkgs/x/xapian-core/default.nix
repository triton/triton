{ stdenv
, fetchurl

, util-linux_lib
, zlib
}:

let
  version = "1.4.2";
in
stdenv.mkDerivation rec {
  name = "xapian-core-${version}";

  src = fetchurl {
    url = "https://oligarchy.co.uk/xapian/${version}/${name}.tar.xz";
    multihash = "QmVB7zQeDJn5d4F6xb3kvj4d4PFeYNaCKPrTHSUnDfag6V";
    sha256 = "aec2c4352998127a2f2316218bf70f48cef0a466a87af3939f5f547c5246e1ce";
  };

  buildInputs = [
    util-linux_lib
    zlib
  ];

  configureFlags = [
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
