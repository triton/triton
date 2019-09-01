{ stdenv
, fetchTritonPatch
, fetchurl

, dbus
, gmp
, libidn2
, libnetfilter_conntrack
, nettle
}:

let
  copts = stdenv.lib.concatStringsSep " " [
    "-DHAVE_LIBIDN2"
    "-DHAVE_DNSSEC"
    "-DHAVE_DBUS"
    "-DHAVE_CONNTRACK"
  ];
in
stdenv.mkDerivation rec {
  name = "dnsmasq-2.80";

  src = fetchurl {
    url = "http://www.thekelleys.org.uk/dnsmasq/${name}.tar.xz";
    multihash = "QmPekN49v1WgC77JZZbgcbZgtZWiaq8xB4o7afu5ofcVWn";
    hashOutput = false;
    sha256 = "cdaba2785e92665cf090646cba6f94812760b9d7d8c8d0cfb07ac819377a63bb";
  };

  buildInputs = [
    dbus
    gmp
    libidn2
    libnetfilter_conntrack
    nettle
  ];

  patches = [
    (fetchTritonPatch {
      rev = "ad2ae94da66195c1e8883812980c22bd98bf731a";
      file = "d/dnsmasq/nettle-3.5.patch";
      sha256 = "d9e54439eb20ccd99c263d9c80013002fecb60b387fb8fefd787c7958fdb96c6";
    })
  ];

  preBuild = ''
    makeFlagsArray+=(
      "COPTS=${copts}"
      "DESTDIR="
      "BINDIR=$out/bin"
      "MANDIR=$out/man"
      "LOCALEDIR=$out/share/locale"
    )
  '';

  # XXX: Does the systemd service definition really belong here when our NixOS
  # module can create it in Nix-land?
  postInstall = ''
    install -D -m 644 -v trust-anchors.conf \
      $out/share/dnsmasq/trust-anchors.conf
    install -D -m 644 -v dbus/dnsmasq.conf \
      $out/etc/dbus-1/system.d/dnsmasq.conf

    mkdir -p $out/share/dbus-1/system-services
    cat <<END > $out/share/dbus-1/system-services/uk.org.thekelleys.dnsmasq.service
    [D-BUS Service]
    Name=uk.org.thekelleys.dnsmasq
    Exec=$out/bin/dnsmasq -k -1
    User=root
    SystemdService=dnsmasq.service
    END
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprints = [
          "2693 22E7 D925 5916 E039  4DD6 28FC 869A 289B 82B7"
          "D6EA CBD6 EE46 B834 248D  1112 15CD DA6A E191 35A2"
        ];
      };
    };
  };

  meta = with stdenv.lib; {
    description = "An integrated DNS, DHCP and TFTP server for small networks";
    homepage = http://www.thekelleys.org.uk/dnsmasq/doc.html;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
