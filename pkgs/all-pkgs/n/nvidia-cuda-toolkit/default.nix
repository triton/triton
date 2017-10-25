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

, channel
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (stdenv.lib)
    elem
    makeSearchPath
    platforms;

  source = (import ./sources.nix { })."${channel}";

  version = channel + "." + source."rev_${targetSystem}";
in
stdenv.mkDerivation rec {
  name = "nvidia-cuda-toolkit-${version}";

  src = fetchurl {
    url = "https://developer.nvidia.com/compute/cuda/${channel}/prod/"
      + "local_installers/cuda_${version}_linux-run";
    insecureProtocolDowngrade = true;
    hashOutput = false;
    sha256 = source."sha256_${targetSystem}";
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

  unpackPhase =
    /* This function prints the first 300 lines of the file, then awk's for
       the line with `OLDSKIP=` which contains the line number where the tarball
       begins, then tails to that line and pipes the tarball to the required
       decompression utility (gzip/xz), which interprets the tarball, and
       finally pipes the output to tar to extract the contents. This is
       exactly what the cli commands in the `.run` file do, but there is an
       issue with some versions so it is best to do it manually instead. */ ''
      runHook 'preUnpack'

      local skip

      # The line you are looking for `OLDSKIP=` is within the first 300 lines of
      # the file, make sure that you aren't grepping/awking/sedding the entire
      # 60,000+ line file for 1 line.
      skip="$(awk -F= '{if(NR<=300&&/OLDSKIP=/){print $2;exit}}' "$src")"
      # Make sure skip is an integer
      skip="''${skip//[^0-9]/}"

      [ ! -z "$skip" ]

      tail -n +"$skip" "$src" | gzip -cd | tar xvf -

      skip="$(awk -F= '{if(NR<=300&&/OLDSKIP=/){print $2;exit}}' ./run_files/cuda-linux64-rel-${version}-*.run)"
      # Make sure skip is an integer
      skip="''${skip//[^0-9]/}"
      tail -n +"$skip" ./run_files/cuda-linux64-rel-${version}-*.run |
        gzip -cd | tar xvf -

      srcRoot="$(pwd)"
      export srcRoot

      local -a RemoveList
      RemoveList=(
        'CUDA_Toolkit_Release_Notes.txt'
        'EULA.txt'
        'InstallUtils.pm'
        'cuda-installer.pl'
        'extras'  # TODO: add cuda-gdb support
        'install-linux.pl'
        'run_files'
        'src'
        'tools'
        'uninstall_cuda.pl'
        'version.txt'
      )
      for i in "''${RemoveList[@]}" ; do
        rm -rvf "$i"
      done

      runHook 'postUnpack'
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
    cp -vR "$srcRoot" "$out"
    rm $out/env-vars

    # Change the #error on GCC > 4.9 to a #warning.
    sed -i $out/include/host_config.h \
      -e 's/#error\(.*unsupported GNU version\)/#warning\1/'
  '';

  dontPatchELF = true;
  dontStrip = true;
  # FIXME
  sourceDateEpochWarn = true;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      md5Url = "http://developer.download.nvidia.com/compute/cuda/${channel}/"
        + "Prod/docs/sidebar/md5sum.txt";
      insecureProtocolDowngrade = true;
    };
  };

  meta = with stdenv.lib; {
    description = "Compiler, libraries, and tools for CUDA gpus";
    homepage = https://developer.nvidia.com/cuda-toolkit;
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
