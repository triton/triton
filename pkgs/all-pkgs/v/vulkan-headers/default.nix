{ stdenv
, fetchFromGitHub
, lib
}:

stdenv.mkDerivation rec {
  name = "vulkan-headers-1.0.64";

  src = fetchFromGitHub {
    version = 3;
    owner = "KhronosGroup";
    repo = "Vulkan-Docs";
    rev = "5436521608c40f324b397693f5bb758d666e3f55";
    sha256 = "334a45183a541a92ac32d18b853b174b339a0c0b2d932b30d20ca5f17cc465f7";
  };

  installPhase = ''
    install -D -m 644 -v 'src/vulkan/vulkan.h' \
      "$out/include/vulkan/vulkan.h"
    install -D -m 644 -v 'src/vulkan/vk_platform.h' \
      "$out/include/vulkan/vk_platform.h"
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
