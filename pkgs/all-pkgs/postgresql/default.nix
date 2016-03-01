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
}:

let

  inherit (stdenv.lib)
    optionals
    versionAtLeast
    versionOlder;

  common = { version, sha256, psqlSchema } @ args: stdenv.mkDerivation (rec {
    name = "postgresql-${version}";

    src = fetchurl {
      url = "mirror://postgresql/source/v${version}/${name}.tar.bz2";
      inherit sha256;
    };

    patches = [
      ./less-is-more.patch
    ] ++ optionals (versionOlder version "9.4.0") [
      ./disable-resolve_symlinks.patch
    ] ++ optionals (versionAtLeast version "9.4.0") [
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
    ] ++ optionals (versionAtLeast version "9.1.0") [
      "--without-selinux"
    ] ++ optionals (versionOlder version "9.3.0") [
      "--enable-shared"
    ] ++ optionals (versionAtLeast version "9.4.0") [
      "--disable-tap-tests"
      "--with-uuid=ossp"
    ] ++ optionals (versionOlder version "9.4.0") [
      "--without-krb5"
      "--with-ossp-uuid"
    ] ++ optionals (versionOlder version "9.5.0") [
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
      inherit psqlSchema;
    };

    meta = with stdenv.lib; {
      homepage = http://www.postgresql.org/;
      description = "A powerful, open source object-relational database system";
      license = licenses.postgresql;
      maintainers = with maintainers; [
        wkennington
      ];
      platforms = with platforms;
        i686-linux
        ++ x86_64-linux;
    };
  });

in {

  postgresql91 = common {
    version = "9.1.20";
    psqlSchema = "9.1";
    sha256 = "0dr9hz1a0ax30f6jvnv2rck0zzxgk9x7nh4n1xgshrf26i1nq7kd";
  };

  postgresql92 = common {
    version = "9.2.15";
    psqlSchema = "9.2";
    sha256 = "0q1yahkfys78crf59avp02ibd0lp3z7h626xchyfi6cqb03livbw";
  };

  postgresql93 = common {
    version = "9.3.11";
    psqlSchema = "9.3";
    sha256 = "08ba951nfiy516flaw352shj1zslxg4ryx3w5k0adls1r682l8ix";
  };

  postgresql94 = common {
    version = "9.4.6";
    psqlSchema = "9.4";
    sha256 = "19j0845i195ksg9pvnk3yc2fr62i7ii2bqgbidfjq556056izknb";
  };

  postgresql95 = common {
    version = "9.5.1";
    psqlSchema = "9.5";
    sha256 = "1ljvijaja5zy4i5b1450drbj8m3fcm3ly1zzaakp75x30s2rsc3b";
  };


}
