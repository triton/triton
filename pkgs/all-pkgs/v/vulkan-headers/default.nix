{ stdenv
, fetchFromGitHub
, lib
}:

stdenv.mkDerivation rec {
  name = "vulkan-headers-1.0.51";

  src = fetchFromGitHub {
    version = 3;
    owner = "KhronosGroup";
    repo = "Vulkan-Docs";
    rev = "1d67e47f1464d5f5e654a405e9a91c7d5441bbb6";
    sha256 = "58bab4fc00f105b4688c67a7cda04b0b40e04084ef04bb67191ef1559ab0bc88";
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
