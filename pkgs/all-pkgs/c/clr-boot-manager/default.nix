{ stdenv
, fetchurl
, lib
, meson
, ninja

, check
, efivar
, gnu-efi
, util-linux_lib
}:

let
  inherit (lib)
    optionals
    optionalString;

  version = "2.0.0";
in
stdenv.mkDerivation rec {
  name = "clr-boot-manager-${version}";
  
  src = fetchurl {
    url = "https://github.com/clearlinux/clr-boot-manager/releases/download/v${version}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "fc2e99ba00d1d5a84a57a07f7c3a5967d5c885933b86fdc111b0b67de4a9ea71";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  buildInputs = [
    efivar
    gnu-efi
    util-linux_lib
  ] ++ optionals doCheck [
    check
  ];

  postPatch = optionalString (!doCheck) ''
    sed \
      -e 's,^dep_check = .*,dep_check = false,' \
      -e "/subdir('tests')/d" \
      -i meson.build

    grep -r 'with_systemd_system_unit_dir'
  '';

  preConfigure = ''
    mesonFlagsArray+=(
      "-Ddatadir=$out/share"
      "-Dwith-systemd-system-unit-dir=$out/lib/systemd/system"
    )
  '';

  mesonFlags = [
    "-Dwith-kernel-conf-dir=/no-such-path"
    "-Dwith-kernel-vendor-conf-dir=/no-such-path"
    "-Dwith-kernel-namespace=io.wak.triton"
    "-Dwith-vendor-prefix=triton"
    "-Dwith-gnu-efi=${gnu-efi}/include/efi"
    "-Dwith-efi-var=${efivar}/include/efivar"
  ];

  doCheck = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "893AFBD05C0814A02C572749646B4C3749D208F2";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
