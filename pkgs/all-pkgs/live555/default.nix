{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "live555-${version}";
  version = "2016.02.09";

  src = fetchurl {
    # upstream doesn't provide a stable URL, use vlc mirror
    url = "https://download.videolan.org/pub/videolan/testing/contrib/live555/"
        + "live.${version}.tar.gz";
    sha256 = "02z2f8z5cy0ajnh9pgar40lsxdknfw5cbyw52138hxnpr6adrvak";
  };

  postPatch =
    /* Remove hardcodec paths */ ''
      sed -i genMakefiles \
        -e 's,/bin/rm,rm,g'
    '' +
    /* Add fPIC support */ ''
      sed -i config.linux \
        -e 's/$(INCLUDES) -I. -O2 -DSOCKLEN_T/$(INCLUDES) -I. -O2 -I. -fPIC -DRTSPCLIENT_SYNCHRONOUS_INTERFACE=1 -DSOCKLEN_T/g' \
    '';

  configureFlags = [
    "linux"
  ];

  makeFlags = [
    "PREFIX=$(out)"
  ];

  configureScript = "./genMakefiles";

  # Not a standard configure script
  dontAddPrefix = true;

  meta = with stdenv.lib; {
    description = "Libraries for RTP/RTCP/RTSP/SIP multimedia streaming";
    homepage = http://www.live555.com/liveMedia/;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
