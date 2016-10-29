{ stdenv
, fetchurl
, ldns
, openssl
}:

# This is purposely not versioned to force the user to keep it up to date
let
  filePath = "share/dnssec/iana-root.txt";

  pkg = fetchurl rec {
    name = "dnssec-root-2010-07-15";
    multihash = "QmQUgFAv46gdDFsgp9N7xCDjHnYewKpEuEgkyqbkD1vjgy";
    sha256 = "14mlj3pv1nw60nhs289inrm3lqxi780kf0x146h7id2xhin56k3r";
    downloadToTemp = true;
    recursiveHash = true;

    postFetch = ''
      if [ "$(openssl ${passthru.srcVerification.outputHashAlgo} -r -hex "$downloadedFile" 2>/dev/null | tail -n 1 | awk '{print $1}')" != "${passthru.srcVerification.outputHash}" ]; then
        echo "Hash does not match the source file" >&2
        exit 1
      fi
      install -Dm644 "$downloadedFile" "$out/${filePath}"
    '';

    passthru = rec {
      srcFile = fetchurl rec {
        failEarly = true;
        url = "https://data.iana.org/root-anchors/root-anchors.xml";
        pgpsigUrl = "https://data.iana.org/root-anchors/root-anchors.asc";
        pgpKeyFingerprint = "2FBB 91BC AAEE 0ABE 1F80  31C7 D1AF BCE0 0F6C 91D2";
        sha256 = "dfb281b771dc854c18d1cff9d2eecaf184cf7a9668606aaa33e8f01bf4b4d8e4";
      };

      srcVerification = stdenv.mkDerivation {
        name = "iana-root.txt";
        outputHash = "56f00d17c194332ab51f9dc524bb0407b487922c8598e8ae1bcf2b1dabd00707";
        outputHashAlgo = "sha256";
        outputHashMode = "flat";

        nativeBuildInputs = [
          openssl
        ];

        buildCommand = ''
          echo ""
          echo -n "##########################"
          echo -n " root-anchors.xml "
          echo -n "##########################"
          echo ""
          cat "${srcFile}"
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
          ' "${srcFile}" > hash
          [ -n "$(cat hash)" ]

          awk '
          BEGIN { FS = "[<>]"; }
          { if (/<DigestType>/) {print $3;} }
          ' "${srcFile}" > hash-type
          [ -n "$(cat hash-type)" ]

          awk '
          BEGIN { FS = "[<>]"; }
          { if (/<KeyTag>/) {print $3;} }
          ' "${srcFile}" > xml-id
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

          install -Dm644 iana-root.txt "$out"
          hash="$(openssl "$outputHashAlgo" -r -hex "$out" | head -n 1 | awk '{print $1}')"
          if [ "$hash" != "$outputHash" ]; then
            str="Got a bad hash:\n"
            str+="  File: $out\n"
            str+="  Hash: $hash\n"
            echo -e -n "$str" >&2
            exit 1
          fi
        '';
      };
    };

    meta = with stdenv.lib; {
      maintainers = with maintainers; [
        wkennington
      ];
      platforms = with platforms;
        x86_64-linux;
    };
};
in pkg // {
  file = "${pkg}/${filePath}";
}
