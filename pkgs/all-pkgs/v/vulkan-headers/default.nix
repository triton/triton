{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "vulkan-headers-1.0.25";

  src = fetchFromGitHub {
    version = 1;
    owner = "KhronosGroup";
    repo = "Vulkan-Docs";
    rev = "85184f305afe0f2e9e99cc9525e8ce25c32e74e0";
    sha256 = "8aee8851c41bb7e2a20201ccbf9184dbed29dec3c2408b49221a41d004135eef";
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
