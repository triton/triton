{ stdenv
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
  name = "dnsmasq-2.78";

  src = fetchurl {
    url = "http://www.thekelleys.org.uk/dnsmasq/${name}.tar.xz";
    multihash = "Qmd1AiL3uzHVSaLuFa5TvZDemaETZqSrb66F7BYDFFnACM";
    hashOutput = false;
    sha256 = "89949f438c74b0c7543f06689c319484bd126cc4b1f8c745c742ab397681252b";
  };

  buildInputs = [
    dbus
    gmp
    libidn2
    libnetfilter_conntrack
    nettle
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
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprints = [
        "2693 22E7 D925 5916 E039  4DD6 28FC 869A 289B 82B7"
        "D6EA CBD6 EE46 B834 248D  1112 15CD DA6A E191 35A2"
      ];
      inherit (src) urls outputHash outputHashAlgo;
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
