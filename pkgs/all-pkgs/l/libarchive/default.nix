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
  version = "3.4.2";
in
stdenv.mkDerivation rec {
  name = "libarchive-${version}";

  src = fetchurl {
    url = "https://github.com/libarchive/libarchive/releases/download/v${version}/${name}.tar.gz";
    sha256 = "b60d58d12632ecf1e8fad7316dc82c6b9738a35625746b47ecdcaf4aed176176";
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
