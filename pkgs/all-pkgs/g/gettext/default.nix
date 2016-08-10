{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "gettext-0.19.8.1";

  src = fetchurl {
    url = "mirror://gnu/gettext/${name}.tar.gz";
    sha256 = "ff942af0e438ced4a8b0ea4b0b6e0d6d657157c5e2364de57baa279c1c125c43";
  };

  postPatch = ''
    sed \
      -i gettext-tools/projects/KDE/trigger \
      -i gettext-tools/projects/GNOME/trigger \
      -i gettext-tools/src/project-id \
      -e 's,/bin/pwd,pwd,g'
  '';

  preFixup = ''
    sed -i "$out/bin/gettext.sh" \
      -e "/^  .\?gettext/ s,envsubst,$out/bin/\0,g" \
      -e "/^  .\?gettext/ s,^  ,\0$out/bin/,"
  '';

  meta = with stdenv.lib; {
    description = "Well integrated set of translation tools and documentation";
    homepage = http://www.gnu.org/software/gettext/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
