{ stdenv
, buildPythonPackage
, fetchPyPi

, libarchive
}:

let
  version = "2.9";
in
buildPythonPackage {
  name = "libarchive-c-${version}";

  src = fetchPyPi {
    package = "libarchive-c";
    inherit version;
    sha256 = "9919344cec203f5db6596a29b5bc26b07ba9662925a05e24980b84709232ef60";
  };

  postPatch = ''
    grep -r 'libarchive_path' | awk -F: '{print $1}' | sort | uniq | xargs -n 1 -P $NIX_BUILD_CORES \
      sed \
        -e 's,(libarchive_path),("${libarchive}/lib/libarchive.so"),g' \
        -e '/libarchive_path =/d' \
        -i
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
