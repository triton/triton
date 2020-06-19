{ stdenv
, fetchurl
, gnum4

, bzip2
, curl
, libarchive
, libmicrohttpd
, sqlite
, xz
, zlib
}:

let
  version = "0.179";
in
stdenv.mkDerivation rec {
  name = "elfutils-${version}";

  src = fetchurl {
    url = "mirror://sourceware/elfutils/${version}/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "25a545566cbacaa37ae6222e58f1c48ea4570f53ba991886e2f5ce96e22a23a2";
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
    "--disable-maintainer-mode"
    "--enable-deterministic-archives"
    "--disable-debuginfod"
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
