{ stdenv
, buildPythonPackage
, fetchgit
, fetchurl

, pkgs
, pythonPackages
}:

let
  inherit (pythonPackages)
    isPy3k;
in

buildPythonPackage rec {
  name = "deluge-${version}";
  #version = "1.3.12";
  version = "2016-05-18";

  /*src = fetchurl {
    url = "http://download.deluge-torrent.org/source/${name}.tar.bz2";
    sha256 = "565745b2a3f0567fc007dbdfeea2aa96a6bebd7dbdda2ec932a3017c66613c93";
  };*/
  # Remove if 1.3.13 or newer release is ever tagged
  src = fetchgit {
    url = "http://git.deluge-torrent.org/deluge";
    rev = "1a11e085b271d880edde835633d89b1ec4591fa2";
    branchName = "1.3-stable";
    sha256 = "1cq55yiiaq7b3nn4k1kca9y4r6r3kaczll8k3ddw7r22glp6zciz";
  };

  nativeBuildInputs = [
    pkgs.gettext
    pkgs.intltool
  ];

  propagatedBuildInputs = [
  # geoip-database
  # setproctitle
    pkgs.libtorrent-rasterbar_1-0
    pkgs.librsvg
    pkgs.xdg-utils
    pythonPackages.chardet
    pythonPackages.Mako
    #pythonPackages.pillow
    #pythonPackages.pygame
    pythonPackages.pygobject
    pythonPackages.pygtk
    pythonPackages.pyopenssl
    #pythonPackages.python-appindicator
    #pythonPackages.notify-python
    pythonPackages.pyxdg
    pythonPackages.setuptools
    pythonPackages.service-identify
    pythonPackages.simplejson
    pythonPackages.twisted
  ];

  postInstall = ''
    mkdir -pv $out/share/applications
    cp -Rv deluge/data/pixmaps $out/share/
    cp -Rv deluge/data/icons $out/share/
    cp -v deluge/data/share/applications/deluge.desktop $out/share/applications
  '';

  disabled = isPy3k;

  doCheck = true;

  meta = with stdenv.lib; {
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