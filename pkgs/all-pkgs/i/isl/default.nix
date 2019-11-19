{ stdenv
, fetchurl

, gmp

, channel
}:

let
  sources = {
    "0.22" = {
      version = "0.22";
      multihash = "QmUJW5Mkw7spZCVbP6ZCxEVXqfZW469seVJbwfW8PSpQQT";
      sha256 = "6c8bc56c477affecba9c59e2c9f026967ac8bad01b51bdd07916db40a517b9fa";
    };
  };

  inherit (sources."${channel}")
    multihash
    sha256
    version;
in
stdenv.mkDerivation rec {
  name = "isl-${version}";

  src = fetchurl {
    url = "http://isl.gforge.inria.fr/${name}.tar.xz";
    inherit sha256; #multihash sha256;
  };

  buildInputs = [
    gmp
  ];

  configureFlags = [
    "--disable-silent-rules"
    "--enable-portable-binary"
  ];

  postInstall = ''
    mkdir -p "$lib"/lib
    mv -v "$dev"/lib*/*.so* "$lib"/lib
    mv -v "$lib"/lib/*gdb* "$dev"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  outputs = [
    "dev"
    "lib"
  ];

  meta = with stdenv.lib; {
    homepage = http://www.kotnet.org/~skimo/isl/;
    description = "A library for manipulating sets and relations of integer points bounded by linear constraints";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux ++
      x86_64-linux ++
      powerpc64le-linux;
  };
}
