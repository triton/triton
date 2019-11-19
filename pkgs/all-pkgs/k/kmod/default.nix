{ stdenv
, fetchurl
, libxslt

, openssl
, xz
, zlib
}:

let
  name = "kmod-26";

  tarballUrls = [
    "mirror://kernel/linux/utils/kernel/kmod/${name}.tar"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    urls = map (n: "${n}.xz") tarballUrls;
    hashOutput = false;
    sha256 = "57bb22c8bb56435991f6b0810a042b0a65e2f1e217551efa58235b7034cdbb9d";
  };

  nativeBuildInputs = [
    libxslt
  ];

  buildInputs = [
    openssl
    xz
    zlib
  ];

  patches = [
    ./module-dir.patch
  ];

  addStatic = false;

  configureFlags = [
    "--sysconfdir=/etc"
    "--with-xz"
    "--with-zlib"
    "--with-openssl"
  ];

  postInstall = ''
    mkdir -p "$bin"
    mv -v "$dev"/bin "$bin"

    # Use symlinks instead of hard-links or copies
    for prog in rmmod lsmod insmod modinfo modprobe depmod; do
      ln -sv kmod $bin/bin/$prog
    done

    mkdir -p "$lib"/lib
    mv -v "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  postFixup = ''
    rm -rv "$dev"/share
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
    "man"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrl = map (n: "${n}.sign") tarballUrls;
        pgpDecompress = true;
        pgpKeyFingerprint = "EAB3 3C96 9001 3C73 3916  AC83 9BA2 A5A6 30CB EA53";
      };
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.kernel.org/pub/linux/utils/kernel/kmod/;
    description = "Tools for loading and managing Linux kernel modules";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
