{ stdenv
, fetchurl
, patchelf
, perl

, alsa-lib
, expat
, fontconfig
, freetype
, glib
, gtk2
, ncurses
, python
, unixODBC
, xorg
, zlib

, channel ? null
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (stdenv.lib)
    elem
    makeSearchPath
    platforms;
  inherit (builtins.getAttr channel (import ./sources.nix))
    rev_PPC64le
    rev_x86_64
    sha256_PPC64le
    sha256_x86_64;

  version =
    if elem targetSystem platforms.x86_64-linux then
      channel + "." + rev_x86_64
    else if elem targetSystem platforms.powerpc64le-linux then
      channel + "." + rev_PPC64le
    else
      null;
  sha256 =
    if elem targetSystem platforms.x86_64-linux then
      sha256_x86_64
    else if elem targetSystem platforms.powerpc64le-linux then
      sha256_PPC64le
    else
      null;
in

assert
  elem targetSystem platforms.x86_64-linux
  || elem targetSystem platforms.powerpc64le-linux;

stdenv.mkDerivation rec {
  name = "nvidia-cuda-toolkit-${version}";

  src = fetchurl {
    url =
      if elem targetSystem platforms.x86_64-linux then
        "http://developer.download.nvidia.com/compute/cuda/${channel}/Prod/"
          + "local_installers/cuda_${version}_linux.run"
      else if elem targetSystem platforms.powerpc64le-linux then
        "http://developer.download.nvidia.com/compute/cuda/${channel}/Prod/"
          + "local_installers/"
          + "cuda-repo-rhel7-7-5-local-${channel}-${rev_PPC64le}.ppc64le.rpm"
      else
        null;
    inherit sha256;
  };

  nativeBuildInputs = [
    perl
  ];

  runtimeDependencies = [
    alsa-lib
    expat
    fontconfig
    freetype
    glib
    gtk2
    ncurses
    python
    unixODBC
    xorg.libX11
    xorg.libXext
    xorg.libXi
    xorg.libXrender
    xorg.libXt
    xorg.libXtst
    zlib
  ];

  rpath = "${makeSearchPath "lib" runtimeDependencies}:${stdenv.cc.cc}/lib64";

  unpackPhase = ''
    sh $src --keep --noexec
    cd pkg/run_files
    sh cuda-linux64-rel-${version}-*.run --keep --noexec
    sh cuda-samples-linux-${version}-*.run --keep --noexec
    cd pkg
  '';

  buildPhase = ''
    find . -type f -executable -exec patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      '{}' \; || true
    find . -type f -exec patchelf \
      --set-rpath $rpath:$out/jre/lib/amd64/jli:$out/lib:$out/lib64:$out/nvvm/lib:$out/nvvm/lib64:$(cat $NIX_CC/nix-support/orig-cc)/lib \
      --force-rpath \
      '{}' \; || true
  '';

  installPhase = ''
    mkdir -pv $out
    perl ./install-linux.pl --prefix="$out"
    rm $out/tools/CUDA_Occupancy_Calculator.xls
    perl ./install-sdk-linux.pl --prefix="$out" --cudaprefix="$out"

    # let's remove the 32-bit libraries, they confuse the lib64->lib mover
    rm -rf $out/lib

    # Fixup path to samples (needed for cuda 6.5 or else nsight will not find them)
    if [ -d "$out"/cuda-samples ]; then
        mv "$out"/cuda-samples "$out"/samples
    fi

    # Change the #error on GCC > 4.9 to a #warning.
    sed -i $out/include/host_config.h -e 's/#error\(.*unsupported GNU version\)/#warning\1/'
  '';

  dontPatchELF = true;
  dontStrip = true;

  meta = with stdenv.lib; {
    description = "Compiler, libraries, and tools for CUDA gpus";
    homepage = https://developer.nvidia.com/cuda-toolkit;
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      powerpc64le-linux
      ++ x86_64-linux;
  };
}
