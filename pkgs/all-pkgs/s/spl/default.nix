{ stdenv
, autoconf
, automake
, elfutils
, fetchFromGitHub
, fetchTritonPatch
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

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "spl";
    rev = "${if source ? version then "spl-${source.version}" else source.rev}";
    inherit (source) sha256;
    version = source.fetchzipVersion;
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
  ] ++ optionals buildKernel [
    elfutils
  ];

  patches = optionals (channel != "dev") [
    (fetchTritonPatch {
      rev = "518382a2bbf31f798bf5271105ac4005510f185d";
      file = "s/spl/0001-Fix-constification.patch";
      sha256 = "96345a84fab6c8a989dc85e238887b91c772784121bff0acd500a49951f44dc0";
    })
  ] ++ [
    (fetchTritonPatch {
      rev = "518382a2bbf31f798bf5271105ac4005510f185d";
      file = "s/spl/0002-Fix-install-paths.patch";
      sha256 = "9527962abe004eeed79dd6d69d5edcf503123c0ca8e086736d3aabb9ef17064b";
    })
    (fetchTritonPatch {
      rev = "7556b2c93e25e3861f30a656fe1c6a55c08a07a1";
      file = "s/spl/0003-Fix-paths.patch";
      sha256 = "214357f623fb397c79cc3ab1ea0a0bc833d828277646928e242a50e76eb26755";
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
