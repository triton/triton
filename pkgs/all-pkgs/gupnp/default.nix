{ stdenv
, fetchurl

, glib
, gobject-introspection
, gssdp
, libsoup
, libxml2
, libuuid
, vala
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "gupnp-${version}";
  majorVersion = "0.20";
  version = "${majorVersion}.15";

  src = fetchurl {
    url = "mirror://gnome/sources/gupnp/${majorVersion}/${name}.tar.xz";
    sha256 = "1qlzaz61zv3sr6pmb87wjcvv6fhpwqn2z0vqrb6xz2jv1lnv8ih4";
  };

  buildInputs = [
    glib
    gobject-introspection
    gssdp
    libsoup
    libuuid
    libxml2
    vala
  ];

  configureFlags = [
    "--enable-largefile"
    "--disable-debug"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    #--with-context-manager=[network-manager/connman/unix/linux]
  ];

  postInstall = ''
    ln -sv ${libsoup}/include/libsoup-[0-9].[0-9]+/libsoup $out/include
    ln -sv ${libxml2}/include/*/libxml $out/include
    ln -sv ${gssdp}/include/*/libgssdp $out/include
  '';

  meta = with stdenv.lib; {
    description = "An implementation of the UPnP specification";
    homepage = http://www.gupnp.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
