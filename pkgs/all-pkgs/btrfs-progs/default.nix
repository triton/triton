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

stdenv.mkDerivation rec {
  name = "btrfs-progs-${version}";
  version = "4.5";

  src = fetchurl {
    url = "mirror://kernel/linux/kernel/people/kdave/btrfs-progs/btrfs-progs-v${version}.tar.xz";
    sha256 = "ee7813d8a7cb7eca230b28713f675487edb982df3c47d6619f46468579e0a811";
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
