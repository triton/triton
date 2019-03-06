{ stdenv
, elfutils
, fetchFromGitHub
, fetchTritonPatch
, fetchurl

, kernel ? null

, channel
, type
}:

let
  inherit (stdenv.lib)
    any
    optionals
    optionalString
    versionOlder;

  buildKernel = any (n: n == type) [ "kernel" "all" ];
  buildUser = any (n: n == type) [ "user" "all" ];

  source = (import ./sources.nix)."${channel}";

  version = if source ? version then source.version else source.date;
in

assert any (n: n == type) [ "kernel" "user" "all" ];
assert buildKernel -> kernel != null;

assert buildKernel && !(kernel.isCompatibleVersion source.maxLinuxVersion "0") ->
  throw ("The '${channel}' SPL channel is only supported on Linux kernel "
    + "channels less than or equal to ${source.maxLinuxVersion}");

stdenv.mkDerivation rec {
  name = "spl-${type}-${version}${optionalString buildKernel "-${kernel.version}"}";

  src = fetchurl {
    url = "https://github.com/zfsonlinux/zfs/releases/download/zfs-${version}/spl-${version}.tar.gz";
    inherit (source) sha256;
  };

  nativeBuildInputs = optionals buildKernel [
    elfutils
  ];

  patches = [
    (fetchTritonPatch {
      rev = "933b930a0663740427562d95e4edcf1f3ca328c1";
      file = "s/spl/0001-Fix-install-paths.patch";
      sha256 = "ac46656b3f4fcbd7fe93f71567dc53bca431ac2e84aff85a56a377b232e39580";
    })
    (fetchTritonPatch {
      rev = "933b930a0663740427562d95e4edcf1f3ca328c1";
      file = "s/spl/0002-Fix-paths.patch";
      sha256 = "7bf4b140e944664648832bb48d69a56200abfe03bad3d65fc3d1a371d32dad0d";
    })
  ];

  configureFlags = [
    "--with-config=${type}"
  ] ++ optionals buildKernel [
    "--with-linux=${kernel.dev}/lib/modules/${kernel.modDirVersion}/source"
    "--with-linux-obj=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  # Fix build impurities
  preFixup = ''
    find "$out" -name Module.symvers -exec sed -i "s,$NIX_BUILD_TOP,/no-such-path,g" {} \;
  '';

  # We don't want these compiler security features / optimizations
  # when we are building kernel modules
  optFlags = !buildKernel;
  pie = !buildKernel;
  fpic = !buildKernel;
  noStrictOverflow = !buildKernel;
  fortifySource = !buildKernel;
  stackProtector = !buildKernel;
  optimize = !buildKernel;

  passthru = {
    inherit (source) maxLinuxVersion;
    inherit channel;
    buildType = type;
  };

  allowedReferences = if buildKernel then [ ] else null;

  meta = with stdenv.lib; {
    description = "Kernel module driver for solaris porting layer (needed by in-kernel zfs)";
    homepage = http://zfsonlinux.org/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
