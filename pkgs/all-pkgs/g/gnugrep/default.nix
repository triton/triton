{ stdenv
, fetchurl
, pcre
, perl
}:

stdenv.mkDerivation rec {
  name = "gnugrep-${version}";
  version = "2.25";

  src = fetchurl {
    url = "mirror://gnu/grep/grep-${version}.tar.xz";
    sha256 = "e21e83bac50450e0d0d61a42c154ee0dceaacdbf4f604ef6e79071cb8e596830";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    pcre
  ];

  doCheck = true;

  # Fix reference to sh in bootstrap-tools, and invoke grep via
  # absolute path rather than looking at argv[0].
  postInstall = ''
    rm $out/bin/egrep $out/bin/fgrep
    echo "#! /bin/sh" > $out/bin/egrep
    echo "exec $out/bin/grep -E \"\$@\"" >> $out/bin/egrep
    echo "#! /bin/sh" > $out/bin/fgrep
    echo "exec $out/bin/grep -F \"\$@\"" >> $out/bin/fgrep
    chmod +x $out/bin/egrep $out/bin/fgrep
  '';

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/grep/;
    description = "GNU implementation of the Unix grep command";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
