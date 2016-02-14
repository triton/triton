{ stdenv
#, autoconf
#, automake113x
, fetchTritonPatch
, fetchurl
, gettext

, glib
, gobject-introspection
, gssdp
, gupnp
#, python
#, pythonPackages
}:

with {
  inherit (stdenv.lib)
    enFlag
    optionals;
};

stdenv.mkDerivation rec {
  name = "gupnp-igd-${version}";
  versionMajor = "0.2";
  versionMinor = "4";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gupnp-igd/${versionMajor}/${name}.tar.xz";
    sha256 = "38c4a6d7718d17eac17df95a3a8c337677eda77e58978129ad3182d769c38e44";
  };

  nativeBuildInputs = [
    gettext
  ]/* ++ optionals (python != null) [
    autoconf
    automake113x
  ]*/;

  buildInputs = [
    glib
    gobject-introspection
    gssdp
    gupnp
    #python
    #pythonPackages.pygobject
  ];

  patches = [
    (fetchTritonPatch {
      rev = "ef3e1239166507b0bcfe63661ad6d7c4959a4c3f";
      file = "gupnp-igd/gupnp-igd-0.1.11-disable_static_modules.patch";
      sha256 = "c7a2802e832c27000765f7988025e3c8fe24953224958523e6f3cc739c4d05bd";
    })
  ];

  configureFlags = [
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (enFlag "introspection" (gobject-introspection != null) null)
    # TODO: python support
    #(enFlag "python" (python != null) null)
    "--disable-python"
  ];

  meta = with stdenv.lib; {
    description = "";
    homepage = http://www.gupnp.org/;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
