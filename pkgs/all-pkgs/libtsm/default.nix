{ stdenv
, fetchurl

, libxkbcommon
}:

stdenv.mkDerivation rec {
  name = "libtsm-3";

  src = fetchurl {
    url = "http://freedesktop.org/software/kmscon/releases/${name}.tar.xz";
    sha256 = "01ygwrsxfii0pngfikgqsb4fxp8n1bbs47l7hck81h9b9bc1ah8i";
  };

  buildInputs = [
    libxkbcommon
  ];

  configureFlags = [
    "--disable-debug"
  ];

  meta = with stdenv.lib; {
    description = "Terminal-emulator State Machine";
    homepage = "http://www.freedesktop.org/wiki/Software/kmscon/libtsm/";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
