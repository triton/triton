{ stdenv
, fetchurl
, lib

, expat
}:

let
  version = "0.1.3";
in
stdenv.mkDerivation rec {
  name = "libmetalink-${version}";

  src = fetchurl {
    url = "https://github.com/metalink-dev/libmetalink/releases/download/release-${version}/${name}.tar.xz";
    sha256 = "86312620c5b64c694b91f9cc355eabbd358fa92195b3e99517504076bf9fe33a";
  };

  buildInputs = [
    expat
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
