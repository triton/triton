{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "vulkan-headers-1.0.26";

  src = fetchFromGitHub {
    version = 1;
    owner = "KhronosGroup";
    repo = "Vulkan-Docs";
    rev = "eaea7d27099cf7deca4848f9536c9f41269fbd90";
    sha256 = "78235ba3c61878b7e401317e08957b3210558d9c56846e32d8ff1d8c76506bf0";
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
