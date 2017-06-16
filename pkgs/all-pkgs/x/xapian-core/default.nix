{ stdenv
, fetchurl

, util-linux_lib
, zlib
}:

let
  version = "1.4.4";
in
stdenv.mkDerivation rec {
  name = "xapian-core-${version}";

  src = fetchurl {
    url = "https://oligarchy.co.uk/xapian/${version}/${name}.tar.xz";
    multihash = "QmQjRk7UXkkbLCg57fWcVads7imyiE5EqYWz5fMkupTmvb";
    sha256 = "a6a985a9841a452d75cf2169196b7ca6ebeef27da7c607078cd401ad041732d9";
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
