{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libmnl-1.0.3";

  src = fetchurl {
    url = "http://netfilter.org/projects/libmnl/files/${name}.tar.bz2";
    sha256 = "1pl4wwzl9ibn4klm60f8ynd4xrb2w6fbbfvivk165g6dk9p3653g";
  };

  meta = with stdenv.lib; {
    description = "minimalistic user-space library oriented to Netlink developers";
    homepage = http://netfilter.org/projects/libmnl/index.html;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
