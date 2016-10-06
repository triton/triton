{ stdenv
, buildPythonPackage
, fetchgit
, fetchurl
, gettext
, intltool
, lib
, pythonPackages

, chardet
, geoip
, librsvg
, libtorrent-rasterbar
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
  inherit (pythonPackages)
    isPy3k;
  inherit (lib)
    optionals;

  version = "2016-09-28";
  # Using an invalid version breaks compatibility with some trackers
  versionSpoof = "1.3.13";
in
buildPythonPackage rec {
  name = "deluge-${version}";

  src = fetchgit {
    version = 2;
    url = "git://git.deluge-torrent.org/deluge";
    rev = "aa164cdbcea86db9cd53c680c18a08b161ec6976";
    branchName = "develop";
    sha256 = "10gpj6g0kpgf0bpp6rlw3wnai3i54glvb2kwifxgmd8d072awmd5";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  propagatedBuildInputs = [
    chardet
    geoip
    librsvg
    libtorrent-rasterbar
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
