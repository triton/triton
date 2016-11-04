{ stdenv
, buildPythonPackage
, fetchPyPi

, libarchive
}:

let
  version = "2.5";
in
buildPythonPackage {
  name = "libarchive-c-${version}";

  src = fetchPyPi {
    package = "libarchive-c";
    inherit version;
    sha256 = "98660daa2501d2da51ab6f39893dc24e88916e72b2d80c205641faa5bce66859";
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
