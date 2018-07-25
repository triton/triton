{ stdenv
, fetchurl
}:

let
  version = "2.0.12";
in
stdenv.mkDerivation rec {
  name = "numactl-${version}";

  src = fetchurl {
    url = "https://github.com/numactl/numactl/releases/download/v${version}/${name}.tar.gz";
    sha256 = "55bbda363f5b32abd057b6fbb4551dd71323f5dbb66335ba758ba93de2ada729";
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
