{ stdenv
, autoreconfHook
, fetchFromGitHub

, libva
}:

# Do NOT use cmake, the cmake file is incomplete upstream

let
  inherit (stdenv.lib)
    wtFlag;
in
stdenv.mkDerivation rec {
  name = "mfx_dispatch-2016-03-17";

  src = fetchFromGitHub {
    owner = "lu-zero";
    repo = "mfx_dispatch";
    rev = "7adf2e463149adf6820de745a4d9e5d9a1ba8763";
    sha256 = "59b014c00bd32816209d3f4e563e1d23fd04879a16ad0fad6f27d8abb709daf7";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    libva
  ];

  configureFlags = [
    "--enable-shared"
    (wtFlag "libva_drm" (libva != null) null)
    (wtFlag "libva_x11" (libva != null) null)
  ];

  CXXFLAGS = [
    "-std=c++03"
    "-Werror"
  ];

  meta = with stdenv.lib; {
    description = "Intel media sdk dispatcher";
    homepage = https://github.com/lu-zero/mfx_dispatch;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
