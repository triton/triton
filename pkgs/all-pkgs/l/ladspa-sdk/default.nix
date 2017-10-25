{ stdenv
, fetchTritonPatch
, fetchurl
, lib
}:

let
  version = "1.13";
in
stdenv.mkDerivation rec {
  name = "ladspa-sdk-${version}";

  src = fetchurl {
    # Upstream no longer exists, use gentoo & debain as an upstream
    url = "mirror://gentoo/distfiles/ladspa_sdk_${version}.tgz";
    sha256 = "0srh5n2l63354bc0srcrv58rzjkn4gv8qjqzg8dnq3rs4m7kzvdm";
  };

  postUnpack = ''
    srcRoot="$sourceRoot/src"
  '';

  prePatch = /* Patches expect the actual source root */ ''
    pushd ../
  '';

  patches = [
    (fetchTritonPatch {
      rev = "e2280bc7aebb20c6bb89918bf5e655ffd7375848";
      file = "l/ladspa-sdk/ladspa-sdk-1.13-properbuild.patch";
      sha256 = "a5bc7ec6643d47a8d57e4e27a5934949c55d9b1f8d2c98a60eca99ea558f24ef";
    })
    (fetchTritonPatch {
      rev = "e2280bc7aebb20c6bb89918bf5e655ffd7375848";
      file = "l/ladspa-sdk/ladspa-sdk-1.13-asneeded.patch";
      sha256 = "0fc78bd4035485559147e9468427a27dcfa879cebcebfec92c7d006e9e95afd0";
    })
    (fetchTritonPatch {
      rev = "e2280bc7aebb20c6bb89918bf5e655ffd7375848";
      file = "l/ladspa-sdk/ladspa-sdk-1.13-fbsd.patch";
      sha256 = "97db76bebb56866d006a0667bb3e67de81b2da1933e4c4d479163a992a488ef8";
    })
    (fetchTritonPatch {
      rev = "e2280bc7aebb20c6bb89918bf5e655ffd7375848";
      file = "l/ladspa-sdk/ladspa-sdk-1.13-no-LD.patch";
      sha256 = "6dfdeefac760dcea33d5d4ef9d0a3ec93b6962b65bf96914a0a8d5e60759fe1a";
    })
  ];

  postPatch = ''
    popd
  '';

  preBuild = ''
    makeFlagsArray+=(
      "MKDIR_P=mkdir -p"
      "INSTALL_PLUGINS_DIR=$out/lib/ladspa/"
      "INSTALL_INCLUDE_DIR=$out/include/"
      "INSTALL_BINARY_DIR=$out/bin/"
    )
  '';

  meta = with lib; {
    description = "The Linux Audio Developer's Simple Plugin API";
    homepage = http://www.ladspa.org/ladspa_sdk/overview.html;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
