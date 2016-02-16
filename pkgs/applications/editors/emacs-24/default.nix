{ stdenv, fetchurl, ncurses, xlibsWrapper, xorg, Xaw3d
, pkgconfig, gettext, dbus, libpng, libjpeg, libungif
, libtiff, librsvg, texinfo, gconf, libxml2, imagemagick, gnutls
, alsaLib, cairo, acl, gpm
, withX ? true
, gtk3
}:

assert (xorg != null) -> libpng != null;      # probably a bug

let
  toolkit =
    if (gtk3 != null) then "gtk3"
    else "lucid";
in

stdenv.mkDerivation rec {
  name = "emacs-24.5";

  builder = ./builder.sh;

  src = fetchurl {
    url    = "mirror://gnu/emacs/${name}.tar.xz";
    sha256 = "0kn3rzm91qiswi0cql89kbv6mqn27rwsyjfb8xmwy9m5s8fxfiyx";
  };

  postPatch = ''
    sed -i 's|/usr/share/locale|${gettext}/share/locale|g' lisp/international/mule-cmds.el
  '';

  buildInputs =
    [ ncurses gconf libxml2 gnutls alsaLib pkgconfig texinfo acl gpm gettext ]
    ++ stdenv.lib.optional stdenv.isLinux dbus
    ++ stdenv.lib.optionals withX
      [ xlibsWrapper xorg.libXaw Xaw3d xorg.libXpm libpng libjpeg libungif libtiff librsvg xorg.libXft
        imagemagick gconf ]
    ++ [ gtk3 ];

  configureFlags =
    if stdenv.isDarwin
      then [ "--with-ns" "--disable-ns-self-contained" ]
    else if withX
      then [ "--with-x-toolkit=${toolkit}" "--with-xft" ]
      else [ "--with-x=no" "--with-xpm=no" "--with-jpeg=no" "--with-png=no"
             "--with-gif=no" "--with-tiff=no" ];

  postInstall = ''
    mkdir -p $out/share/emacs/site-lisp/
    cp ${./site-start.el} $out/share/emacs/site-lisp/site-start.el
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    description = "GNU Emacs 24, the extensible, customizable text editor";
    homepage    = http://www.gnu.org/software/emacs/;
    license     = licenses.gpl3Plus;
    maintainers = with maintainers; [  ];
    platforms   = platforms.all;

    # So that Exuberant ctags is preferred
    priority = 1;
  };
}
