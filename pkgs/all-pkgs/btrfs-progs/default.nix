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
  version = "4.5.3";
  tarballUrls = [
    "mirror://kernel/linux/kernel/people/kdave/btrfs-progs/btrfs-progs-v${version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "btrfs-progs-${version}";

  src = fetchurl {
    urls = map (n: "${n}.xz") tarballUrls;
    allowHashOutput = false;
    sha256 = "e6e79608d81ccda62ad877c20e4d0868dc68e570ba42f4c94e66bf5e8ee0ebd3";
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
