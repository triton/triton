{ stdenv
, bison
, fetchurl
, flex
, groff

, audit_lib
, coreutils
, cyrus-sasl
, openldap
, openssl
, pam
, zlib
}:

stdenv.mkDerivation rec {
  name = "sudo-1.8.31";

  src = fetchurl {
    url = "https://www.sudo.ws/dist/${name}.tar.gz";
    multihash = "QmWhY16ZgcTYTu2Le9iLuGBm3gmD7JEhNrwAk2JgZtytwW";
    hashOutput = false;
    sha256 = "7ea8d97a3cee4c844e0887ea7a1bd80eb54cc98fd77966776cb1a80653ad454f";
  };

  nativeBuildInputs = [
    bison
    flex
    groff
  ];

  buildInputs = [
    audit_lib
    cyrus-sasl
    openldap
    openssl
    pam
    zlib
  ];

  postPatch = ''
    # Don't setuid
    sed -i 's,4755,0755,g' src/Makefile.in
  '';

  configureFlags = [
    "--with-linux-audit"
    "--with-sssd"
    "--with-pam"
    "--with-logging=syslog"
    "--with-rundir=/run/sudo"
    "--with-vardir=/var/db/sudo"
    "--with-sendmail=/var/setuid-wrappers/sendmail"
    "--with-env-editor"
    "--with-ldap"
    "--enable-zlib"
    "--enable-openssl"
    "--with-pam-login"
  ];

  postConfigure = ''
    cat >> pathnames.h <<'EOF'
      #undef _PATH_MV
      #define _PATH_MV "${coreutils}/bin/mv"
    EOF
    makeFlagsArray+=(
      "install_uid=$(id -u)"
      "install_gid=$(id -g)"
    )
    installFlagsArray+=(
      "sudoers_uid=$(id -u)"
      "sudoers_gid=$(id -g)"
      "sysconfdir=$out/etc"
      "rundir=$TMPDIR/dummy"
      "vardir=$TMPDIR/dummy"
    )
  '';

  # Needed to pass the install process since it checks sudoers
  preInstall = ''
    mkdir -p "$out"/etc
    touch "$out"/etc/sudoers
  '';

  postInstall = ''
    rm -f $out/share/doc/sudo/ChangeLog
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprints = [
          # Todd C. Miller
          "59D1 E9CC BA2B 3767 04FD  D35B A9F4 C021 CEA4 70FB"
          "CCB2 4BE9 E948 1B15 D341  5953 5A89 DFA2 7EE4 70C4"
        ];
      };
    };
  };

  meta = with stdenv.lib; {
    description = "A command to run commands as root";
    homepage = http://www.sudo.ws/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
