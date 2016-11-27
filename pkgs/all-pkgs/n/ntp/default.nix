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
  patch = "8p9";
in
stdenv.mkDerivation rec {
  name = "ntp-${major}.${minor}.${patch}";

  src = fetchurl rec {
    url = "http://archive.ntp.org/ntp${major}/ntp-${major}.${minor}/${name}.tar.gz";
    md5Url = "${url}.md5";
    sha256 = "b724287778e1bac625b447327c9851eedef020517a3545625e9f652a90f30b72";
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
