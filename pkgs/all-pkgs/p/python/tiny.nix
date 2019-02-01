{ stdenv
, fetchurl
, lib
}:

let
  version = "3.7.2";
in
stdenv.mkDerivation {
  name = "python-tiny-${version}";

  src = fetchurl {
    url = "https://www.python.org/ftp/python/${version}/Python-${version}.tar.xz";
    hashOutput = false;
    sha256 = "d83fe8ce51b1bb48bbcf0550fd265b9a75cdfdfa93f916f9e700aef8444bf1bb";
  };

  configureFlags = [
    "--enable-shared"
    "--with-assertions"
    "--without-ensurepip"
  ];

  postInstall = ''
    rm -r "$out"/lib/python*/test
    rm -r "$out"/lib/python*/config-*
    rm -r "$out"/share
    find "$out"/lib -name __pycache__ -prune -exec rm -r {} \;
    find "$out"/lib -name '*'.exe -delete
    rm -r "$out"/lib/python*/{idlelib,ensurepip}
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
