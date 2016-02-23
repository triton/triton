{ stdenv
, fetchurl

, findXMLCatalogs
, icu
, python
, readline
, xz
, zlib
}:

let
  sitePackages = "\${out}/lib/${python.libPrefix}/site-packages";
in
stdenv.mkDerivation rec {
  name = "libxml2-${version}";
  version = "2.9.3";

  src = fetchurl {
    url = "http://xmlsoft.org/sources/${name}.tar.gz";
    sha256 = "0bd17g6znn2r98gzpjppsqjg33iraky4px923j3k8kdl8qgy7sad";
  };

  buildInputs = [
    icu
    python
    readline
    xz
    zlib
  ];

  propagatedBuildInputs = [
    findXMLCatalogs
  ];

  preConfigure = ''
    configureFlagsArray+=("--with-python-install-dir=$(toPythonPath "$out")")
  '';

  configureFlags = [
    "--with-icu=${icu}"
    "--with-python=${python}"
    "--with-readline=${readline}"
    "--with-zlib=${zlib}"
    "--with-lzma=${xz}"
  ];

  meta = with stdenv.lib; {
    homepage = http://xmlsoft.org/;
    description = "An XML parsing library for C";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
