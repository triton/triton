{ stdenv
, bison
, fetchurl
, flex
, gettext
, libxslt

# Optional Dependencies
, kerberos
, pam
, openldap
, openssl
, readline
, libossp-uuid
, libxml2
, zlib

# Extra Arguments
, blockSizeKB ? 8, segmentSizeGB ? 1
, walBlockSizeKB ? 8, walSegmentSizeMB ? 16
, channel ? "9.5"
}:

let
  sources = {
    "9.1" = {
      version = "9.1.21";
      sha256 = "d66ee9076f3149a4cab4be3c6f47e13bc047138d17dfcb531ad01f78cfdeb393";
    };

    "9.2" = {
      version = "9.2.16";
      sha256 = "d2164cb8706bf828161871c195299841c5be1fbd9bc85d7866704e54f0741b11";
    };

    "9.3" = {
      version = "9.3.12";
      sha256 = "f3339ea23f86d07f3730adc878b2e5d433087ff44aad65a5ec9c22c32b112e67";
    };

    "9.4" = {
      version = "9.4.7";
      sha256 = "cc795e6c35b30e697e5891e3056376af685f848a4e67fab1702e74a2385f81e0";
    };

    "9.5" = {
      version = "9.5.2";
      sha256 = "f8d132e464506b551ef498719f18cfe9d777709c7a1589dc360afc0b20e47c41";
    };
  };

  source = sources."${channel}";

  inherit (stdenv.lib)
    optionals
    versionAtLeast
    versionOlder;
in
stdenv.mkDerivation rec {
  name = "postgresql-${source.version}";

  src = fetchurl rec {
    url = "mirror://postgresql/source/v${source.version}/${name}.tar.bz2";
    sha256Url = "${url}.sha256";
    inherit (source) sha256;
  };

  patches = [
    ./less-is-more.patch
  ] ++ optionals (versionOlder source.version "9.4.0") [
    ./disable-resolve_symlinks.patch
  ] ++ optionals (versionAtLeast source.version "9.4.0") [
    ./disable-resolve_symlinks-94.patch
  ];

  nativeBuildInputs = [
    bison
    flex
    gettext
    libxslt
  ];

  buildInputs = [
    kerberos
    libossp-uuid
    libxml2
    openldap
    openssl
    pam
    readline
    zlib
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-integer-datetimes"
    "--enable-nls"
    "--with-pgport=5432"
    "--enable-rpath"
    "--enable-spinlocks"
    "--disable-debug"
    "--disable-profiling"
    "--disable-coverage"
    "--disable-dtrace"
    "--with-blocksize=${toString blockSizeKB}"
    "--with-segsize=${toString segmentSizeGB}"
    "--with-wal-blocksize=${toString walBlockSizeKB}"
    "--with-wal-segsize=${toString walSegmentSizeMB}"
    "--enable-depend"
    "--disable-cassert"
    "--enable-thread-safety"
    "--without-tcl"  # Maybe enable some day
    "--without-perl"  # Maybe enable some day
    "--without-python"  # Maybe enable some day
    "--with-gssapi"
    "--with-pam"
    "--with-ldap"
    "--without-bonjour"
    "--with-openssl"
    "--with-readline"
    "--without-libedit-preferred"
    "--with-libxml"
    "--with-libxslt"
    "--with-zlib"
  ] ++ optionals (versionAtLeast source.version "9.1.0") [
    "--without-selinux"
  ] ++ optionals (versionOlder source.version "9.3.0") [
    "--enable-shared"
  ] ++ optionals (versionAtLeast source.version "9.4.0") [
    "--disable-tap-tests"
    "--with-uuid=ossp"
  ] ++ optionals (versionOlder source.version "9.4.0") [
    "--without-krb5"
    "--with-ossp-uuid"
  ] ++ optionals (versionOlder source.version "9.5.0") [
    "--enable-atomics"
  ];

  outputs = [ "out" "doc" ];

  # We need to build world to include contrib (like pg_upgrade) and docs
  buildFlags = [ "world" ];
  installFlags = [ "install-world" ];

  postInstall = ''
    # Prevent a retained dependency on gcc-wrapper.
    substituteInPlace $out/lib/pgxs/src/Makefile.global --replace ${stdenv.cc}/bin/ld ld
  '';

  disallowedReferences = [ stdenv.cc ];

  passthru = {
    psqlSchema = channel;
  };

  meta = with stdenv.lib; {
    homepage = http://www.postgresql.org/;
    description = "A powerful, open source object-relational database system";
    license = licenses.postgresql;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
