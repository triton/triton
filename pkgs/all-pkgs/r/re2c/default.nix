{ stdenv
, fetchurl
}:

let
  version = "1.0.2";
in
stdenv.mkDerivation rec {
  name = "re2c-${version}";

  src = fetchurl {
    urls = [
      "https://github.com/skvadrik/re2c/releases/download/${version}/${name}.tar.gz"
      "mirror://sourceforge/re2c/${version}/${name}.tar.gz"
    ];
    sha256 = "b0919585b50095a00e55b99212a81bc67c5fab61d877aca0d9d061aff3093f52";
  };

  meta = with stdenv.lib; {
    description = "Tool for writing very fast and very flexible scanners";
    homepage = "http://re2c.org";
    license = licenses.publicDomain;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = platforms.all;
  };
}
