{ stdenv
, fetchTritonPatch
, fetchurl
, lib

, channel
}:

let
  source = (
    import ./sources.nix {
      inherit (lib)
        licenses;
    }
  )."${channel}";
in
stdenv.mkDerivation rec {
  name = "db-${source.version}";

  src = fetchurl {
    url = "http://download.oracle.com/berkeley-db/${name}.tar.gz";
    inherit (source)
      multihash
      sha256;
  };

  patchFlags = "-p0";

  patches = [
    (fetchTritonPatch {
      rev = "f860b4dd819226df55909dd4f50d843494583f84";
      file = "d/db/fix-atomic-gcc8.patch";
      sha256 = "ba0e2b4f53e9cb0ec58f60a979b53b8567b4565f0384886196f1fc1ef111d151";
    })
  ];

  configureFlags = [
    "--enable-cxx"
    "--enable-compat185"
    "--enable-dbm"
    "--with-pic"
  ];

  preConfigure = ''
    cd build_unix
    configureScript=../dist/configure
  '';

  postInstall = ''
    rm -r "$out"/docs
  '';

  meta = with lib; {
    description = "Berkeley DB";
    homepage = http://www.oracle.com/technetwork/database/database-technologies/berkeleydb/index.html;
    license = source.license;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
