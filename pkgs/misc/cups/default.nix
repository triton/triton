{ stdenv, fetchurl, zlib, libjpeg, libpng, libtiff, pam
, dbus, acl, gmp
, libusb, gnutls, avahi, libpaper
}:

let version = "2.1.3"; in

with stdenv.lib;
stdenv.mkDerivation {
  name = "cups-${version}";

  passthru = { inherit version; };

  src = fetchurl {
    url = "https://www.cups.org/software/${version}/cups-${version}-source.tar.bz2";
    sha256 = "1lyl3z01xhg9xb9c8m42398c6h9kw8qr6jwiv8bjdsjab11hv9rn";
  };

  buildInputs = [
    zlib
    libjpeg
    libpng
    libtiff
    libusb
    gnutls
    avahi
    libpaper
    gmp
    pam
    dbus.libs
    acl
  ];

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--with-systemd=\${out}/lib/systemd/system"
    "--enable-raw-printing"
    "--enable-threads"
    "--enable-dbus"
    "--enable-pam"
    "--enable-libusb"
    "--enable-ssl"
    "--enable-avahi"
    "--enable-libpaper"
  ];

  installFlags =
    [ # Don't try to write in /var at build time.
      "CACHEDIR=$(TMPDIR)/dummy"
      "LOGDIR=$(TMPDIR)/dummy"
      "REQUESTS=$(TMPDIR)/dummy"
      "STATEDIR=$(TMPDIR)/dummy"
      # Idem for /etc.
      "PAMDIR=$(out)/etc/pam.d"
      "DBUSDIR=$(out)/etc/dbus-1"
      "XINETD=$(out)/etc/xinetd.d"
      "SERVERROOT=$(out)/etc/cups"
      # Idem for /usr.
      "MENUDIR=$(out)/share/applications"
      "ICONDIR=$(out)/share/icons"
      # Work around a Makefile bug.
      "CUPS_PRIMARY_SYSTEM_GROUP=root"
    ];

  postInstall = ''
      # Delete obsolete stuff that conflicts with cups-filters.
      rm -rf $out/share/cups/banners $out/share/cups/data/testprint

      # Rename systemd files provided by CUPS
      for f in $out/lib/systemd/system/*; do
        substituteInPlace "$f" \
          --replace "org.cups.cupsd" "cups" \
          --replace "org.cups." ""

        if [[ "$f" =~ .*cupsd\..* ]]; then
          mv "$f" "''${f/org\.cups\.cupsd/cups}"
        else
          mv "$f" "''${f/org\.cups\./}"
        fi
      done
      # Use xdg-open when on Linux
      substituteInPlace $out/share/applications/cups.desktop \
        --replace "Exec=htmlview" "Exec=xdg-open"
    '';

  meta = {
    homepage = https://cups.org/;
    description = "A standards-based printing system for UNIX";
    license = licenses.gpl2; # actually LGPL for the library and GPL for the rest
    maintainers = with maintainers; [ urkud simons jgeerds ];
    platforms = platforms.linux;
  };
}
