{ stdenv
, lib
, fetchurl
}:

let
  version = "0.98.1";
in
stdenv.mkDerivation {
  name = "libb2-${version}";

  src = fetchurl {
    url = "https://github.com/BLAKE2/libb2/releases/download/v${version}/libb2-${version}.tar.gz";
    sha256 = "53626fddce753c454a3fea581cbbc7fe9bbcf0bc70416d48fdbbf5d87ef6c72e";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
