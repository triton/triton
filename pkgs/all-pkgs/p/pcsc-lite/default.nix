{ stdenv
, fetchurl
, perl
, python2

, dbus
, libusb
, polkit
, systemd_lib

, libOnly
}:

let
  id = "4216";
  version = "1.8.21";

  tarballUrls = id: version: [
    "https://alioth.debian.org/frs/download.php/file/${id}/pcsc-lite-${version}.tar.bz2"
  ];

  inherit (stdenv.lib)
    optionals
    optionalString;
in
stdenv.mkDerivation rec {
  name = "${if libOnly then "lib" else ""}pcsc-lite-${version}";

  src = fetchurl {
    urls = tarballUrls id version;
    hashOutput = false;
    multihash = "QmabfNsHHEbpxqbzMmDQSXVuVbrU7vopAhojMXPdWsaTyy";
    sha256 = "fe3365eb7d4ce0fe891e2b6d6248351c287435ca502103f1f1431b1710e513ad";
  };

  nativeBuildInputs = optionals (!libOnly) [
    perl
    python2
  ];

  buildInputs = optionals (!libOnly) [
    dbus
    libusb
    polkit
    systemd_lib
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--with-systemdsystemunitdir=$out/etc/systemd/system"
    )
  '';

  configureFlags = [
    # The OS should care on preparing the drivers into this location
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-usbdropdir=/var/lib/pcsc/drivers"
    "--enable-confdir=/etc"
  ] ++ optionals libOnly [
    "--disable-usb"
  ] ++ optionals (!libOnly) [
    "--enable-libudev"
    "--enable-polkit"
  ];

  preBuild = optionalString libOnly ''
    cd src
    echo 'myBuildLibs: $(lib_LTLIBRARIES)' >> Makefile
    echo 'myBuildSources: $(BUILT_SOURCES)' >> Makefile
  '';

  buildFlags = optionals libOnly [
    "myBuildSources"
    "myBuildLibs"
  ];

  preInstall = ''
    installFlagsArray+=("POLICY_DIR=$out/share/polkit-1/actions")
  '';

  installTargets = optionals libOnly [
    "install-libLTLIBRARIES"
    "install-nodistheaderDATA"
    "install-nobase_includeHEADERS"
    "install-pcDATA"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "4216" "1.8.21";
      pgpsigUrls = map (n: "${n}.asc") (tarballUrls "4217" "1.8.21");
      pgpKeyFingerprint = "F5E1 1B9F FE91 1146 F41D  953D 78A1 B4DF E8F9 C57E";
      inherit (src) outputHashAlgo;
      outputHash = "fe3365eb7d4ce0fe891e2b6d6248351c287435ca502103f1f1431b1710e513ad";
    };
  };

  meta = with stdenv.lib; {
    description = "Middleware to access a smart card using SCard API (PC/SC)";
    homepage = http://pcsclite.alioth.debian.org/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
