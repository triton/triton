{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "vulkan-headers-1.0.30";

  src = fetchFromGitHub {
    version = 2;
    owner = "KhronosGroup";
    repo = "Vulkan-Docs";
    rev = "49adf2575c4495a0488baed80a5e1c94a664394a";
    sha256 = "c7d391717e37a37605465dc37f1c77136d5e4e07ee6e7672ca140109f559251f";
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
