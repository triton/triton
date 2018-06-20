{ stdenv
, asciidoc
, docbook-xsl
, docbook_xml_dtd_45
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
  version = "4.17";

  tarballUrls = [
    "mirror://kernel/linux/kernel/people/kdave/btrfs-progs/btrfs-progs-v${version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "btrfs-progs-${version}";

  src = fetchurl {
    urls = map (n: "${n}.xz") tarballUrls;
    hashOutput = false;
    sha256 = "82ca0ecf76350a1e3c6543fe220c0910e240511e663d51fc79c32bd0052c117c";
  };

  nativeBuildInputs = [
    asciidoc
    docbook-xsl
    docbook_xml_dtd_45
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

  configureFlags = [
    "--disable-python"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      pgpDecompress = true;
      pgpsigUrls = map (n: "${n}.sign") tarballUrls;
      pgpKeyFingerprint = "F2B4 1200 C54E FB30 380C  1756 C565 D5F9 D76D 583B";
      inherit (src) urls outputHash outputHashAlgo;
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
