{ stdenv
, fetchurl
}:

let
  version = "0.16";
in
stdenv.mkDerivation rec {
  name = "re2c-${version}";

  src = fetchurl {
    urls = [
      "mirror://sourceforge.net/re2c/${version}/${name}.tar.gz"
      "https://github.com/skvadrik/re2c/releases/download/${version}/${name}.tar.gz"
    ];
    sha256 = "48c12564297641cceb5ff05aead57f28118db6277f31e2262437feba89069e84";
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
