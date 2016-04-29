{ stdenv
, fetchurl

, libevent
}:

let
  version = "0.2.0";
in
stdenv.mkDerivation rec {
  name = "fstrm-${version}";

  src = fetchurl {
    url = "https://github.com/farsightsec/fstrm/releases/download/v${version}/${name}.tar.gz";
    sha256 = "ad5d39957a4b334a6c7fcc94f308dc7ac75e1997cc642e9bb91a18fc0f42a98a";
  };

  buildInputs = [
    libevent
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
