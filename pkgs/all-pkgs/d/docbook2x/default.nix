{ stdenv
, fetchurl
, fetchTritonPatch
, lib
, libxslt
, makeWrapper
, perlPackages

, findXMLCatalogs
, gnugrep
, gnused_small
, opensp
}:

let
  version = "0.8.8";

  inherit (lib)
    concatStringsSep;

  perlLib = concatStringsSep ":" (map (n: "${n}/${perlPackages.perl.libPrefix}") [
    perlPackages.XMLNamespaceSupport
    perlPackages.XMLSAX
    perlPackages.XMLSAXBase
  ]);
in
stdenv.mkDerivation rec {
  name = "docbook2X-${version}";
  
  src = fetchurl {
    url = "mirror://sourceforge/docbook2x/docbook2x/${version}/${name}.tar.gz";
    sha256 = "0ifwzk99rzjws0ixzimbvs83x6cxqk1xzmg84wa1p7bs6rypaxs0";
  };

  patches = [
    (fetchTritonPatch {
      rev = "0920142cd6d9338b3853f280a4185210e063fe2b";
      file = "d/docbook2x/db2x_texixml-to-stdout.patch";
      sha256 = "d723a78a32a273c20434696b4c8da8af990739ac1184aef4e06ce90cb6ec3ea2";
    })
    (fetchTritonPatch {
      rev = "0920142cd6d9338b3853f280a4185210e063fe2b";
      file = "d/docbook2x/fix-configure.patch";
      sha256 = "7345f4822a8b47d11f81dfb0732a548ec15a5657408e9c595d75a2de0a635691";
    })
  ];

  nativeBuildInputs = [
    libxslt
    makeWrapper
  ];

  buildInputs = [
    opensp
    perlPackages.perl
    perlPackages.XMLSAX
  ];

  propagatedBuildInputs = [
    findXMLCatalogs
  ];

  postInstall = ''
    for file in "$out"/bin/*; do
      if readelf -h "$file" >/dev/null 2>&1; then
        continue
      fi
      if head -n 1 "$file" | grep 'perl$'; then
        wrapProgram "$file" \
          --prefix PERL5LIB : "${perlLib}" \
	        --prefix XML_CATALOG_FILES "\ " \
	          "$out/share/docbook2X/dtd/catalog.xml\ $out/share/docbook2X/xslt/catalog.xml"
      fi
      if head -n 1 "$file" | grep 'sh$'; then
        wrapProgram "$file" \
          --prefix PATH : "${gnused_small}/bin:${gnugrep}/bin"
      fi
    done
  '';

  meta = with lib; {
    license = licenses.mit;
    homepage = http://docbook2x.sourceforge.net/;
    platforms = with platforms;
      x86_64-linux;
  };
}
