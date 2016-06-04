{ stdenv
, buildPythonPackage
, fetchgit
, fetchurl
, pythonPackages

, chardet
, Mako
#, pillow
, pkgs
#, pygame
, pygobject
, pygtk
, pyopenssl
#, python-appindicator
#, notify-python
, pyxdg
, service-identity
, simplejson
, slimit
, twisted

, pytest
}:

let
  inherit (pythonPackages)
    isPy3k;
  inherit (stdenv.lib)
    optionals;
in

buildPythonPackage rec {
  name = "deluge-${version}";
  version = "2016-05-25";

  src = fetchgit {
    url = "git://git.deluge-torrent.org/deluge";
    rev = "7e229ceb2f0bd119f307751bf55106bfec592297";
    branchName = "develop";
    sha256 = "1ai34a1v2c35d0l9cabpp6f5x5acjpjrlnnvplvsw3z637s043jz";
  };

  nativeBuildInputs = [
    pkgs.gettext
    pkgs.intltool
  ];

  propagatedBuildInputs = [
    chardet
    # geoip-database
    Mako
    #pillow
    pkgs.libtorrent-rasterbar_1-0
    pkgs.librsvg
    pkgs.xdg-utils
    #pygame
    pygobject
    pygtk
    pyopenssl
    #python-appindicator
    #notify-python
    pyxdg
    service-identity
    # setproctitle
    simplejson
    twisted
  ] ++ [
    slimit
  ];

  buildInputs = optionals doCheck [
    pytest
  ];

  postPatch = /* Fix version detection */ ''
    sed -i setup.py \
      -e 's/_version = .*/_version = "${version}.dev"/'
  '' + /* Fix incorrect path to build directory */ ''
    sed -i setup.py \
      -e '/js_basedir/ s|self.build_lib, ||'
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