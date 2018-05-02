{ stdenv
, fetchFromGitHub
, lib
}:

stdenv.mkDerivation rec {
  name = "vulkan-headers-1.0.74";

  src = fetchFromGitHub {
    version = 6;
    owner = "KhronosGroup";
    repo = "Vulkan-Docs";
    rev = "c51545d33f4fd791dc4109d0d338e79b572f6286";
    sha256 = "fc959a9372a29418b728519962933db412ca4f42968107e1932a535167965460";
  };

  configurePhase = "true";

  buildPhase = "true";

  installPhase = ''
    for i in include/vulkan/*; do
      install -D -m 644 -v "$i" \
        "$out"/include/vulkan/"$(basename "$i")"
    done
  '';

  meta = with lib; {
    description = "The Vulkan API Specification";
    homepage = https://github.com/KhronosGroup/Vulkan-Docs;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
