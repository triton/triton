{ stdenv
, cmake
, docbook_xml_dtd_45
, docbook-xsl
, fetchurl
, gettext
, lib
, libxslt
, ninja
, perl
, po4a

, bzip2
, curl
, db
, dpkg
, gnutls
, lz4
, systemd_lib
, xz
, zlib
}:

let
  version = "1.5";
in
stdenv.mkDerivation {
  name = "apt-${version}";

  src = fetchurl {
    url = "mirror://debian/pool/main/a/apt/apt_${version}.tar.xz";
    sha256 = "7d9a4daf7a4ae87de7ff4b1423e951ce66fe0535944f0774c8890d8f2a23e920";
  };

  nativeBuildInputs = [
    cmake
    docbook_xml_dtd_45
    docbook-xsl
    gettext
    libxslt
    ninja
    perl
    po4a
  ];

  buildInputs = [
    bzip2
    curl
    db
    dpkg
    gnutls
    lz4
    systemd_lib
    xz
    zlib
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_SYSCONFDIR=/etc"
    "-DCMAKE_INSTALL_LOCALSTATEDIR=/var"
    "-DROOT_GROUP=wheel"
    "-DWITH_DOC=OFF"
    "-DDOCBOOK_XSL=${docbook-xsl}/share/xml/docbook-xsl"
    "-DBERKELEY_DB_INCLUDE_DIRS=${db}/include"
  ];

  preInstall = ''
    sed \
      -e "s,{DESTDIR}/etc,$out/etc,g" \
      -e "s,{DESTDIR}/var,$TMPDIR/var,g" \
      -i cmake_install.cmake
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
