{ stdenv
, fetchurl
}:

let
  version = "1.2.8";
in
stdenv.mkDerivation rec {
  name = "exfat-utils-${version}";

  src = fetchurl {
    url = "https://github.com/relan/exfat/releases/download/v${version}/${name}.tar.gz";
    sha256 = "5c1643d23d24663b4e483292a643a791d2af7269870cac2f781c5dfe6a20ce27";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
