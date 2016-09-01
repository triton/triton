{ stdenv
, fetchurl

, xz
}:

stdenv.mkDerivation rec {
  name = "orc-0.4.26";

  src = fetchurl rec {
    url = "https://gstreamer.freedesktop.org/src/orc/${name}.tar.xz";
    sha256Url = "${url}.sha256sum";
    sha256 = "7d52fa80ef84988359c3434e1eea302d077a08987abdde6905678ebcad4fa649";
  };

  buildInputs = [
    xz
  ];

  postPatch =
    /* Completely disable examples */ ''
      sed -i Makefile.{am,in} \
        -e '/SUBDIRS/ s:examples::'
    '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    #"--enable-backend=all"
    "--enable-Bsymbolic"
  ];

  meta = with stdenv.lib; {
    description = "The Oil Runtime Compiler, a JIT compiler for array operations";
    homepage = http://gstreamer.freedesktop.org/;
    # The source code implementing the Marsenne Twister algorithm is licensed
    # under the 3-clause BSD license. The rest is 2-clause BSD license.
    license = with licenses; [
      bsd2
      bsd3
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
