{ stdenv
, fetchurl
}:

let
  version = "3.2.1";
in
stdenv.mkDerivation rec {
  name = "libconfuse-${version}";

  src = fetchurl {
    url = "https://github.com/martinh/libconfuse/releases/download/v${version}/confuse-${version}.tar.xz";
    sha256 = "23c63272baf2ef4e2cbbafad2cf57de7eb81f006ec347c00b954819824add25e";
  };
  
  configureFlags = [
    "--sysconfdir=/etc"
    "--disable-examples"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
