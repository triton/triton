{ stdenv
, buildPythonPackage
, fetchFromGitHub
, fetchurl
, gettext
, intltool
, isPy3
, lib
, makeWrapper
, python

, adwaita-icon-theme
, atk
, chardet
, gdk-pixbuf
, geoip
, glib
, gobject-introspection
, gnome-themes-standard
, gtk
, librsvg
, libtorrent-rasterbar_1-1_head
, Mako
, pango
, pillow
, pycairo
, pygobject
, pyopenssl
#, python-appindicator
, pyxdg
, rencode
, setproctitle
, simplejson
, six
, shared-mime-info
, slimit
, twisted
, zope-interface

, pytest

, channel
}:

let
  inherit (lib)
    makeSearchPath
    optionals;

  sources = {
    "stable" = {
      version = "2.0.3";
      sha256 = "7e7ae8e6ca2a2bf0d487227cecf81e27332f0b92b567cc2bda38e47d859da891";
    };
    "head" = {
      fetchzipversion = 6;
      version = "2019-06-24";
      rev = "3f9ae337932da550f2623daa6dedd9c3e0e5cfb3";
      sha256 = "43b5e1e25df77a2eede02278545fe37ce66122e5f0a8b393c07db1f9f14eebd8";
    };
  };
  source = sources."${channel}";
in
buildPythonPackage rec {
  name = "deluge-${source.version}";

  src =
    if channel != "head" then
      fetchurl {
        url = "http://download.deluge-torrent.org/source/2.0/"
          + "deluge-${source.version}.tar.xz";
        inherit (source) sha256;
      }
    else
      fetchFromGitHub {
        version = source.fetchzipversion;
        owner = "deluge-torrent";
        repo = "deluge";
        inherit (source) rev sha256;
      };

  nativeBuildInputs = [
    gettext
    intltool
    makeWrapper
  ];

  propagatedBuildInputs = [
    adwaita-icon-theme
    atk
    chardet
    gdk-pixbuf
    geoip
    glib
    gnome-themes-standard
    gobject-introspection
    gtk
    ###librsvg
    libtorrent-rasterbar_1-1_head
    Mako
    pango
    pillow
    pycairo
    pygobject
    pyopenssl
    #python-appindicator
    pyxdg
    rencode
    setproctitle
    simplejson
    six
    twisted
    zope-interface
  ] ++ [
    slimit
  ];

  buildInputs = optionals doCheck [
    pytest
  ];

  postPatch = (
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

  postInstall = ''
    mkdir -pv $out/share/applications
    cp -Rv deluge/ui/data/pixmaps $out/share/
    cp -Rv deluge/ui/data/icons $out/share/
    cp -v deluge/ui/data/share/applications/deluge.desktop \
      $out/share/applications
  '';

  preFixup = ''
    for i in deluge deluge-console deluged deluge-gtk deluge-web; do
      wrapProgram "$out"/bin/"$i" \
        --set 'GDK_PIXBUF_MODULE_FILE' "${gdk-pixbuf.loaders.cache}" \
        --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
        --prefix 'GI_TYPELIB_PATH' : "$GI_TYPELIB_PATH" \
        --prefix 'LD_LIBRARY_PATH' : \
          "${makeSearchPath "lib" propagatedBuildInputs}" \
        --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
        --prefix 'XDG_DATA_DIRS' : "$out/share" \
        --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share" \
        --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
    done
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Urls = map (u: "${u}.sha256") src.urls;
      };
    };
  };

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
