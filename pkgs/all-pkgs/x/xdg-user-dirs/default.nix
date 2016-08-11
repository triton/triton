{ stdenv
, docbook-xsl
, fetchurl
, libxslt
, makeWrapper
}:

stdenv.mkDerivation rec {
  name = "xdg-user-dirs-0.15";

  src = fetchurl {
    url = "http://user-dirs.freedesktop.org/releases/${name}.tar.gz";
    sha256 = "20b4a751f41d0554bce3e0ce5e8d934be98cc62d48f0b90a894c3e1916552786";
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

  meta = with stdenv.lib; {
    description = "A tool to help manage well known user directories";
    homepage = http://freedesktop.org/wiki/Software/xdg-user-dirs;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
