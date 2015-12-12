{ fetchurl, ldns }:

# This is purposely not versioned to force the user to keep it up to date
fetchurl {
  name = "dnssec-root-2010-07-15";
  url = "https://data.iana.org/root-anchors/root-anchors.xml";
  sha256 = "14mlj3pv1nw60nhs289inrm3lqxi780kf0x146h7id2xhin56k3r";
  downloadToTemp = true;
  recursiveHash = true;
  postFetch = ''
    echo ""
    echo -n "##########################"
    echo -n " root-anchors.xml "
    echo -n "##########################"
    echo ""
    cat $downloadedFile
    echo -n "##########################"
    echo -n " root-anchors.xml "
    echo -n "##########################"
    echo ""
    echo ""
    echo -n "##########################"
    echo -n " drill-query "
    echo -n "##########################"
    echo ""
    ${ldns}/bin/drill -z -t -s DNSKEY . | tee drill-out
    echo -n "##########################"
    echo -n " drill-query "
    echo -n "##########################"
    echo ""

    awk '
    BEGIN { FS = "[<>]"; }
    { if (/<Digest>/) {print $3;} }
    ' $downloadedFile > hash
    [ -n "$(cat hash)" ]

    awk '
    BEGIN { FS = "[<>]"; }
    { if (/<DigestType>/) {print $3;} }
    ' $downloadedFile > hash-type
    [ -n "$(cat hash-type)" ]

    awk '
    BEGIN { FS = "[<>]"; }
    { if (/<KeyTag>/) {print $3;} }
    ' $downloadedFile > xml-id
    [ -n "$(cat xml-id)" ]

    awk '
    BEGIN { getline hash<"hash"; }
    { if (match($0, tolower(hash))) {print $7;} }
    ' drill-out > drill-id
    [ -n "$(cat drill-id)" ]
    
    if [ "$(cat xml-id)" != "$(cat drill-id)" ]; then
      echo "Drill and XML Id's don't match" >&2
      exit 1
    fi

    awk '
    BEGIN { getline id<"drill-id"; }
    { if (match($0, "id = " id)) {print $0;} }
    ' drill-out > key-line

    awk '
    {
      getline id<"xml-id";
      getline hash<"hash";
      getline hashtype<"hash-type";
      print "Domain: " $1;
      print "Id: " id;
      print "Hash: " hash;
      print "HashType: " hashtype;
      print "Flags: " $5;
      print "Protocol: " $6;
      print "Algorithm: " $7;
      print "Key: " $8;
    }
    ' key-line > iana-root.txt

    echo ""
    echo -n "##########################"
    echo -n " IANA Root Parsed "
    echo -n "##########################"
    echo ""
    cat iana-root.txt
    echo -n "##########################"
    echo -n " IANA Root Parsed "
    echo -n "##########################"
    echo ""

    echo ""
    echo "The key is probably okay since the root-anchors and dns match."

    install -Dm644 iana-root.txt "$out/share/dnssec/iana-root.txt"
  '';
}
