{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "gettext-0.19.7";

  src = fetchurl {
    url = "mirror://gnu/gettext/${name}.tar.gz";
    sha256 = "0gy2b2aydj8r0sapadnjw8cmb8j2rynj28d5qs1mfa800njd51jk";
  };

  outputs = [ "out" "doc" ];

  patchPhase = ''
   substituteInPlace gettext-tools/projects/KDE/trigger --replace "/bin/pwd" pwd
   substituteInPlace gettext-tools/projects/GNOME/trigger --replace "/bin/pwd" pwd
   substituteInPlace gettext-tools/src/project-id --replace "/bin/pwd" pwd
  '';

  preFixup = ''
    sed -i "$out/bin/gettext.sh" \
      -e "s,^  \([n]\?gettext \),  $out/bin/\1,"
  '';

  meta = {
    description = "Well integrated set of translation tools and documentation";
    homepage = http://www.gnu.org/software/gettext/;
    platforms = stdenv.lib.platforms.all;
  };
}
