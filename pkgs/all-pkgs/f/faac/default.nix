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
  version = "${channel}.9.2";
in
stdenv.mkDerivation rec {
  name = "faac-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/faac/faac-src/faac-${channel}/${name}.tar.gz";
    sha256 = "d45f209d837c49dae6deebcdd87b8cc3b04ea290880358faecf5e7737740c771";
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
