{ stdenv, fetchurl, alsaLib, pkgconfig }:

stdenv.mkDerivation rec {
  name = "portaudio-19-20140130";

  src = fetchurl {
    url = http://www.portaudio.com/archives/pa_stable_v19_20140130.tgz;
    sha256 = "0mwddk4qzybaf85wqfhxqlf0c5im9il8z03rd4n127k8y2jj9q4g";
  };

  buildInputs = [ pkgconfig ]
    ++ stdenv.lib.optional (stdenv.isLinux) alsaLib;

  # not sure why, but all the headers seem to be installed by the make install
  installPhase = ''
    make install

    # fixup .pc file to find alsa library
    sed -i "s|-lasound|-L${alsaLib}/lib -lasound|" "$out/lib/pkgconfig/"*.pc
  '';

  meta = with stdenv.lib; {
    description = "Portable cross-platform Audio API";
    homepage    = http://www.portaudio.com/;
    # Not exactly a bsd license, but alike
    license     = licenses.mit;
    maintainers = with maintainers; [ lovek323 ];
    platforms   = platforms.unix;
  };

  passthru = {
    api_version = 19;
  };
}
