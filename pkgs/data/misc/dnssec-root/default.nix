{ fetchurl, ldns }:

# This is purposely not versioned to force the user to keep it up to date
fetchurl {
  name = "dnssec-root-2010-07-15";
  url = "https://data.iana.org/root-anchors/root-anchors.xml";
  sha256 = "0higqh4wkpwbv0jnx8r4wgl7zmxzbv58m6pn0zi9yg2mq9i3q6hm";
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
    echo ""

    echo -n "Digest (root-anchors.xml): "
    awk '
    BEGIN { FS = "[<>]"; }
    { if (/<Digest>/) {print $3;} }
    ' $downloadedFile | tee hash
    [ -n "$(cat hash)" ]

    echo -n "Root Key Id (root-anchors.xml): "
    awk '
    BEGIN { FS = "[<>]"; }
    { if (/<KeyTag>/) {print $3;} }
    ' $downloadedFile | tee xml-id
    [ -n "$(cat xml-id)" ]

    echo -n "Root Key Id (Drill): "
    awk '
    BEGIN { getline hash<"hash"; }
    { if (match($0, tolower(hash))) {print $7;} }
    ' drill-out | tee drill-id
    [ -n "$(cat drill-id)" ]
    
    if [ "$(cat xml-id)" != "$(cat drill-id)" ]; then
      echo "Drill and XML Id's don't match" >&2
      exit 1
    fi

    awk '
    BEGIN { getline id<"drill-id"; }
    { if (match($0, "id = " id)) {print $0;} }
    ' drill-out > key-line

    echo ""
    echo -n "##########################"
    echo -n " Matching Key "
    echo -n "##########################"
    echo ""
    cat key-line
    echo -n "##########################"
    echo -n " Matching Key "
    echo -n "##########################"
    echo ""
    echo ""
    echo "This means the key is probably okay since the root-anchors and dns match."

    awk '
    {
      getline id<"xml-id";
      getline hash<"hash";
      print "Domain: " $1;
      print "Id: " id;
      print "Hash: " hash;
      print "Flags: " $5;
      print "Protocol: " $6;
      print "Algorithm: " $7;
      print "Key: " $8;
    }
    ' key-line > icann-root.txt
    install -Dm644 icann-root.txt "$out/share/dnssec/icann-root.txt"
  '';
}
