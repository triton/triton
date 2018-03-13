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
, zlib
}:

let
  major = "4";
  minor = "2";
  patch = "8p11";
in
stdenv.mkDerivation rec {
  name = "ntp-${major}.${minor}.${patch}";

  src = fetchurl rec {
    url = "http://archive.ntp.org/ntp${major}/ntp-${major}.${minor}/${name}.tar.gz";
    md5Url = "${url}.md5";
    sha256 = "f14a39f753688252d683ff907035ffff106ba8d3db21309b742e09b5c3cd278e";
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
    zlib
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-ignore-dns-errors"
    "--enable-linuxcaps"
    "--enable-seccomp"
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
