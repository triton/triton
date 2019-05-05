{ stdenv
, fetchurl
, gettext
, intltool
, lib
, perl

, glib
, libxml2
}:

let
  id = "80c7f1afbcad2769f38aeb9ba6317a51";
  version = "1.12";
in
stdenv.mkDerivation rec {
  name = "shared-mime-info-${version}";

  src = fetchurl {
    url = "https://gitlab.freedesktop.org/xdg/shared-mime-info/uploads/${id}/${name}.tar.xz";
    multihash = "QmZsZqvXincx9CpbtP8AhagCL78dDYGEkJLJdcXhTDNht2";
    sha256 = "18b2f0fe07ed0d6f81951a5fd5ece44de9c8aeb4dc5bb20d4f595f6cc6bd403e";
  };

  nativeBuildInputs = [
    gettext
    intltool
    perl
  ];

  buildInputs = [
    glib
    libxml2
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--disable-update-mimedb"
  ];

  preFixup = ''
    $out/bin/update-mime-database -V $out/share/mime
  '';

  doCheck = true;
  buildParallel = false;
  installParallel = false;

  meta = with lib; {
    description = "The Shared MIME-info Database specification";
    homepage = https://freedesktop.org/wiki/Software/shared-mime-info;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
