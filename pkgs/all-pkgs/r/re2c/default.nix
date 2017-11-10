{ stdenv
, fetchurl
}:

let
  version = "1.0.3";
in
stdenv.mkDerivation rec {
  name = "re2c-${version}";

  src = fetchurl {
    url = "https://github.com/skvadrik/re2c/releases/download/${version}/${name}.tar.gz";
    sha256 = "cf56e0de3f335f6a22d3e8c06b8b450d858a4e7875ea1b01c9233e084b90cb52";
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
