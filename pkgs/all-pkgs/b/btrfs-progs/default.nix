{ stdenv
, asciidoctor_2
, docbook-xsl
, fetchurl
, lib
, libxslt
, xmlto

, e2fsprogs
, lzo
, util-linux_lib
, zlib
, zstd
}:

let
  version = "5.4";

  tarballUrls = [
    "mirror://kernel/linux/kernel/people/kdave/btrfs-progs/btrfs-progs-v${version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "btrfs-progs-${version}";

  src = fetchurl {
    urls = map (n: "${n}.xz") tarballUrls;
    hashOutput = false;
    sha256 = "0f973295911224ce15a10f9c9a0d9773d13a7f0d04959afb88783009b65670fa";
  };

  nativeBuildInputs = [
    asciidoctor_2
    docbook-xsl
    libxslt
    xmlto
  ];

  buildInputs = [
    e2fsprogs
    lzo
    util-linux_lib
    zlib
    zstd
  ];

  postPatch = ''
    grep -q '^XMLTO_EXTRA =$' Documentation/Makefile.in
    sed -i '/^XMLTO_EXTRA =$/d' Documentation/Makefile.in
  '';

  configureFlags = [
    "--disable-python"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpDecompress = true;
        pgpsigUrls = map (n: "${n}.sign") tarballUrls;
        pgpKeyFingerprint = "F2B4 1200 C54E FB30 380C  1756 C565 D5F9 D76D 583B";
      };
    };
  };

  meta = with lib; {
    description = "Utilities for the btrfs filesystem";
    homepage = https://btrfs.wiki.kernel.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms =  with platforms;
      x86_64-linux;
  };
}
