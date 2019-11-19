{ stdenv
, fetchurl
, gnum4

, bzip2
, xz
, zlib
}:

let
  version = "0.176";
in
stdenv.mkDerivation rec {
  name = "elfutils-${version}";

  src = fetchurl {
    url = "https://sourceware.org/elfutils/ftp/${version}/${name}.tar.bz2";
    multihash = "QmaaRXyFKYMEvvH7ctZMBqsYCHe5nbCotaNmMv2pTxbr19";
    hashOutput = false;
    sha256 = "eb5747c371b0af0f71e86215a5ebb88728533c3a104a43d4231963f308cd1023";
  };

  nativeBuildInputs = [
    gnum4
  ];

  buildInputs = [
    bzip2
    xz
    zlib
  ];

  configureFlags = [
    "--bindir=${placeholder "bin"}/bin"
    "--localedir=${placeholder "bin"}/share/locale"
    "--enable-deterministic-archives"
  ];

  postInstall = ''
    mkdir -p "$lib"/lib
    mv -v "$dev"/lib/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib

    # Symlink non-prefixed tools
    pushd "$bin"/bin >/dev/null
    for prog in *; do
      [ "eu-" != "${prog:0:3}" ] && continue
      ln -sv "$prog" "${prog:3}"
    done
    popd >/dev/null
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
  ];

  passthru = {
    inherit version;
    srcVerification = fetchurl rec {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        pgpKeyFingerprint = "47CC 0331 081B 8BC6 D0FD  4DA0 8370 665B 5781 6A6A";
      };
    };
  };

  meta = with stdenv.lib; {
    description = "Libraries/utilities to handle ELF objects";
    homepage = https://sourceware.org/elfutils/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
