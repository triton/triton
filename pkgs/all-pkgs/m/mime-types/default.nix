{ stdenv
, fetchurl
}:

stdenv.mkDerivation {
  name = "mime-types-2016-01-12";

  src = fetchurl {
    url = "https://anonscm.debian.org/cgit/collab-maint/mime-support.git/plain/"
        + "mime.types?id=fe8d90a379338a4a9dac4ca791ed7aca52fa0423";
    multihash = "QmUZHmEDh8p21ZntKM3PaQNsZszW1XqrsWfYUwyqeDmQWw";
    sha256 = "1z6q4w90id3g8kmfrxxbkgj3sxqqwfka5cnkvn556l0nbc7zr4wi";
  };

  buildCommand = ''
    mkdir -pv $out/etc
    cp -v $src $out/etc/mime.types
  '';

  meta = with stdenv.lib; {
    description = "Provides /etc/mime.types file";
    homepage = http://anonscm.debian.org/cgit/collab-maint/mime-support.git;
    license = licenses.free;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
