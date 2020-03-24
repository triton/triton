{ stdenv
, fetchurl
, libxslt

, openssl
, xz
, zlib
}:

let
  name = "kmod-27";

  tarballUrls = [
    "mirror://kernel/linux/utils/kernel/kmod/${name}.tar"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    urls = map (n: "${n}.xz") tarballUrls;
    hashOutput = false;
    sha256 = "c1d3fbf16ca24b95f334c1de1b46f17bbe5a10b0e81e72668bdc922ebffbbc0c";
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

  configureFlags = [
    "--sysconfdir=/etc"
    "--with-xz"
    "--with-zlib"
    "--with-openssl"
  ];

  # Use symlinks instead of hard-links or copies
  postInstall = ''
    ln -s kmod $out/bin/lsmod
    mkdir -p $out/sbin
    for prog in rmmod insmod modinfo modprobe depmod; do
      ln -sv $out/bin/kmod $out/sbin/$prog
    done
  '';

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
