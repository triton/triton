{ stdenv
, fetchFromGitHub
, lib
}:

stdenv.mkDerivation rec {
  name = "vulkan-headers-1.0.60";

  src = fetchFromGitHub {
    version = 3;
    owner = "KhronosGroup";
    repo = "Vulkan-Docs";
    rev = "6aa7d7bd2c447a3f10433ccd3b38a82e2a587eac";
    sha256 = "57932bc709d2b24075d9d6431a0156849f3e55effdf4faeefdbdea378c825da8";
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
