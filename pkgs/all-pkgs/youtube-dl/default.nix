{ stdenv
, fetchurl
, buildPythonPackage
, makeWrapper

, ffmpeg
#, pandoc
, zip
}:

let
  inherit (stdenv.lib)
    optionalString;
in

# Pandoc is required to build the package's man page. Release tarballs
# contain a formatted man page already, though, so it's fine to pass
# "pandoc = null" to this derivation; the man page will still be
# installed. We keep the pandoc argument and build input in place in
# case someone wants to use this derivation to build a Git version of
# the tool that doesn't have the formatted man page included.

buildPythonPackage rec {
  name = "youtube-dl-${version}";
  version = "2016.06.03";

  src = fetchurl {
    url = "https://github.com/rg3/youtube-dl/releases/download/"
      + "${version}_tmp/${name}.tar.gz";
    sha256 = "29d9eb4eeea9c781010ee6111a8d0dc6469b9974fbd76c6c6d1641f3e8d489e2";
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

  # Requires network
  doCheck = false;

  meta = with stdenv.lib; {
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
