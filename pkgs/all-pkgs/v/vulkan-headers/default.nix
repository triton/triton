{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "vulkan-headers-1.0.36";

  src = fetchFromGitHub {
    version = 2;
    owner = "KhronosGroup";
    repo = "Vulkan-Docs";
    rev = "7cba8f5d9953986da27010b7cbc6fbcc9f96f880";
    sha256 = "9dc68c7b7ac8f503c4d3ef4e8c4018982116315001b9d0b9635debb02c4e11d2";
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
