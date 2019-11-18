{ stdenv
, fetchurl

, ncurses
}:

stdenv.mkDerivation rec {
  name = "libedit-20191025-3.1";

  src = fetchurl {
    url = "https://thrysoee.dk/editline/${name}.tar.gz";
    multihash = "QmbG7BSYK6ULpyohCFLbSxRJeNsRytMgcGv5fLHmQTr2PN";
    sha256 = "6dff036660d478bfaa14e407fc5de26d22da1087118c897b1a3ad2e90cb7bf39";
  };

  buildInputs = [
    ncurses
  ];

  configureFlags = [
    "--disable-examples"
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

  meta = with stdenv.lib; {
    homepage = "https://thrysoee.dk/editline/";
    description = "A port of the NetBSD Editline library (libedit)";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
