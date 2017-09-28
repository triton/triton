{ stdenv
, autoreconfHook
, fetchTritonPatch
, fetchurl
, lib

# Digital Radio Mondiale
, drmSupport ? false
}:

let
  inherit (lib)
    boolEn;

  channel = "1.29";
  version = "${channel}.7.7";
in
stdenv.mkDerivation rec {
  name = "faac-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/faac/faac-src/faac-${channel}/${name}.tar.gz";
    sha256 = "b898fcf55e7b52f964ee62d077f56fe9b3b35650e228f006fbef4ce903b4d731";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  configureFlags = [
    "--${boolEn drmSupport}-drm"
    "--enable-largefile"
  ];

  meta = with lib; {
    description = "Open source MPEG-4 and MPEG-2 AAC encoder";
    homepage = http://www.audiocoding.com/faac.html;
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
