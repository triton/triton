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
  version = "${majorVersion}.18";

  src = fetchurl {
    url = "mirror://gnome-insecure/sources/gupnp/${majorVersion}/${name}.tar.xz";
    sha256Url = "mirror://gnome-secure/sources/gupnp/${majorVersion}/"
      + "${name}.sha256sum";
    sha256 = "c5e0e11061f8d0ff9c8dccc196f39c45a49c0153c9a72abf6290ab34d1cbb021";
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
