{ stdenv
, fetchurl
, perl
, which

, libcap
, libedit
, libevent
, libseccomp
, net-snmp
, openssl
}:

let
  major = "4";
  minor = "2";
  patch = "8p7";
in
stdenv.mkDerivation rec {
  name = "ntp-${major}.${minor}.${patch}";

  src = fetchurl rec {
    url = "http://archive.ntp.org/ntp${major}/ntp-${major}.${minor}/${name}.tar.gz";
    md5Url = "${url}.md5";
    sha256 = "81d20c06a0b01abe3b84fac092185bf014252d38fe5e7b2758f604680a0220dc";
  };

  nativeBuildInputs = [
    which
    perl
  ];

  buildInputs = [
    libcap
    libedit
    libevent
    libseccomp
    net-snmp
    openssl
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-ignore-dns-errors"
    "--enable-linuxcaps"
  ];

  postInstall = ''
    rm -rf $out/share/doc
  '';

  meta = with stdenv.lib; {
    homepage = http://www.ntp.org/;
    description = "An implementation of the Network Time Protocol";
    maintainers = with stdenv.lib; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
