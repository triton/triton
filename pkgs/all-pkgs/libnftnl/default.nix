{ stdenv
, fetchurl

, jansson
, libmnl
, mxml
}:

stdenv.mkDerivation rec {
  name = "libnftnl-1.0.5";

  src = fetchurl {
    url = "http://netfilter.org/projects/libnftnl/files/${name}.tar.bz2";
    sha256 = "15z4kcsklbvy94d24p2r0avyhc2rsvygjqr3gyccg2z30akzbm7n";
  };

  buildInputs = [
    jansson
    libmnl
    mxml
  ];

  configureFlags = [
    "--with-json-parsing"
    "--with-xml-parsing"
  ];

  meta = with stdenv.lib; {
    description = "a userspace library providing a low-level netlink API to the in-kernel nf_tables subsystem";
    homepage = http://netfilter.org/projects/libnftnl;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
