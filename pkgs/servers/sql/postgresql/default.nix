{ stdenv, fetchurl, bison, flex
, gettext

# Optional Dependencies
, kerberos ? null, pam ? null, openldap ? null, openssl ? null, readline ? null
, libossp_uuid ? null, libxml2 ? null, libxslt ? null, zlib ? null

# Extra Arguments
, blockSizeKB ? 8, segmentSizeGB ? 1
, walBlockSizeKB ? 8, walSegmentSizeMB ? 16
}:

with stdenv;
with stdenv.lib;
let

  optKerberos = shouldUsePkg kerberos;
  optPam = shouldUsePkg pam;
  optOpenldap = shouldUsePkg openldap;
  optOpenssl = shouldUsePkg openssl;
  optReadline = shouldUsePkg readline;
  optLibossp_uuid = shouldUsePkg libossp_uuid;
  optLibxml2 = shouldUsePkg libxml2;
  optLibxslt = shouldUsePkg libxslt;
  optZlib = shouldUsePkg zlib;

  uuid = if optLibossp_uuid != null then "ossp"
    else if stdenv.isDarwin then "e2fs"
    else null;

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

    nativeBuildInputs = [ bison flex ];
    buildInputs = [
      gettext optKerberos optPam optOpenldap optOpenssl optReadline
      optLibossp_uuid optLibxml2 optLibxslt optZlib
    ];

    configureFlags = [
      (mkOther                            "sysconfdir"        "/etc")
      (mkOther                            "localstatedir"     "/var")
      (mkEnable true                      "integer-datetimes" null)
      (mkEnable true                      "nls"               null)
      (mkWith   true                      "pgport"            "5432")
      (mkEnable true                      "rpath"             null)
      (mkEnable true                      "spinlocks"         null)
      (mkEnable false                     "debug"             null)
      (mkEnable false                     "profiling"         null)
      (mkEnable false                     "coverage"          null)
      (mkEnable false                     "dtrace"            null)
      (mkWith   true                      "blocksize"         (toString blockSizeKB))
      (mkWith   true                      "segsize"           (toString segmentSizeGB))
      (mkWith   true                      "wal-blocksize"     (toString walBlockSizeKB))
      (mkWith   true                      "wal-segsize"       (toString walSegmentSizeMB))
      (mkEnable true                      "depend"            null)
      (mkEnable false                     "cassert"           null)
      (mkEnable true                      "thread-safety"     null)
      (mkWith   false                     "tcl"               null)  # Maybe enable some day
      (mkWith   false                     "perl"              null)  # Maybe enable some day
      (mkWith   false                     "python"            null)  # Maybe enable some day
      (mkWith   (optKerberos != null)     "gssapi"            null)
      (mkWith   (optPam != null)          "pam"               null)
      (mkWith   (optOpenldap != null)     "ldap"              null)
      (mkWith   false                     "bonjour"           null)
      (mkWith   (optOpenssl != null)      "openssl"           null)
      (mkWith   (optReadline != null)     "readline"          null)
      (mkWith   false                     "libedit-preferred" null)
      (mkWith   (optLibxml2 != null)      "libxml"            null)
      (mkWith   (optLibxslt != null)      "libxslt"           null)
      (mkWith   (optZlib != null)         "zlib"              null)
    ] ++ optionals (versionAtLeast version "9.1.0") [
      (mkWith   false                     "selinux"           null)
    ] ++ optionals (versionOlder version "9.3.0") [
      (mkEnable true                      "shared"            null)
    ] ++ optionals (versionAtLeast version "9.4.0") [
      (mkEnable false                     "tap-tests"         null)
      (mkWith   (uuid != null)            "uuid"              uuid)
    ] ++ optionals (versionOlder version "9.4.0") [
      (mkWith   false                     "krb5"              null)
      (mkWith   (optLibossp_uuid != null) "ossp-uuid"         null)
    ];

    enableParallelBuilding = true;

    outputs = [ "out" "doc" ];

    # We need to build world to include contrib (like pg_upgrade) and docs
    buildFlags = [ "world" ];
    installFlags = [ "install-world" ];

    postInstall =
      ''
        # Prevent a retained dependency on gcc-wrapper.
        substituteInPlace $out/lib/pgxs/src/Makefile.global --replace ${stdenv.cc}/bin/ld ld
      '';

    disallowedReferences = [ stdenv.cc ];

    passthru = {
      inherit psqlSchema;
      readline = optReadline;
    };

    meta = with lib; {
      homepage = http://www.postgresql.org/;
      description = "A powerful, open source object-relational database system";
      license = licenses.postgresql;
      maintainers = with maintainers; [ ocharles wkennington ];
      platforms = platforms.unix;
      hydraPlatforms = platforms.linux;
    };
  });

in {

  postgresql90 = common {
    version = "9.0.23";
    psqlSchema = "9.0";
    sha256 = "1pnpni95r0ry112z6ycrqk5m6iw0vd4npg789czrl4qlr0cvxg1x";
  };

  postgresql91 = common {
    version = "9.1.19";
    psqlSchema = "9.1";
    sha256 = "1ihf9h353agsm5p2dr717dvraxvsw6j7chbn3qxdcz8la5s0bmfb";
  };

  postgresql92 = common {
    version = "9.2.14";
    psqlSchema = "9.2";
    sha256 = "0bi9zfsfhj84mnaa41ar63j9qgzsnac1wwgjhy2c6j0a68zhphjl";
  };

  postgresql93 = common {
    version = "9.3.10";
    psqlSchema = "9.3";
    sha256 = "0c8mailildnqnndwpmnqf8ymxmk1qf5w5dq02hjqmydgfq7lyi75";
  };

  postgresql94 = common {
    version = "9.4.5";
    psqlSchema = "9.4";
    sha256 = "0faav7k3nlhh1z7j1r3adrhx1fpsji3jixmm2abjm93fdg350z5q";
  };

  postgresql95 = common {
    version = "9.5.0";
    psqlSchema = "9.5";
    sha256 = "f1c0d3a1a8aa8c92738cab0153fbfffcc4d4158b3fee84f7aa6bfea8283978bc";
  };


}
