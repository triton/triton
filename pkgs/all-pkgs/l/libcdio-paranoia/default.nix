{ stdenv
, fetchurl
, gettext
, lib

, libcdio
}:

let
  version = "10.2+2.0.0";
in
stdenv.mkDerivation rec {
  name = "libcdio-paranoia-${version}";

  src = fetchurl {
    url = "mirror://gnu/libcdio/libcdio-paranoia-${version}.tar.bz2";
    sha256 = "4565c18caf401083c53733e6d2847b6671ba824cff1c7792b9039693d34713c1";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    libcdio
  ];

  configureFlags = [
    "--disable-example-progs"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        pgpsigUrls = map (u: "${u}.sig") src.urls;
        pgpKeyFingerprints = [
          # Rocky Bernstein
          "DAA6 3BC2 5820 34A0 2B92  3D52 1A8D E500 8275 EC21"
        ];
      };
    };
  };

  meta = with lib; {
    description = "CD paranoia on top of libcdio";
    homepage = https://github.com/rocky/libcdio-paranoia;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

