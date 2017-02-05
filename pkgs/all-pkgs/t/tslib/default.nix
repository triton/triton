{ stdenv
, autoreconfHook
, fetchurl
}:

let
  version = "1.4";
in
stdenv.mkDerivation rec {
  name = "tslib-${version}";

  src = fetchurl {
    url = "https://github.com/kergoth/tslib/releases/download/${version}/"
      + "${name}.tar.xz";
    sha256 = "ad0373f1dbfda27caec92cb10421227f226c79d160488f1ac915585ba947741f";
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
