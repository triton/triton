{ stdenv
, fetchurl

, nspr
, nss
}:

let
  version = "4.0.4";
in
stdenv.mkDerivation rec {
  name = "svrcore-${version}";

  src = fetchurl {
    url = "https://ftp.mozilla.org/pub/directory/svrcore/releases/${version}/src/${name}.tar.bz2";
    multihash = "QmfYLr5PtB3xbTZKQUAKoYSTy8v8iCopgf99rf92VbiDmA";
    sha256 = "4772fb4705492de11f10d3e020f0ceca2541415c009ae5444988d6becca36a58";
  };

  buildInputs = [
    nspr
    nss
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
