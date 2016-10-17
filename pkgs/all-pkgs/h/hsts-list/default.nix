{ stdenv
, fetchgit
, jq
}:

stdenv.mkDerivation {
  name = "hsts-list-2016-10-07";

  src = fetchgit {
    version = 2;
    url = "https://chromium.googlesource.com/chromium/src/net";
    rev = "c3ac5d441a4ffa3419adcacd005e5f8c0ff0d5b5";
    sha256 = "1axpg1z4ynhxb7anjvmqmkxzg81b3ljkz5ch42mwls8lm5c4az7z";
  };

  nativeBuildInputs = [
    jq
  ];

  buildPhase = ''
    cat http/transport_security_state_static.json \
      | awk '{ if (!/^[ ]*\/\//) { print $0; }}' \
      | jq '.' >transport_security_state_static.json

    echo "domain,include_subdomains" >transport_security_state_static.csv
    jq -r '.entries[] | (.name + "," + (.include_subdomains | tostring))' \
      <transport_security_state_static.json >>transport_security_state_static.csv
 '';

  installPhase = ''
    mkdir -p "$out"/share/chromium
    cp -v transport_security_state_static.{json,csv} "$out"/share/chromium
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
