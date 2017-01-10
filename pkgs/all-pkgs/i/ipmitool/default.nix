{ stdenv
, fetchurl

, openssl_1-0-2
}:

let
  version = "1.8.18";
in
stdenv.mkDerivation rec {
  name = "ipmitool-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/ipmitool/ipmitool/${version}/${name}.tar.bz2";
    sha256 = "0c1ba3b1555edefb7c32ae8cd6a3e04322056bc087918f07189eeedfc8b81e01";
  };

  buildInputs = [
    openssl_1-0-2
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--infodir=$out/share/info"
      "--mandir=$out/share/man"
    )
  '';

  meta = with stdenv.lib; {
    description = "Command-line interface to IPMI-enabled devices";
    homepage = http://ipmitool.sourceforge.net;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
