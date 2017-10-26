{ stdenv
, buildPythonPackage
, fetchgit
, fetchurl
, gettext
, intltool
, isPy3
, lib
, makeWrapper

, chardet
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
      fetchzipversion = 3;
      version = "2017-07-05";
      rev = "e3f537770f5282b7629e880caa282989c86ebc89";
      sha256 = "3ac11daca86587ca82b7d1a6e6978fd7a0734b5313245b67c96db90d735d1b1b";
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
    chardet
    geoip
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

  postPatch = optionalString (channel == "head") (
    /* Using an invalid version breaks compatibility with some trackers */ ''
      sed -i setup.py \
        -e 's/_version = .*/_version = "${sources.stable.version}"/' # .dev"/'
    '' + /* Format the user-agent string the same as the release versions */ ''
      sed -i deluge/core/core.py \
        -e "s/user_agent = .*/user_agent = 'Deluge {}'.format(deluge_version)/"
    '' + /* Fix incorrect path to build directory */ ''
      sed -i setup.py \
        -e '/js_basedir/ s|self.build_lib, ||'
    ''
  );

  preBuild = ''
    python setup.py build
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
      --set 'GTK2_RC_FILES' '${gnome-themes-standard}/share/themes/Adwaita/gtk-2.0/gtkrc' \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share"
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
