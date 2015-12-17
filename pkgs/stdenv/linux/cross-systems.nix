let
  platforms = import ../../top-level/platforms.nix;
in
{
  sheevaplug = rec {
    config = "armv5tel-unknown-linux-gnueabi";
    bigEndian = false;
    arch = "arm";
    float = "soft";
    withTLS = true;
    libc = "glibc";
    platform = platforms.sheevaplug;
    openssl.system = "linux-generic32";
  };
  
  raspberrypi = rec {
    config = "armv6l-unknown-linux-gnueabi";  
    bigEndian = false;
    arch = "arm";
    float = "hard";
    fpu = "vfp";
    withTLS = true;
    libc = "glibc";
    platform = platforms.raspberrypi;
    openssl.system = "linux-generic32";
    inherit (platform) gcc;
  };
  
  armv7l-hf-multiplatform = rec {
    config = "armv7l-unknown-linux-gnueabi";  
    bigEndian = false;
    arch = "arm";
    float = "hard";
    fpu = "vfpv3-d16";
    withTLS = true;
    libc = "glibc";
    platform = platforms.armv7l-hf-multiplatform;
    openssl.system = "linux-generic32";
    inherit (platform) gcc;
  };

  armv5tel = sheevaplug;
  armv6l = raspberrypi;
  armv7l = armv7l-hf-multiplatform;
}
