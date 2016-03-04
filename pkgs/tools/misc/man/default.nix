{ stdenv, fetchurl, groff, less }:
 
stdenv.mkDerivation rec {
  name = "man-1.6g";

  src = fetchurl {
    urls = [
      "http://primates.ximian.com/~flucifredi/man/${name}.tar.gz"
      "http://pkgs.fedoraproject.org/repo/pkgs/man2html/man-1.6g.tar.gz/ba154d5796928b841c9c69f0ae376660/man-1.6g.tar.gz"
    ];
    sha256 = "17wmp2ahkhl72cvfzshmck22dnq2lbjg0678swihj270yk1vip6c";
  };
  
  buildInputs = [ groff less ];

  preBuild = ''
    makeFlagsArray=(bindir=$out/bin sbindir=$out/sbin libdir=$out/lib mandir=$out/share/man)
  '';

  patches = [
    # Search in "share/man" relative to each path in $PATH (in addition to "man").
    ./share.patch

    # Prefer /etc/man.conf over $out/lib/man.conf.  Man only reads the
    # first file that exists, so this is necessary to allow the
    # builtin config to be overriden.
    ./conf.patch
  ];

  preConfigure = ''
    sed 's/^PREPATH=.*/PREPATH=$PATH/' -i configure
  '';

  postInstall =
    ''
      # Use UTF-8 by default.  Otherwise man won't know how to deal
      # with certain characters.
      substituteInPlace $out/lib/man.conf \
        --replace "nroff -Tlatin1" "nroff" \
        --replace "eqn -Tlatin1" "eqn -Tutf8"

      # Work around a bug in substituteInPlace.  It loses the final
      # newline, and man requires every line in man.conf to be
      # terminated by a newline.
      echo >> $out/lib/man.conf
    '';

  meta = {
    homepage = http://primates.ximian.com/~flucifredi/man/;
    description = "Tool to read online Unix documentation";
  };
}
