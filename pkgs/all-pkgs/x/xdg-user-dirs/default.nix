{ stdenv
, docbook-xsl
, fetchurl
, lib
, libxslt
, makeWrapper
}:

stdenv.mkDerivation rec {
  name = "xdg-user-dirs-0.17";

  src = fetchurl {
    url = "https://user-dirs.freedesktop.org/releases/${name}.tar.gz";
    multihash = "QmT2dLoRbs3NSta4D2Ttv5MuHujjAaD3qmySzbtbLNtrUT";
    sha256 = "2a07052823788e8614925c5a19ef5b968d8db734fdee656699ea4f97d132418c";
  };

  nativeBuildInputs = [
    docbook-xsl
    libxslt
    makeWrapper
  ];

  preFixup = ''
    wrapProgram $out/bin/xdg-user-dirs-update \
      --prefix XDG_CONFIG_DIRS : "$out/etc/xdg"
  '';

  meta = with lib; {
    description = "A tool to help manage well known user directories";
    homepage = http://freedesktop.org/wiki/Software/xdg-user-dirs;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
