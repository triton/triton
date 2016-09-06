{ stdenv
, fetchurl
}:

let
  version = "0.8.8.5";
in
stdenv.mkDerivation rec {
  name = "libmodplug-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/modplug-xmms/libmodplug/${version}/${name}.tar.gz";
    multihash = "QmSfTtNJjzvM29zfgGGWS7DhXL57n6A3u9Fjp1xdUjgD6R";
    sha256 = "1bfsladg7h6vnii47dd66f5vh1ir7qv12mfb8n36qiwrxq92sikp";
  };

  meta = with stdenv.lib; {
    description = "MOD playing library";
    homepage = "http://modplug-xmms.sourceforge.net/";
    license = licenses.publicDomain;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
