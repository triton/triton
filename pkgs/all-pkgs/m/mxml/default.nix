{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "mxml-2.9";

  src = fetchurl {
    url = "http://www.msweet.org/files/project3/${name}.tar.gz";
    md5Confirm = "e21cad0f7aacd18f942aa0568a8dee19";
    sha256 = "cded54653c584b24c4a78a7fa1b3b4377d49ac4f451ddf170ebbc8161d85ff92";
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
