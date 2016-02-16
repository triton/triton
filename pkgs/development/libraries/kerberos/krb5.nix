{ stdenv, fetchurl, pkgconfig, perl, yacc

# Optional Dependencies
, libedit ? null, readline ? null, ncurses ? null, libverto ? null
, openldap ? null

# Crypto Dependencies
, openssl ? null, nss ? null, nspr ? null

# Extra Arguments
, type ? ""
}:

with stdenv;
let
  libOnly = type == "lib";

  optOpenssl = shouldUsePkg openssl;
  optNss = shouldUsePkg nss;
  optNspr = shouldUsePkg nspr;
  optLibedit = if libOnly then null else shouldUsePkg libedit;
  optReadline = if libOnly then null else shouldUsePkg readline;
  optNcurses = if libOnly then null else shouldUsePkg ncurses;
  optLibverto = shouldUsePkg libverto;
  optOpenldap = if libOnly then null else shouldUsePkg openldap;

  # Prefer the openssl implementation
  cryptoStr = if optOpenssl != null then "openssl"
    else if optNss != null && optNspr != null then "nss"
    else "builtin";

  cryptoInputs = {
    "openssl" = [ optOpenssl ];
    "nss" = [ optNss optNspr ];
    "builtin" = [ ];
  }.${cryptoStr};

  tlsStr = if optOpenssl != null then "openssl"
    else "no";

  tlsInputs = {
    "openssl" = [ optOpenssl ];
    "no" = [ ];
  }.${tlsStr};

  # Libedit is less buggy in krb5, readline breaks tests
  lineParserStr = if optLibedit != null then "libedit"
    else if optReadline != null && optNcurses != null then "readline"
    else "no";

  lineParserInputs = {
    "libedit" = [ optLibedit ];
    "readline" = [ optReadline optNcurses ];
    "no" = [ ];
  }.${lineParserStr};
in
with stdenv.lib;
stdenv.mkDerivation rec {
  name = "${type}krb5-${version}";
  version = "1.14";

  src = fetchurl {
    url = "${meta.homepage}dist/krb5/1.14/krb5-${version}.tar.gz";
    sha256 = "1sgr61cnkgc5xazijaww6wpn5fnxl9vyj9ixk3r3y7ikv3x0gnyf";
  };

  prePatch= ''
    cd src
  '';

  nativeBuildInputs = [ pkgconfig perl yacc ];
  buildInputs = [ optOpenssl optLibverto optOpenldap ]
    ++ cryptoInputs ++ tlsInputs ++ lineParserInputs;

  configureFlags = [
    (mkOther                                "sysconfdir"          "/etc")
    (mkOther                                "localstatedir"       "/var")
    (mkEnable false                         "athena"              null)
    (mkWith   false                         "vague-errors"        null)
    (mkWith   true                          "crypto-impl"         cryptoStr)
    (mkWith   true                          "pkinit-crypto-impl"  cryptoStr)
    (mkWith   true                          "tls-impl"            tlsStr)
    (mkEnable true                          "aesni"               null)
    (mkEnable true                          "kdc-lookaside-cache" null)
    (mkEnable (optOpenssl != null)          "pkinit"              null)
    (mkWith   (lineParserStr == "libedit")  "libedit"             null)
    (mkWith   (lineParserStr == "readline") "readline"            null)
    (mkWith   (optLibverto != null)         "system-verto"        null)
    (mkWith   (optOpenldap != null)         "ldap"                null)
    (mkWith   false                         "tcl"                 null)
    (mkWith   false                         "system-db"           null)  # Requires db v1.85
  ];

  buildPhase = optionalString libOnly ''
    (cd util; make -j $NIX_BUILD_CORES)
    (cd include; make -j $NIX_BUILD_CORES)
    (cd lib; make -j $NIX_BUILD_CORES)
    (cd build-tools; make -j $NIX_BUILD_CORES)
  '';

  installPhase = optionalString libOnly ''
    mkdir -p $out/{bin,include/{gssapi,gssrpc,kadm5,krb5},lib/pkgconfig,sbin,share/{et,man/man1}}
    (cd util; make -j $NIX_BUILD_CORES install)
    (cd include; make -j $NIX_BUILD_CORES install)
    (cd lib; make -j $NIX_BUILD_CORES install)
    (cd build-tools; make -j $NIX_BUILD_CORES install)
    rm -rf $out/{sbin,share}
    find $out/bin -type f | grep -v 'krb5-config' | xargs rm
  '';

  meta = {
    description = "MIT Kerberos 5";
    homepage = http://web.mit.edu/kerberos/;
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ wkennington ];
  };

  passthru.implementation = "krb5";
}
