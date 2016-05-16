{ stdenv
, fetchurl

, linux-headers_4_6
, python
}:

stdenv.mkDerivation rec {
  name = "libevdev-1.5.0";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/libevdev/${name}.tar.xz";
    allowHashOutput = false;
    sha256 = "8c80cbc4b0a0b0c347867c6d03a5ef58a64b0dec52d0c725e279226c9ab442fc";
  };

  buildInputs = [
    linux-headers_4_6
    python
  ];

  configureFlags = [
    "--disable-silent"
  ];

  passthru = {
    srcVerified = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "3C2C 43D9 447D 5938 EF45  51EB E23B 7E70 B467 F0BF";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Wrapper library for evdev devices";
    homepage = http://www.freedesktop.org/software/libevdev/doc/latest/index.html;
    license = licenses.mit;
    maintainers = with stdenv.lib; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
