{ stdenv
, asciidoc
, docbook_xsl
, docbook_xml_dtd_45
, fetchurl
, libxslt
, xmlto

, acl
, attr
, e2fsprogs
, lzo
, util-linux_lib
, zlib
}:

let
  version = "4.6";
  tarballUrls = [
    "mirror://kernel/linux/kernel/people/kdave/btrfs-progs/btrfs-progs-v${version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "btrfs-progs-${version}";

  src = fetchurl {
    urls = map (n: "${n}.xz") tarballUrls;
    allowHashOutput = false;
    sha256 = "d867565a998dd8d3f8787019bc078ff23ef1302045b2da246b5a827902084df2";
  };

  nativeBuildInputs = [
    asciidoc
    docbook_xsl
    docbook_xml_dtd_45
    libxslt
    xmlto
  ];

  buildInputs = [
    acl
    attr
    e2fsprogs
    lzo
    util-linux_lib
    zlib
  ];

  passthru = {
    srcVerified = fetchurl rec {
      failEarly = true;
      pgpDecompress = true;
      pgpsigUrls = map (n: "${n}.sign") tarballUrls;
      pgpKeyFingerprint = "F2B4 1200 C54E FB30 380C  1756 C565 D5F9 D76D 583B";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Utilities for the btrfs filesystem";
    homepage = https://btrfs.wiki.kernel.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms =  with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
