{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "cabextract-1.6";

  src = fetchurl {
    url = "https://www.cabextract.org.uk/${name}.tar.gz";
    multihash = "QmQ474EmBoH88W1keK4j3AqtBz6YHZfwqBJ7ZVaKY73sBh";
    sha256 = "cee661b56555350d26943c5e127fc75dd290b7f75689d5ebc1f04957c4af55fb";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
