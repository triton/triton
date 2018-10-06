{ stdenv
, lib
, fetchurl
}:

let
  version = "2018-10-04";
in
stdenv.mkDerivation rec {
  name = "iana-etc-${version}";

  srcs = [
    (fetchurl {
      # 2018-10-04
      url = "https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xml";
      multihash = "QmTv56KqERBXzA6ne2k4umfpmnnN73rbaPa82PNeXGNGp1";
      sha256 = "39cd8578705974d0c9a1eb645c7374b4f72d9ceed82ec3eefc5670121036ca52";
    })
    (fetchurl {
      # 2017-10-13
      url = "https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xml";
      multihash = "QmcND9WWoYMiw8yX2V2J6qNZwikjtMYe2pK57ssXo3DqZk";
      sha256 = "4992fbc5453d0feb48492e6abda96bf9285ff4d2516f6924a0f92f773dc4cea2";
    })
  ];

  unpackPhase = ''
    cp $srcs .
    mv *service-names-port-numbers.xml service-names-port-numbers.xml
    mv *protocol-numbers.xml protocol-numbers.xml
  '';

  buildPhase = ''
    awk '
    BEGIN {
      print "# Internet (IP) protocols"
      print "#"
      print "# Updated from http://www.iana.org/assignments/protocol-numbers and other"
      print "# sources."
      print "# New protocols will be added on request if they have been officially"
      print "# assigned by IANA and are not historical."
      print "# If you need a huge list of used numbers please install the nmap package."
      print ""
      FS="[<>]"
    }

    {
      # Empty all of the value state when we have a new record
      if (/<record/) {
        value = "";
        name = "";
        description = "";
        deprecated = 0;
      }

      # Collect the values for each record
      if (/<value/) {
        value = $3;
      }
      if (/<name/) {
        name = $3;
        if (/deprecated/) {
          deprecated = 1;
        }
      }
      if (/<description/) {
        description = $3;
      }

      # Fix the name so that it doesnt contain spaces
      gsub(/ /, "-", name);

      # When the record is done, print out all of the collected information
      # We dont print deprecated protocols or protocols which have no name as they are unhelpful
      if (/<\/record/ && !deprecated && name != "") {
        printf "%-15s %-3i %-15s # %s\n", tolower(name), value, name, description;
      }
    }
    ' protocol-numbers.xml > protocols

    awk '
    BEGIN {
      print "# Network services, Internet style"
      print "#"
      print "# Note that it is presently the policy of IANA to assign a single well-known"
      print "# port number for both TCP and UDP; hence, officially ports have two entries"
      print "# even if the protocol doesnt support UDP operations."
      print "#"
      print "# Updated from http://www.iana.org/assignments/port-numbers and other"
      print "# sources like http://www.freebsd.org/cgi/cvsweb.cgi/src/etc/services ."
      print "# New ports will be added on request if they have been officially assigned"
      print "# by IANA and used in the real-world or are needed by a debian package."
      print "# If you need a huge list of used numbers please install the nmap package."
      print ""
      FS="[<>]"
    }

    {
      # Empty all of the value state when we have a new record
      if (/<record/) {
        name = "";
        protocol = "";
        description = "";
        number = "";
        unassigned = 0;
      }

      # Collect the values for each record
      if (/<name/) {
        name = $3;
      }
      if (/<description/) {
        description = $3;
        if (/Unassigned/) {
          unassigned = 1;
        }
      }
      if (/<protocol/) {
        protocol = $3;
      }
      if (/<number/) {
        number = $3;
      }

      # When the record is done, print out all of the collected information
      # We dont print unassigned services or services which have no name, port, or protocol as they are unhelpful
      if (/<\/record/ && !unassigned && name != "" && number != "" && protocol != "") {
        printf "%-15s %5s/%-4s # %s\n", name, number, protocol, description;
      }
    }' service-names-port-numbers.xml > services
  '';

  installPhase = ''
    install -Dm644 protocol-numbers.xml "$out/share/iana-etc/protocol-numbers.xml"
    install -Dm644 protocols "$out/etc/protocols"
    install -Dm644 service-names-port-numbers.xml "$out/share/iana-etc/service-names-and-port-numbers.xml"
    install -Dm644 services "$out/etc/services"
  '';

  meta = with stdenv.lib; {
    description = "IANA protocol and port number assignments (/etc/protocols and /etc/services)";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
