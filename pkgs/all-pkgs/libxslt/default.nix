{ stdenv
, fetchpatch
, fetchurl

, findXMLCatalogs
, libxml2
}:

stdenv.mkDerivation rec {
  name = "libxslt-1.1.28";

  src = fetchurl {
    url = "http://xmlsoft.org/sources/${name}.tar.gz";
    sha256 = "13029baw9kkyjgr7q3jccw2mz38amq7mmpr5p3bh775qawd1bisz";
  };

  patches = [
    (fetchpatch {
      name = "CVE-2015-7995.patch";
      url = "http://git.gnome.org/browse/libxslt/patch/?id=7ca19df892ca22";
      sha256 = "1xzg0q94dzbih9nvqp7g9ihz0a3qb0w23l1158m360z9smbi8zbd";
    })
  ];

  buildInputs = [
    libxml2
  ];

  propagatedBuildInputs = [
    findXMLCatalogs
  ];

  configureFlags = [
    "--with-libxml-prefix=${libxml2}"
    "--without-python"
    "--with-crypto"
    "--without-debug"
    "--without-mem-debug"
    "--without-debugger"
  ];

  meta = with stdenv.lib; {
    homepage = http://xmlsoft.org/XSLT/;
    description = "A C library and tools to do XSL transformations";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
