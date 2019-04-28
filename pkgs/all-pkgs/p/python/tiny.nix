{ stdenv
, fetchurl
, lib
}:

let
  version = "3.7.3";
in
stdenv.mkDerivation {
  name = "python-tiny-${version}";

  src = fetchurl {
    url = "https://www.python.org/ftp/python/${version}/Python-${version}.tar.xz";
    hashOutput = false;
    sha256 = "da60b54064d4cfcd9c26576f6df2690e62085123826cff2e667e72a91952d318";
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
