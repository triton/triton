{ stdenv
, fetchurl
}:

let
  major = "0.1";
  patch = "18";
  version = "${major}.${patch}";
in
stdenv.mkDerivation rec {
  name = "babl-${version}";

  src = fetchurl {
    url = [
      "https://download.gimp.org/pub/babl/${major}/${name}.tar.bz2"
      "http://ftp.gtk.org/pub/babl/${major}/${name}.tar.bz2"
    ];
    multihash = "QmeBXFgyvtQormCBCX42mphESCSpgiQHxyXqxgJ8AxeXgK";
    sha256 = "1ygvnq22pf0zvf3bj7h67vvbpz7b8hhjvrr79ribws7sr5dljfj8";
  };

  meta = with stdenv.lib; { 
    description = "Image pixel format conversion library";
    homepage = http://gegl.org/babl/;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
