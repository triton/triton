{ lib, stdenv, fetchurl }:

let

  common = { pname, sha256 }: stdenv.mkDerivation rec {
    name = "${pname}-1.79.0";

    src = fetchurl {
      url = "mirror://sourceforge/docbook/${name}.tar.bz2";
      inherit sha256;
    };

    buildPhase = "true";

    installPhase =
      ''
        dst=$out/share/xml/${pname}
        mkdir -p $dst
        rm -rf RELEASE* README* INSTALL TODO NEWS* BUGS install.sh svn* tools log Makefile tests extensions webhelp
        mv * $dst/

        # Backwards compatibility. Will remove eventually.
        mkdir -p $out/xml/xsl
        ln -s $dst $out/xml/xsl/docbook
      '';

    meta = {
      homepage = http://wiki.docbook.org/topic/DocBookXslStylesheets;
      description = "XSL stylesheets for transforming DocBook documents into HTML and various other formats";
      maintainers = [ lib.maintainers.eelco ];
      platforms = lib.platforms.all;
    };
  };

in {

  docbook_xsl = common {
    pname = "docbook-xsl";
    sha256 = "01nn8gmzdnfvig7cnhb8pbr7xn9h786hhzz5ygs7vjvmvk7sjyyy";
  };

  docbook_xsl_ns = common {
    pname = "docbook-xsl-ns";
    sha256 = "1zjfmilm8rmrshxrwnwc2rrqz48hz2jg7vzgpb79z6vz2mlgi4fm";
  };

}
