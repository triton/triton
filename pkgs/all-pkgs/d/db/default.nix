{ stdenv
, fetchTritonPatch
, fetchurl
, lib

, channel
}:

let
  # Requires an account to download tarballs.
  # https://www.oracle.com/technetwork/database/database-technologies/berkeleydb/downloads/index-082944.html
  sources = {
    "5" = {
      version = "5.3.28";
      multihash = "QmQxwsAWipTXj3rJZEJMnYtKPUHBWjBVz7w8PsAU7bYtmZ";
      sha256 = "e0a992d740709892e81f9d93f06daf305cf73fb81b545afe72478043172c3628";
      license = lib.licenses.sleepycat;
    };
    "6" = {
      version = "6.2.38";
      multihash = "QmWyG1wLdna319VG92BE7DZpkDAQrxJ6CbcyN1vNuE9oZq";
      sha256 = "99ccd944ffcccc88c0f404b4f3d8cb10747e1e3dfe9ec566f518725f986ca2fd";
      license = lib.licenses.agpl30;
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "db-${source.version}";

  src = fetchurl {
    url = "http://download.oracle.com/otn/berkeley-db/${name}.tar.gz";
    hashOutput = false;
    inherit (source)
      multihash
      sha256;
  };

  patchFlags = "-p0";

  patches = lib.optionals (lib.versionOlder source.version "6.2.0") [
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
