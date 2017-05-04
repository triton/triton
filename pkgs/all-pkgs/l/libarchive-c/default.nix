{ stdenv
, buildPythonPackage
, fetchPyPi

, libarchive
}:

let
  version = "2.7";
in
buildPythonPackage {
  name = "libarchive-c-${version}";

  src = fetchPyPi {
    package = "libarchive-c";
    inherit version;
    sha256 = "56eadbc383c27ec9cf6aad3ead72265e70f80fa474b20944328db38bab762b04";
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
