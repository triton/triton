{ stdenv
, fetchurl
, makeWrapper
, perlPackages

, cyrus-sasl
, db
, icu
, krb5_lib
, net-snmp
, nspr
, nss
, openldap
, pam
, pcre
, svrcore
}:

stdenv.mkDerivation rec {
  name = "389-ds-base-1.3.5.15";

  src = fetchurl {
    url = "http://directory.fedoraproject.org/binaries/${name}.tar.bz2";
    multihash = "QmS9xkKoLWAbfVRdoeEteobXUVLAu5WMv5ifYctPLTCySW";
    sha256 = "21dd81525422b64d2760144a4dedf1d3351ecdea7e8e40ae97cd7645b2b527fc";
  };

  nativeBuildInputs = [
    makeWrapper
    perlPackages.perl
  ];

  buildInputs = [
    cyrus-sasl
    db
    icu
    krb5_lib
    net-snmp
    nspr
    nss
    nunc-stans
    openldap
    pam
    pcre
    svrcore
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-presence"
    "--enable-nunc-stans"
    "--with-openldap=${openldap}"
    "--with-db=${db}"
    "--with-sasl=${cyrus-sasl}"
    "--with-netsnmp=${net-snmp}"
    "--with-nunc-stans=${nunc-stans}"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
    )
  '';

  postInstall = ''
    files=($(find "$out"/{s,}bin -type f -name \*.pl))
    for file in "''${files[@]}"; do
      echo "Wrapping: $file" >&2
      wrapProgram "$file" \
        --prefix PERL5LIB : "$(echo ${perlPackages.MozillaLdap}/${perlPackages.perl.libPrefix})" \
        --prefix PERL5LIB : "$(echo ${perlPackages.NetAddrIP}/${perlPackages.perl.libPrefix})"
    done
  '';

  # This fails randomly otherwise
  installParallel = false;

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
