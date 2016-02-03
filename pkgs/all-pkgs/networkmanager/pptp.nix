{ stdenv, fetchTritonPatch, fetchurl, networkmanager, pptp, ppp, intltool
, pkgconfig, substituteAll, gtk3, libgnome_keyring, networkmanagerapplet
, libsecret, withGnome ? true, dbus_glib }:

stdenv.mkDerivation rec {
  name = "${pname}${if withGnome then "-gnome" else ""}-${version}";
  pname = "NetworkManager-pptp";
  version = networkmanager.version;

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/1.0/${pname}-${version}.tar.xz";
    sha256 = "1gn1f8r32wznk4rsn2lg2slw1ccli00svz0fi4bx0qiylimlbyln";
  };

  buildInputs = [ networkmanager pptp ppp libsecret dbus_glib ]
    ++ stdenv.lib.optionals withGnome [ gtk3 libgnome_keyring
                                        networkmanagerapplet ];

  nativeBuildInputs = [ intltool pkgconfig ];

  configureFlags =
    if withGnome then "--with-gnome --with-gtkver=3" else "--without-gnome";

  postConfigure = "sed 's/-Werror//g' -i Makefile */Makefile";

  patches = [
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "networkmanager/pptp-purity.patch";
      sha256 = "8d3359767c1acb8cf36eff094763b8f9ce0a860e2b20f585e0922ee2c4750c23";
    })
  ];

  meta = {
    description = "PPtP plugin for NetworkManager";
    inherit (networkmanager.meta) maintainers platforms;
  };
}
