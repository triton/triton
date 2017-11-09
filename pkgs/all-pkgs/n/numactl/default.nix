{ stdenv
, autoreconfHook
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "numactl-2.0.11";

  src = fetchurl {
    url = "ftp://oss.sgi.com/www/projects/libnuma/download/${name}.tar.gz";
    multihash = "QmaBbbjGZoxP3LoNpkVRy4oNktHtQBCSYxZVKuJDxAavCD";
    sha256 = "450c091235f891ee874a8651b179c30f57a1391ca5c4673354740ba65e527861";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  disableStatic = false;

  meta = with stdenv.lib; {
    description = "Library and tools for non-uniform memory access (NUMA) machines";
    homepage = http://oss.sgi.com/projects/libnuma/;
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ wkennington ];
  };
}
