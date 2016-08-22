{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "mxml-2.10";

  src = fetchurl {
    url = "http://www.msweet.org/files/project3/${name}.tar.gz";
    md5Confirm = "8804c961a24500a95690ef287d150abe";
    multihash = "QmVB3H25sYwTSgZvMvd8u5fu3dPWz8NpGqAN5ZtDdVaL4a";
    sha256 = "267ff58b64ddc767170d71dab0c729c06f45e1df9a9b6f75180b564f09767891";
  };

  configureFlags = [
    "--enable-threads"
    "--enable-shared"
  ];

  meta = with stdenv.lib; {
    homepage = "https://www.msweet.org/downloads.php?L+Z3";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
