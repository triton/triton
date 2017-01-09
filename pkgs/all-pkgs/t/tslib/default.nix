{ stdenv
, autoreconfHook
, fetchurl
}:

let
  version = "1.3";
in
stdenv.mkDerivation rec {
  name = "tslib-${version}";

  src = fetchurl {
    url = "https://github.com/kergoth/tslib/releases/download/${version}/"
      + "${name}.tar.xz";
    sha256 = "e935101adca980a14d1a13362796222575f99e6a41db585e8358fffddb98d92c";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  meta = with stdenv.lib; {
    description = "Touchscreen access library";
    homepage = https://github.com/kergoth/tslib/;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
