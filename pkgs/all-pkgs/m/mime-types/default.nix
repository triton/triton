{ stdenv
, fetchurl
, lib
}:

let
  date = "2019-08-10";
  rev = "ac860b672bd8da0c8c0e9e03b3ef62d798b0f87b";
in
stdenv.mkDerivation {
  name = "mime-types-${date}";

  src = fetchurl {
    url = "https://salsa.debian.org/debian/mime-support/raw/${rev}/mime.types";
    multihash = "QmeNVW5u5R182PkZBKextQYz8WquDnacLZHUQJA7ZVUB9K";
    sha256 = "0a764dac9e452844750e9f3551e4e78c152116133de4e6e4e5e8f50eba4e17f3";
  };

  unpackPhase = ''
    true
  '';

  installPhase = ''
    install -D -m644 -v $src "$out"/etc/mime.types
  '';

  meta = with lib; {
    description = "Provides /etc/mime.types file";
    homepage = https://salsa.debian.org/debian/mime-support;
    license = licenses.free;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ powerpc64le-linux
      ++ x86_64-linux;
  };
}
