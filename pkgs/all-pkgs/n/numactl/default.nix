{ stdenv
, fetchurl
}:

let
  version = "2.0.13";
in
stdenv.mkDerivation rec {
  name = "numactl-${version}";

  src = fetchurl {
    url = "https://github.com/numactl/numactl/releases/download/v${version}/${name}.tar.gz";
    sha256 = "991e254b867eb5951a44d2ae0bf1996a8ef0209e026911ef6c3ef4caf6f58c9a";
  };

  disableStatic = false;

  meta = with stdenv.lib; {
    description = "Library and tools for non-uniform memory access (NUMA) machines";
    homepage = http://oss.sgi.com/projects/libnuma/;
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ wkennington ];
  };
}
