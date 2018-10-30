{ stdenv
, buildPythonPackage
, fetchgit
, fetchTritonPatch
, fetchurl
, gettext
, intltool
, isPy3
, lib
, makeWrapper
, python

, adwaita-icon-theme
, chardet
, gdk-pixbuf
, geoip
, gnome-themes-standard
, librsvg
, libtorrent-rasterbar_1-1_head
, Mako
, pillow
#, pygame
, pygobject_2
, pygtk
, pyopenssl
#, python-appindicator
, notify-python
, pyxdg
, service-identity
, simplejson
, shared-mime-info
, slimit
, twisted

, atk
, cairo
, pango

, pytest
, zope-interface

, channel
}:

let
  inherit (lib)
    optionals
    optionalString;

  sources = {
    "stable" = {
      version = "1.3.15";
      sha256 = "a96405140e3cbc569e6e056165e289a5e9ec66e036c327f3912c73d049ccf92c";
    };
    "head" = {
      fetchzipversion = 6;
      version = "2018-10-25";
      rev = "9dcd90056d4225f65046fab4ed37a25e9caeda06";
      sha256 = "edb19981eecb0f1e20c641acc3d0f4845441228c761af7a1b9b129c629325acb";
    };
  };
  source = sources."${channel}";
in
buildPythonPackage rec {
  name = "deluge-${source.version}";

  src =
    if channel != "head" then
      fetchurl {
        url = "http://download.deluge-torrent.org/source/deluge-${source.version}.tar.xz";
        inherit (source) sha256;
      }
    else
      fetchgit {
        version = source.fetchzipversion;
        url = "git://git.deluge-torrent.org/deluge";
        branchName = "develop";
        inherit (source) rev sha256;
      };

  nativeBuildInputs = [
    gettext
    intltool
    makeWrapper
  ];

  propagatedBuildInputs = [
    adwaita-icon-theme
    chardet
    geoip
    gnome-themes-standard
    librsvg
    libtorrent-rasterbar_1-1_head
    Mako
    pillow
    #pygame
    pygobject_2
    pygtk
    pyopenssl
    #python-appindicator
    notify-python
    pyxdg
    service-identity
    #setproctitle
    simplejson
    twisted
  ] ++ [
    slimit
  ];

  buildInputs = optionals doCheck [
    pytest
    zope-interface
  ];

  patches = optionals (channel == "stable") [
    # Remove for 1.3.16
    (fetchTritonPatch {
      rev = "fb4f50bb98024562652d4bfd702b660f2ae3cfe4";
      file = "d/deluge/deluge-1.3.15-fix-preferences-dialog.patch";
      sha256 = "01e01364dd41b0dcd69871a973448f50a5c8efb4e13dd456569e21259e1dc06c";
    })
  ];

  postPatch = optionalString (channel == "head") (
    /* Using an invalid version breaks compatibility with some trackers */ ''
      sed -i setup.py \
        -e 's/_version = .*/_version = "${sources.stable.version}"/' # .dev"/'
    '' + /* Format the user-agent string the same as the release versions */ ''
      sed -i deluge/core/core.py \
        -e "s/user_agent = .*/user_agent = 'Deluge {}'.format(DELUGE_VER)/"
    '' + /* Fix incorrect path to build directory */ ''
      sed -i setup.py \
        -e '/js_basedir/ s|self.build_lib, ||'
    ''
  );

  preBuild = ''
    ${python.interpreter} setup.py build
  '';

  postInstall = optionalString (channel == "head") ''
    mkdir -pv $out/share/applications
    cp -Rv deluge/ui/data/pixmaps $out/share/
    cp -Rv deluge/ui/data/icons $out/share/
    cp -v deluge/ui/data/share/applications/deluge.desktop \
      $out/share/applications
  '';

  preFixup = ''
    wrapProgram $out/bin/deluge \
      --set 'GDK_PIXBUF_MODULE_FILE' "${gdk-pixbuf.loaders.cache}" \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS" \
      --run "$DEFAULT_GTK2_RC_FILES"
  '';

  disabled = isPy3;

  doCheck = false;

  meta = with lib; {
    description = "BitTorrent client with a client/server model";
    homepage = http://deluge-torrent.org;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
