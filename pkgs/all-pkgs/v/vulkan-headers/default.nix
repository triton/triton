{ stdenv
, fetchFromGitHub
, lib
}:

stdenv.mkDerivation rec {
  name = "vulkan-headers-1.0.69";

  src = fetchFromGitHub {
    version = 5;
    owner = "KhronosGroup";
    repo = "Vulkan-Docs";
    rev = "ab08f0951ef1ad9b84db93f971e113c1d9d55609";
    sha256 = "917dc04207c59b4b5f5db7c44677ec03e3e710a6ccfd864ef86ccb0d4c1da7ef";
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
