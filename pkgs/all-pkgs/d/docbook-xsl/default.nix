{ stdenv
, fetchTritonPatch
, fetchurl

, type ? ""
}:

let
  inherit (stdenv.lib)
    optionals;

  sources = {
    "" = {
      multihash = "QmPr15Jcki6Q434fgNcbESVkS84Wyj5NPjXDZ6vrnLQ4Nj";
      sha256 = "725f452e12b296956e8bfb876ccece71eeecdd14b94f667f3ed9091761a4a968";
    };
    "ns" = {
      multihash = "QmbNqZRikpVksYesK1fhmsqR7D6evMjdYZFxWi4TxbQVR6";
      sha256 = "36ca9026e05b8985baebd61a23af8ded8e2cf71cc3163b673159c9d78a7b0f9c";
    };
  };

  inherit (sources."${type}")
    multihash
    sha256;

  pname = "docbook-xsl${if type != "" then "-${type}" else ""}";

  version = "1.79.1";
in
stdenv.mkDerivation rec {
  name = "${pname}-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/docbook/${pname}/${version}/${name}.tar.bz2";
    inherit multihash sha256;
  };

  patches = optionals (type == "") [
    # Fix infinite recursion.
    (fetchTritonPatch {
      rev = "1fcb617f160d9c0367f334a907ef6bf0a87512c5";
      file = "d/docbook-xsl/nonrecursive-string-subst.patch";
      sha256 = "9ba5a2f75647df559c2399ec660017135e6997a188e220557e7ce106f5b6a174";
    })
  ];

  # Running make will cause the build to fail
  buildPhase = ''
    true
  '';

  installPhase = ''
    dst="$out/share/xml/${pname}"
    mkdir -pv "$dst"
    rm -rvf RELEASE* README* INSTALL TODO NEWS* BUGS install.sh \
      svn* tools log Makefile tests extensions webhelp
    mv * "$dst"

    # Backwards compatibility. Will remove eventually.
    mkdir -p "$out"/xml/xsl
    ln -sv "$dst" "$out"/xml/xsl/docbook
  '';

  meta = with stdenv.lib; {
    description = "XSL stylesheets for converting DocBook documents into other formats";
    homepage = http://wiki.docbook.org/topic/DocBookXslStylesheets;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
