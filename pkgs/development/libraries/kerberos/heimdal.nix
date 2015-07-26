{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig, python, perl, yacc, flex
, texinfo ? null, perlPackages

# Optional Dependencies
, openldap ? null, libcap_ng ? null, sqlite ? null, openssl ? null, db ? null
, readline ? null, libedit ? null, pam ? null

# Extra Args
, type ? ""
}:

with stdenv;
let
  libOnly = type == "lib";

  optTexinfo = if libOnly then null else shouldUsePkg texinfo;
  optOpenldap = if libOnly then null else shouldUsePkg openldap;
  optLibcap_ng = shouldUsePkg libcap_ng;
  optSqlite = shouldUsePkg sqlite;
  optOpenssl = shouldUsePkg openssl;
  optDb = shouldUsePkg db;
  optReadline = shouldUsePkg readline;
  optLibedit = shouldUsePkg libedit;
  optPam = if libOnly then null else shouldUsePkg pam;

  lineParserStr = if optLibedit != null then "libedit"
    else if optReadline != null then "readline"
    else "no";

  lineParserInputs = {
    "libedit" = [ optLibedit ];
    "readline" = [ optReadline ];
    "no" = [ ];
  }.${lineParserStr};
in
with stdenv.lib;
stdenv.mkDerivation rec {
  name = "${type}heimdal-2015-06-17";

  src = fetchFromGitHub {
    owner = "heimdal";
    repo = "heimdal";
    rev = "be63a2914adcbea7d42d56e674ee6edb4883ebaf";
    sha256 = "147gv49gmy94y6f0x1vx523qni0frgcp3r7fill0r06rkfgfzc0j";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig python perl yacc flex optTexinfo ]
    ++ (with perlPackages; [ JSON ]);
  buildInputs = [
    optOpenldap optLibcap_ng optSqlite optOpenssl optDb optPam
  ] ++ lineParserInputs;

  configureFlags = [
    (mkOther                                "sysconfdir"            "/etc")
    (mkOther                                "localstatedir"         "/var")
    (mkWith   (optOpenldap != null)         "openldap"              optOpenldap)
    (mkEnable (optOpenldap != null)         "hdb-openldap-module"   null)
    (mkEnable true                          "pk-init"               null)
    (mkEnable true                          "digest"                null)
    (mkEnable true                          "kx509"                 null)
    (mkWith   (optLibcap_ng != null)        "capng"                 null)
    (mkWith   (optSqlite != null)           "sqlite3"               sqlite)
    (mkEnable (optSqlite != null)           "sqlite-cache"          null)
    (mkWith   false                         "libintl"               null)               # TODO libintl fix
    (mkWith   true                          "hdbdir"                "/var/lib/heimdal")
    (mkEnable false                         "dce"                   null)               # TODO: Add support
    (mkEnable (!libOnly)                    "afs-support"           null)
    (mkEnable true                          "mmap"                  null)
    (mkEnable (!libOnly)                    "afs-string-to-key"     null)
    (mkWith   (lineParserStr == "readline") "readline"              optReadline)
    (mkWith   (lineParserStr == "libedit")  "libedit"               optLibedit)
    (mkWith   false                         "hesiod"                null)
    (mkEnable (!libOnly)                    "kcm"                   null)
    (mkEnable (optTexinfo != null)          "heimdal-documentation" null)
    (mkWith   true                          "ipv6"                  null)
    (mkEnable true                          "pthread-support"       null)
    (mkEnable false                         "osfc2"                 null)
    (mkEnable false                         "socket-wrapper"        null)
    (mkEnable (!libOnly)                    "otp"                   null)
    (mkEnable false                         "developer"             null)
    (mkWith   (optDb != null)               "berkeley-db"           optDb)
    (mkEnable true                          "ndbm-db"               null)
    (mkEnable false                         "mdb-db"                null)
    (mkWith   (optOpenssl != null)          "openssl"               optOpenssl)
  ];

  buildPhase = optionalString libOnly ''
    (cd include; make -j $NIX_BUILD_CORES)
    (cd lib; make -j $NIX_BUILD_CORES)
    (cd tools; make -j $NIX_BUILD_CORES)
    (cd include/hcrypto; make -j $NIX_BUILD_CORES)
    (cd lib/hcrypto; make -j $NIX_BUILD_CORES)
  '';

  installPhase = optionalString libOnly ''
    (cd include; make -j $NIX_BUILD_CORES install)
    (cd lib; make -j $NIX_BUILD_CORES install)
    (cd tools; make -j $NIX_BUILD_CORES install)
    (cd include/hcrypto; make -j $NIX_BUILD_CORES install)
    (cd lib/hcrypto; make -j $NIX_BUILD_CORES install)
    rm -rf $out/{libexec,sbin,share}
    find $out/bin -type f | grep -v 'krb5-config' | xargs rm
  '';

  # We need to build hcrypt for applications like samba
  postBuild = ''
    (cd include/hcrypto; make -j $NIX_BUILD_CORES)
    (cd lib/hcrypto; make -j $NIX_BUILD_CORES)
  '';

  postInstall = ''
    # Install hcrypto
    (cd include/hcrypto; make -j $NIX_BUILD_CORES install)
    (cd lib/hcrypto; make -j $NIX_BUILD_CORES install)

    # Doesn't succeed with --libexec=$out/sbin, so
    mv "$out/libexec/"* $out/sbin/
    rmdir $out/libexec
  '';

  enableParallelBuilding = true;

  meta = {
    description = "An implementation of Kerberos 5 (and some more stuff)";
    license = licenses.bsd3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ wkennington ];
  };

  passthru.implementation = "heimdal";
}
