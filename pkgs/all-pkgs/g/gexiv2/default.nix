{ stdenv
, fetchurl
, lib

, glib
, gobject-introspection
, exiv2
, vala

, channel
}:

# TODO: python bindings

let
  inherit (lib)
    boolEn;

  sources = {
    "0.10" = {
      version = "0.10.8";
      sha256 = "81c528fd1e5e03577acd80fb77798223945f043fd1d4e06920c71202eea90801";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "gexiv2-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gexiv2/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    vala
  ];

  buildInputs = [
    glib
    gobject-introspection
    exiv2
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-Werror"
    "--disable-debug"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-tests"
    "--${boolEn (vala != null)}-vala"
    #"--with-python2-girdir"
    #"--with-python3-girdir"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gexiv2/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "GObject-based wrapper around the Exiv2 library";
    homepage = https://wiki.gnome.org/Projects/gexiv2;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
