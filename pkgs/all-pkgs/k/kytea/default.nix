{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "kytea-0.4.7";
  
  src = fetchurl {
    url = "http://www.phontron.com/kytea/download/${name}.tar.gz";
    multihash = "Qme88yCXrCeimKQmBFZXaourVyhTVL9Tv47uDYf7Cgvhvy";
    sha256 = "534a33d40c4dc5421f053c71a75695c377df737169f965573175df5d2cff9f46";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
