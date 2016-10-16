{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "vulkan-headers-1.0.31";

  src = fetchFromGitHub {
    version = 2;
    owner = "KhronosGroup";
    repo = "Vulkan-Docs";
    rev = "b97259786d817bfda38a3b0374782949011e51db";
    sha256 = "ba8d21669a17081851cfd067be5fab9c76f2b5c1d4b923457c2f520807d93db7";
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
