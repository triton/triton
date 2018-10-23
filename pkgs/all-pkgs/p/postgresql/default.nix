{ stdenv
, bison
, fetchTritonPatch
, fetchurl
, flex
, gettext
, libxslt

# Optional Dependencies
, kerberos
, icu
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
    hashOutput = false;
    inherit (source) sha256;
  };

  patches = [
    (fetchTritonPatch {
      rev = "3ae0a8f2ad3c8518381e400e319e275f4b1dd06e";
      file = "p/postgresql/disable-resolve_symlinks-9.4.0.patch";
      sha256 = "c90d8ec802b606ed5541e69e764e5eb66e047243289821b381c2ce63ede3e856";
    })
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
    systemd_lib
    zlib
  ] ++ optionals (versionAtLeast source.version "10.0") [
    icu
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
    "--without-selinux"
    "--disable-tap-tests"
    "--with-uuid=ossp"
    "--with-systemd"
  ] ++ optionals (versionAtLeast source.version "10.0") [
    "--with-icu"
  ] ++ optionals (versionOlder source.version "11.0") [
    "--with-wal-segsize=${toString walSegmentSizeMB}"
  ] ++ optionals (versionAtLeast source.version "11.0") [
    #"--with-llvm"  # jit
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

    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        md5Url = map (n: "${n}.md5") src.urls;
        sha256Url = map (n: "${n}.sha256")src.urls;
      };
    };
  };

  # Sometimes fails
  installParallel = false;

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
