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
  inherit (stdenv.lib)
    optionals
    versionAtLeast
    versionOlder;
in

let
  sources = import ./sources.nix;

  source = sources."${channel}";
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

  # Sometimes fails
  parallelInstall = false;

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
