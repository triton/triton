{ stdenv
, fetchurl
, buildPythonPackage
, lib
, makeWrapper

, ffmpeg
#, pandoc
, zip
}:

# Pandoc is required to build the package's man page. Release tarballs
# contain a formatted man page already, though, so it's fine to pass
# "pandoc = null" to this derivation; the man page will still be
# installed. We keep the pandoc argument and build input in place in
# case someone wants to use this derivation to build a Git version of
# the tool that doesn't have the formatted man page included.

let
  inherit (lib)
    optionalString;

  version = "2018.06.25";
in
buildPythonPackage rec {
  name = "youtube-dl-${version}";

  src = fetchurl {
    url = "https://github.com/rg3/youtube-dl/releases/download/"
      + "${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "8e1e939eb3f679ae5f17db67abecec513e1fe78ecb5ae5aaed7b6368cc9e4ba2";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  # Ensure ffmpeg is available in $PATH for post-processing &
  # transcoding support.
  preFixup = optionalString (ffmpeg != null) ''
    wrapProgram $out/bin/youtube-dl \
      --prefix PATH : "${ffmpeg}/bin"
  '';

  # Tests requires network access
  doCheck = false;

  passthru = {
    srcVerification = fetchurl rec {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha512Url = "https://github.com/rg3/youtube-dl/releases/download/"
        + "${version}/SHA2-512SUMS";
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      # Sergey M.
      pgpKeyFingerprint = "ED7F 5BF4 6B3B BED8 1C87  368E 2C39 3E0F 18A9 236D";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "CLI tool to download videos from YouTube.com & other sites";
    homepage = http://rg3.github.io/youtube-dl/;
    license = licenses.publicDomain;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
