{ stdenv
, fetchurl

, libmnl
}:

stdenv.mkDerivation rec {
  name = "libnetfilter_cttimeout-1.0.0";

  src = fetchurl {
    url = "http://netfilter.org/projects/libnetfilter_cttimeout/files/${name}.tar.bz2";
    md5Confirm = "7697437fc9ebb6f6b83df56a633db7f9";
    sha256 = "aeab12754f557cba3ce2950a2029963d817490df7edb49880008b34d7ff8feba";
  };

  buildInputs = [
    libmnl
  ];

  meta = with stdenv.lib; {
    description = "Userspace library that provides the programming interface to the connection tracking timeout infrastructure";
    homepage = http://netfilter.org/projects/libnetfilter_cttimeout/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
