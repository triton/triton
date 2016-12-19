{ stdenv
, cmake
, docbook_xml_dtd_45
, docbook-xsl
, fetchurl
, gettext
, libxslt
, ninja
, po4a

, bzip2
, curl
, db
, dpkg
, googletest
, lz4
, xz
, zlib
}:

let
  version = "1.3.1";
in
stdenv.mkDerivation {
  name = "apt-${version}";

  src = fetchurl {
    url = "mirror://debian/pool/main/a/apt/apt_${version}.tar.xz";
    sha256 = "7ae8ebc1e371d10c4bfe1b0009cbdb6d22944963a616ae6407c74d122234fa58";
  };

  nativeBuildInputs = [
    cmake
    docbook_xml_dtd_45
    docbook-xsl
    gettext
    libxslt
    ninja
    po4a
  ];

  buildInputs = [
    bzip2
    curl
    db
    dpkg
    googletest
    lz4
    xz
    zlib
  ];

  preConfigure = ''
    cmakeFlagsArray+=(
      "-DCMAKE_INSTALL_LOCALSTATEDIR=$TMPDIR/var"
    )
  '';

  cmakeFlags = [
    "-DROOT_GROUP=wheel"
    "-DWITH_DOC=OFF"
    "-DDOCBOOK_XSL=${docbook-xsl}/share/xml/docbook-xsl"
    "-DBERKELEY_DB_INCLUDE_DIRS=${db}/include"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
