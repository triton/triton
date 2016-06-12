{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "gettext-0.19.8";

  src = fetchurl {
    url = "mirror://gnu/gettext/${name}.tar.gz";
    sha256 = "3da4f6bd79685648ecf46dab51d66fcdddc156f41ed07e580a696a38ac61d48f";
  };

  postPatch = ''
   substituteInPlace gettext-tools/projects/KDE/trigger --replace "/bin/pwd" pwd
   substituteInPlace gettext-tools/projects/GNOME/trigger --replace "/bin/pwd" pwd
   substituteInPlace gettext-tools/src/project-id --replace "/bin/pwd" pwd
  '';

  outputs = [
    "out"
    "doc"
  ];

  preFixup = ''
    sed -i "$out/bin/gettext.sh" \
      -e "/^  .\?gettext/ s,envsubst,$out/bin/\0,g" \
      -e "/^  .\?gettext/ s,^  ,\0$out/bin/,"
  '';

  meta = {
    description = "Well integrated set of translation tools and documentation";
    homepage = http://www.gnu.org/software/gettext/;
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
