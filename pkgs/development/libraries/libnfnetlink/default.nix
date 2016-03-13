{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "libnfnetlink-1.0.1";

  src = fetchurl {
    url = "http://www.netfilter.org/projects/libnfnetlink/files/${name}.tar.bz2";
    sha256 = "06mm2x4b01k3m7wnrxblk9j0mybyr4pfz28ml7944xhjx6fy2w7j";
  };

  meta = {
    description = "Low-level library for netfilter kernel/userspace communication";
    homepage = http://www.netfilter.org/projects/libnfnetlink/index.html;
    license = stdenv.lib.licenses.gpl2;

    platforms = stdenv.lib.platforms.linux;
  };
}
