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
, nunc-stans
, openldap
, pam
, pcre
, svrcore
}:

stdenv.mkDerivation rec {
  name = "389-ds-base-1.3.4.14";

  src = fetchurl {
    url = "http://directory.fedoraproject.org/binaries/${name}.tar.bz2";
    multihash = "QmZw4LnEFZFTwU3M7dKdkPZD6USEVRnbiXcxBUhCGe24HT";
    sha256 = "4408e61c52dc56d8e0ffee530dde70c2af00aa86b385cc40b389ef8bcce55aaa";
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
  parallelInstall = false;

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
