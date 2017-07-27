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
  version = "${channel}.3";
in
stdenv.mkDerivation rec {
  name = "faac-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/faac/faac-src/faac-${channel}/${name}.tar.gz";
    sha256 = "cef2897843baf366983ad29f471cd1c4dcc95762b86d283a925514bcc5cf5a3f";
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
