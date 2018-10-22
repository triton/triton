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
  version = "1.8.24";

  tarballUrls = version: [
    "https://pcsclite.apdu.fr/files/pcsc-lite-${version}.tar.bz2"
  ];

  inherit (stdenv.lib)
    optionals
    optionalString;
in
stdenv.mkDerivation rec {
  name = "${if libOnly then "lib" else ""}pcsc-lite-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmaUHWFuu8kxP9wNNCdW1xrDD4zifu6qFSeb8cXbYWMUGE";
    hashOutput = false;
    sha256 = "b81864fa6a5ec776639c02ae89998955f7702a8d10e8b8f70023c5a599d97568";
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
    "--disable-libsystemd"
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
      urls = tarballUrls "1.8.24";
      inherit (src)
        outputHashAlgo;
      outputHash = "b81864fa6a5ec776639c02ae89998955f7702a8d10e8b8f70023c5a599d97568";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") urls;
        pgpKeyFingerprint = "F5E1 1B9F FE91 1146 F41D  953D 78A1 B4DF E8F9 C57E";
      };
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
