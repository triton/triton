{ stdenv
, bison
, fetchTritonPatch
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
, systemd_lib
, libossp-uuid
, libxml2
, zlib

# Extra Arguments
, blockSizeKB ? 8, segmentSizeGB ? 1
, walBlockSizeKB ? 8, walSegmentSizeMB ? 16
, channel
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
  ] ++ optionals (versionOlder source.version "9.4.0") [
		(fetchTritonPatch {
			rev = "3ae0a8f2ad3c8518381e400e319e275f4b1dd06e";
			file = "p/postgresql/disable-resolve_symlinks.patch";
			sha256 = "2fc6e019778b298de867f06b4a55d6330f3d433e28f2a287456fced5c68912bf";
		})
  ] ++ optionals (versionAtLeast source.version "9.4.0") [
    (fetchTritonPatch {
      rev = "3ae0a8f2ad3c8518381e400e319e275f4b1dd06e";
      file = "p/postgresql/disable-resolve_symlinks-9.4.0.patch";
      sha256 = "c90d8ec802b606ed5541e69e764e5eb66e047243289821b381c2ce63ede3e856";
    })
  ] ++ optionals (versionOlder source.version "9.6.0") [
		(fetchTritonPatch {
			rev = "3ae0a8f2ad3c8518381e400e319e275f4b1dd06e";
			file = "p/postgresql/less-is-more.patch";
			sha256 = "bef1902a506bba97474a18a85349d2eceb96eef1ab7fa034d6bc2707b5d436e9";
		})
  ] ++ optionals (versionAtLeast source.version "9.6.0") [
    (fetchTritonPatch {
      rev = "3ae0a8f2ad3c8518381e400e319e275f4b1dd06e";
      file = "p/postgresql/less-is-more-9.6.0.patch";
      sha256 = "be2ef57e1b4438b640ef401e37dfc3bb1c71ea797fa1e41b9f271200d132ae51";
    })
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
  ] ++ optionals (versionAtLeast source.version "9.6.0") [
    systemd_lib
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
  ] ++ optionals (versionAtLeast source.version "9.6.0") [
    "--with-systemd"
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

  # FIXME
  buildDirCheck = false;

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
