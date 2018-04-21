{ stdenv
, fetchurl
, lib
}:

let
  version = "1.5.2";
in
stdenv.mkDerivation {
  name = "opensp-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/openjade/opensp/${version}/OpenSP-${version}.tar.gz";
    sha256 = "1khpasr6l0a8nfz6kcf3s81vgdab8fm2dj291n5r2s53k228kx2p";
  };

  configureFlags = [
    "--enable-http"
    "--enable-xml-messages"
    "--disable-doc-build"
  ];

  setupHook = ./setup-hook.sh;

  meta = with lib; {
    description = "A suite of SGML/XML processing tools";
    license = licenses.mit;
    homepage = http://openjade.sourceforge.net/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
