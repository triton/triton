{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "vulkan-headers-1.0.33";

  src = fetchFromGitHub {
    version = 2;
    owner = "KhronosGroup";
    repo = "Vulkan-Docs";
    rev = "6cdc56d0d73ec65f1cd2db2afafe9aad781fc5b7";
    sha256 = "5eea02408893ee25c007822b55982857385a683390d01e81359d0d128695aa3b";
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
