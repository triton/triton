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

  version = "2016-07-20";
  # Using an invalid version breaks compatibility with some trackers
  versionSpoof = "1.3.999";
in
buildPythonPackage rec {
  name = "deluge-${version}";

  src = fetchgit {
    version = 1;
    url = "git://git.deluge-torrent.org/deluge";
    rev = "9c27ed29ae6faaa7d3de1a53dea02c4ed527e218";
    branchName = "develop";
    sha256 = "11yiwf4pkbzp4ajsi7bjs2cwcm8651b61b6s9gmzxxqis3m0za53";
  };

  nativeBuildInputs = [
    pkgs.gettext
    pkgs.intltool
  ];

  propagatedBuildInputs = [
    chardet
    #geoip-database
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
    #setproctitle
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
      -e 's/_version = .*/_version = "${versionSpoof}"/' # .dev"/'
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
