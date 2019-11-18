{ stdenv
, fetchurl
, lib

, ncurses
}:

let
  version = "1.16.1";
in
stdenv.mkDerivation rec {
  name = "editline-${version}";

  src = fetchurl {
    url = "https://github.com/troglobit/editline/releases/download/${version}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "6518cc0d8241bcebc860432d1babc662a9ce0f5d6035649effe38b5bc9463f8c";
  };

  buildInputs = [
    ncurses
  ];

  configureFlags = [
    "--enable-termcap"
  ];

  postInstall = ''
    mkdir -p "$lib"/lib
    mv "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  postFixup = ''
    rm -rv "$dev"/share
  '';

  outputs = [
    "dev"
    "lib"
    "man"
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
