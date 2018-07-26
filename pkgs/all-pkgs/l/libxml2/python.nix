{ stdenv
, fetchTritonPatch
, fetchurl

, libxml2
, python
}:

stdenv.mkDerivation rec {
  name = "${python.libPrefix}-${libxml2.name}";

  src = libxml2.src;

  buildInputs = [
    libxml2
    python
  ];

  postPatch = ''
    grep -q '$(top_builddir)/libxml2.la' python/Makefile.in
    sed -i 's,$(top_builddir)/libxml2.la,${libxml2}/lib/libxml2.la,' python/Makefile.in
  '';

  preConfigure = ''
    configureFlagsArray+=(
      "--with-python-install-dir=$(toPythonPath "$out")"
    )
  '';

  configureFlags = [
    "--with-python=${python.interpreter}"
  ];

  preBuild = ''
    cd python
  '';

  makeFlags = [
    "V=1"
  ];

  meta = with stdenv.lib; {
    homepage = http://xmlsoft.org/;
    description = "An XML parsing library for C";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
