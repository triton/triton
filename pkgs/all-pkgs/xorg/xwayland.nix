
{ stdenv
, wayland
, libepoxy
, libxslt
, libunwind
, makeWrapper
, xorg
}:

with stdenv.lib;

overrideDerivation xorg.xorgserver (oldAttrs: {

  name = "xwayland-${xorg.xorgserver.name}";
  propagatedNativeBuildInputs = oldAttrs.propagatedNativeBuildInputs
    ++ [wayland libepoxy libxslt makeWrapper libunwind];
  configureFlags = [
    "--disable-docs"
    "--disable-devel-docs"
    "--enable-xwayland"
    "--disable-xorg"
    "--disable-xvfb"
    "--disable-xnest"
    "--disable-xquartz"
    "--disable-xwin"
    "--with-default-font-path="
    "--with-xkb-bin-directory=${xorg.xkbcomp}/bin"
    "--with-xkb-path=${xorg.xkeyboard_config}/etc/X11/xkb"
    "--with-xkb-output=$(out)/share/X11/xkb/compiled"
  ];

  postInstall = ''
    rm -fr $out/share/X11/xkb/compiled
    ln -s /var/tmp $out/share/X11/xkb/compiled
  '';

}) // {
  meta = {
    description = "An X server for interfacing X11 apps with the Wayland protocol";
    homepage = http://wayland.freedesktop.org/xserver.html;
    license = licenses.mit;
    platforms = platforms.linux;
  };
}



