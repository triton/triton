{ stdenv
, fetchurl
, lib

, ncurses
}:

let
  version = "1.16.0";
in
stdenv.mkDerivation rec {
  name = "editline-${version}";

  src = fetchurl {
    url = "https://github.com/troglobit/editline/releases/download/${version}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "38a3635f6850774d70f14d293b8755eaef85760755b600875aab59e9a3a98f3d";
  };

  buildInputs = [
    ncurses
  ];

  configureFlags = [
    "--enable-termcap"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        md5Url = map (x: "${x}.md5") src.urls;
      };
    };
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
