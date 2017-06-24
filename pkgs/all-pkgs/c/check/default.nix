{ stdenv
, fetchurl
, lib
}:

let
  version = "0.11.0";
in
stdenv.mkDerivation rec {
  name = "check-${version}";

  src = fetchurl {
    url = "https://github.com/libcheck/check/releases/download/${version}/"
      + "${name}.tar.gz";
    sha256 = "24f7a48aae6b74755bcbe964ce8bc7240f6ced2141f8d9cf480bc3b3de0d5616";
  };

  meta = with lib; {
    description = "Unit testing framework for C";
    homepage = https://libcheck.github.io/check/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
