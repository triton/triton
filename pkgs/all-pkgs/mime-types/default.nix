{ stdenv
, fetchurl
}:

stdenv.mkDerivation {
  name = "mime-types-2016-01-12";

  src = fetchurl {
    url = "http://anonscm.debian.org/cgit/collab-maint/mime-support.git/plain/mime.types?id=fe8d90a379338a4a9dac4ca791ed7aca52fa0423";
    sha256 = "1z6q4w90id3g8kmfrxxbkgj3sxqqwfka5cnkvn556l0nbc7zr4wi";
  };

  buildCommand = ''
    mkdir -p $out/etc
    cp $src $out/etc/mime.types
  '';

  meta = with stdenv.lib; {
    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
    maintainers = with maintainers; [
      wkennington
    ];
  };
}
