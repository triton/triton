{ stdenv
, fetchurl

, zlib
}:

let
  version = "3.5.0";
in
stdenv.mkDerivation rec {
  name = "protobuf-cpp-${version}";

  src = fetchurl {
    url = "https://github.com/google/protobuf/releases/download/v${version}/${name}.tar.gz";
    sha256 = "8dd6b051c2b39ab95dfe1f53cc5e1662ceb852d856db57d85751696859698551";
  };

  buildInputs = [
    zlib
  ];

  configureFlags = [
    "--with-zlib"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
