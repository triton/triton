{ stdenv
, fetchurl
}:

let
  version = "3.2.2";
in
stdenv.mkDerivation rec {
  name = "libconfuse-${version}";

  src = fetchurl {
    url = "https://github.com/martinh/libconfuse/releases/download/v${version}/confuse-${version}.tar.xz";
    sha256 = "a9240b653d02e8cfc52db48e8c4224426e528e1faa09b65e8ca08a197fad210b";
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
