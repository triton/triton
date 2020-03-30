{ stdenv
, fetchurl
, lib
}:

let
  version = "20190731";
in
stdenv.mkDerivation rec {
  name = "libspiro-${version}";

  src = fetchurl {
    url = "https://github.com/fontforge/libspiro/releases/download/"
      + "${version}/libspiro-${version}.tar.gz";
    sha256 = "24c7d1ccc7c7fe44ff10c376aa9f96e20e505f417ee72b63dc91a9b34eeac354";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

