{ stdenv, fetchFromGitHub, libpcap, ppp }:

let version = "1.3.6";
in stdenv.mkDerivation {
  name = "xl2tpd-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "xelerance";
    repo = "xl2tpd";
    rev = "v${version}";
    sha256 = "8a597acf4a629ad5760b0099e54339a94d6b03bd2bcb57256f5fd86ca699c546";
  };

  buildInputs = [ libpcap ];

  postPatch = ''
    substituteInPlace l2tp.h --replace /usr/sbin/pppd ${ppp}/sbin/pppd
  '';

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with stdenv.lib; {
    homepage = http://www.xelerance.com/software/xl2tpd/;
    description = "Layer 2 Tunnelling Protocol Daemon (RFC 2661)";
    platforms = platforms.linux;
    license = licenses.gpl2;
    maintainers = with maintainers; [ abbradar ];
  };
}
