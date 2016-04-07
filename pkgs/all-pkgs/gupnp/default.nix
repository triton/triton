{ stdenv
, fetchurl

, glib
, gobject-introspection
, gssdp
, libsoup
, libxml2
, util-linux_lib
, vala
}:

let
  inherit (stdenv.lib)
    enFlag;
in

stdenv.mkDerivation rec {
  name = "gupnp-${version}";
  majorVersion = "0.20";
  version = "${majorVersion}.16";

  src = fetchurl {
    url = "mirror://gnome/sources/gupnp/${majorVersion}/${name}.tar.xz";
    sha256 = "ff1119eff12529c46837e03c742f69dc4fae48d59097d79582d38a383b832602";
  };

  buildInputs = [
    glib
    gobject-introspection
    gssdp
    libsoup
    libxml2
    util-linux_lib
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
      x86_64-linux;
  };
}
