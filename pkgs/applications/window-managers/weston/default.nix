{ stdenv, fetchurl, pkgconfig
, cairo, dbus, libdrm, libinput, libjpeg, libunwind, libva, libwebp, libxcb
, libxkbcommon, libXcursor, mesa, mtdev, pam, pango, udev, wayland, x11
, freerdp ? null, vaapi ? null, xwayland ? null
}:

let
  inherit (stdenv.lib) mkEnable mkWith optional optionals;
in

stdenv.mkDerivation rec {
  name = "weston-${version}";
  version = "1.8.0";

  src = fetchurl {
    url = "http://wayland.freedesktop.org/releases/${name}.tar.xz";
    sha256 = "04nkbbdglh0pqznxkdqvak3pc53jmz24d0658bn5r0cf6agycqw9";
  };

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [
    cairo dbus.libs libdrm libinput libjpeg libunwind libva libwebp libxcb
    libxkbcommon libXcursor mesa mtdev pam pango udev wayland x11
    freerdp vaapi xwayland
  ];

  configureFlags = [
    "--enable-x11-compositor"
    "--enable-drm-compositor"
    "--enable-wayland-compositor"
    "--enable-headless-compositor"
    "--enable-fbdev-compositor"
    "--enable-screen-sharing"
    "--enable-clients"
    "--enable-weston-launch"
    "--disable-setuid-install" # prevent install target chowning `weston-launch' as root, which fails
    (mkEnable (freerdp != null)  "rdp-compositor" null)
    (mkEnable (vaapi != null)    "vaapi-recorder" null)
    (mkEnable (xwayland != null) "xwayland"       null)
    (mkWith   (xwayland != null) "xserver-path"   "${xwayland}/bin/Xwayland")
  ];

  meta = with stdenv.lib; {
    description = "Reference implementation of a Wayland compositor";
    homepage = http://wayland.freedesktop.org/;
    license = licenses.mit;
    maintainers = with maintainers; [ codyopel wkennington ];
    platforms = platforms.linux;
  };
}
