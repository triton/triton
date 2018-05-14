{ stdenv
, autoconf
, automake
, elfutils
, fetchFromGitHub
, fetchTritonPatch
, fetchurl
, libtool

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

  src = if source ? fetchzipVersion then
    fetchFromGitHub {
      owner = "zfsonlinux";
      repo = "spl";
      rev = "${if source ? version then "zfs-${source.version}" else source.rev}";
      inherit (source) sha256;
      version = source.fetchzipVersion;
    }
  else
    fetchurl {
      url = "https://github.com/zfsonlinux/zfs/releases/download/zfs-${version}/spl-${version}.tar.gz";
      inherit (source) sha256;
    };


  nativeBuildInputs = [
    autoconf
    automake
    libtool
  ] ++ optionals buildKernel [
    elfutils
  ];

  patches = [
    (fetchTritonPatch {
      rev = "97be348abfd5d881ce8206e2cb5005b52b6fe9a5";
      file = "s/spl/0001-Fix-install-paths.patch";
      sha256 = "f962c22a1d18d45688dda97d7177ed50adccf47037c9df61bae65becaae02592";
    })
    (fetchTritonPatch {
      rev = "97be348abfd5d881ce8206e2cb5005b52b6fe9a5";
      file = "s/spl/0002-Fix-paths.patch";
      sha256 = "77ee1b103a6144b31d5a8af9ec30e923ff8cef1e98584a3375a1e55d0ba93d41";
    })
  ];

  preConfigure = ''
    ./autogen.sh
  '';

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
