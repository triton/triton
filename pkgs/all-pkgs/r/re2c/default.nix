{ stdenv
, fetchurl
}:

let
  version = "1.0.1";
in
stdenv.mkDerivation rec {
  name = "re2c-${version}";

  src = fetchurl {
    urls = [
      "https://github.com/skvadrik/re2c/releases/download/${version}/${name}.tar.gz"
      "mirror://sourceforge/re2c/${version}/${name}.tar.gz"
    ];
    sha256 = "605058d18a00e01bfc32aebf83af35ed5b13180b4e9f279c90843afab2c66c7c";
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
