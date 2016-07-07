{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libmnl-1.0.4";

  src = fetchurl {
    url = "http://netfilter.org/projects/libmnl/files/${name}.tar.bz2";
    sha1Confirm = "2db40dea612e88c62fd321906be40ab5f8f1685a";
    sha256 = "171f89699f286a5854b72b91d06e8f8e3683064c5901fb09d954a9ab6f551f81";
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
