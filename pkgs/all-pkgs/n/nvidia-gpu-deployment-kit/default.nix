{ stdenv
, fetchurl
}:

# WARNING: this package is fairly incomplete.

let
  inherit (stdenv.lib)
    makeSearchPath
    replaceStrings;

  version = "352.79";

  versionFormatted = replaceStrings ["."] ["_"] version;

  # Only revevant as part of the mirror's url, nothing to do with cuda.
  cudaVersion = "7.5";
in
stdenv.mkDerivation rec {
  name = "nvidia-gpu-deployment-kit-${version}";

  src = fetchurl {
    url = "http://developer.download.nvidia.com/compute/cuda/${cudaVersion}/"
      + "Prod/gdk/gdk_linux_amd64_${versionFormatted}_release.run";
    sha256 = "3fa9d17cd57119d82d4088e5cfbfcad960f12e3384e3e1a7566aeb2441e54ce4";
  };

  buildInputs = [
    stdenv.cc.cc
  ];

  unpackPhase =
    /* This function prints the first 200 lines of the file, then awk's for
       the line with `OLDSKIP=` which contains the line number where the tarball
       begins, then tails to that line and pipes the tarball to the required
       decompression utility (gzip/xz), which interprets the tarball, and
       finally pipes the output to tar to extract the contents. This is
       exactly what the cli commands in the `.run` file do, but there is an
       issue with some versions so it is best to do it manually instead. */ ''
      local skip

      skip="$(awk -F= '{if(NR<=200&&/OLDSKIP=/){print $2;exit}}' "$src")"
      # Make sure skip is an integer
      skip="''${skip//[^0-9]/}"

      [ ! -z "$skip" ] || {
        echo 'skip is null while a value was expected'
        return 1
      }

      tail -n +"$skip" "$src" | gzip -cd | tar xvf -

      srcRoot="$(pwd)"
      export srcRoot
    '';

  nvLibPath = makeSearchPath "lib" buildInputs;

  installPhase = ''
    pushd 'payload/nvml'
      install -D -m644 -v 'include/nvml.h' "$out/include/nvml.h"

      install -D -m644 -v 'lib/libnvidia-ml.so.1' \
        "$out/lib/libnvidia-ml.so.1"
      ln -s "$out/lib/libnvidia-ml.so.1" \
        "$out/lib/libnvidia-ml.so"
      ln -s "$out/lib/libnvidia-ml.so.1" \
        "$out/lib/libnvidia-ml.so.${version}"
    popd
  '';

  preFixup = ''
    patchelf \
      --set-rpath "${nvLibPath}" \
      "$out/lib/libnvidia-ml.so.1"
  '';

  meta = with stdenv.lib; {
    description = "A utility for managing NVIDIA GPUs";
    homepage = https://developer.nvidia.com/gpu-deployment-kit;
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
