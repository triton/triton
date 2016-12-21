{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "vulkan-headers-1.0.38";

  src = fetchFromGitHub {
    version = 2;
    owner = "KhronosGroup";
    repo = "Vulkan-Docs";
    rev = "70b659d28d01a75209d27afbfd764d1ef0d1dcb3";
    sha256 = "11d00582e2ce99fff586c32c4bbe1edc70fe1efb30517c257a5547ce8f5f4834";
  };

  installPhase = ''
    install -D -m 644 -v 'src/vulkan/vulkan.h' \
      "$out/include/vulkan/vulkan.h"
    install -D -m 644 -v 'src/vulkan/vk_platform.h' \
      "$out/include/vulkan/vk_platform.h"
  '';

  meta = with stdenv.lib; {
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
