{ stdenv
, autoreconfHook
, fetchurl
, lib

# Digital Radio Mondiale
, drmSupport ? false
}:

let
  inherit (lib)
    boolWt;

  channel = "2.8";
  version = "${channel}.3";
in
stdenv.mkDerivation rec {
  name = "faad2-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/faac/faad2-src/faad2-${channel}.0/"
      + "${name}.tar.gz";
    sha256 = "a8a0e6818f436bb6f84f06b29248758b425327bba061428e6bce9522c613c5a7";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  configureFlags = [
    #"--with-xmms"
    "--${boolWt drmSupport}-drm"
    #"--with-mpeg4ip"
  ];

  meta = with lib; {
    description = "An open source MPEG-4 and MPEG-2 AAC decoder";
    homepage = http://www.audiocoding.com/faad2.html;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms   = with platforms;
      x86_64-linux;
  };
}
