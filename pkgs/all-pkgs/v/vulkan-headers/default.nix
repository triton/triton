{ stdenv
, fetchFromGitHub
, lib
}:

stdenv.mkDerivation rec {
  name = "vulkan-headers-1.0.70";

  src = fetchFromGitHub {
    version = 6;
    owner = "KhronosGroup";
    repo = "Vulkan-Docs";
    rev = "ce60b9c88745ecded74296dfbe69dae7c1fb2e62";
    sha256 = "86d1ae31591f20930591da9604b6987830bd57e8e896dc3fff06f7aab827866b";
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
