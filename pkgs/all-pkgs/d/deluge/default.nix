{ stdenv
, buildPythonPackage
, fetchgit
, fetchurl
, gettext
, intltool
, isPy3k
, lib
, pythonPackages

, chardet
, geoip
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
, slimit
, twisted

, atk
, cairo
, pango

, pytest
, zope-interface
}:

let
  inherit (lib)
    optionals;

  version = "2017-03-01";
  # Using an invalid version breaks compatibility with some trackers
  versionSpoof = "1.3.13";
in
buildPythonPackage rec {
  name = "deluge-${version}";

  src = fetchgit {
    version = 2;
    url = "git://git.deluge-torrent.org/deluge";
    rev = "966678196ed1393629b4705c9b580624704324c3";
    branchName = "develop";
    sha256 = "1be5ba0dee47dcb13bf19a3c66ac2db3d522d5dfc4319ea3b4eaed3d1c127199";
  };

  nativeBuildInputs = [
    gettext
    intltool
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

  postPatch = /* Fix version detection */ ''
    sed -i setup.py \
      -e 's/_version = .*/_version = "${versionSpoof}"/' # .dev"/'
  '' + /* Fix incorrect path to build directory */ ''
    sed -i setup.py \
      -e '/js_basedir/ s|self.build_lib, ||'
  '';

  preBuild = ''
    python setup.py build
  '';

  postInstall = ''
    mkdir -pv $out/share/applications
    cp -Rv deluge/ui/data/pixmaps $out/share/
    cp -Rv deluge/ui/data/icons $out/share/
    cp -v deluge/ui/data/share/applications/deluge.desktop \
      $out/share/applications
  '';

  disabled = isPy3k;

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
