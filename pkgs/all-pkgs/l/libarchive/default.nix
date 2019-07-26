{ stdenv
, fetchurl

, acl
, bzip2
, e2fsprogs
, libb2
, libxml2
, lz4
, lzo
, openssl
, xz
, zlib
, zstd
}:

let
  version = "3.4.0";
in
stdenv.mkDerivation rec {
  name = "libarchive-${version}";

  src = fetchurl {
    url = "https://github.com/libarchive/libarchive/releases/download/v${version}/${name}.tar.gz";
    sha256 = "8643d50ed40c759f5412a3af4e353cffbce4fdf3b5cf321cb72cacf06b2d825e";
  };

  buildInputs = [
    acl
    bzip2
    e2fsprogs
    libb2
    libxml2
    lz4
    lzo
    openssl
    xz
    zlib
    zstd
  ];

  configureFlags = [
    "--with-lzo"
  ];

  meta = with stdenv.lib; {
    description = "Multi-format archive and compression library";
    homepage = http://libarchive.org;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
