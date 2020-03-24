{ stdenv
, fetchTritonPatch
, fetchurl

, type ? "full"
}:

let
  inherit (stdenv.lib)
    optionalString;
in
stdenv.mkDerivation rec {
  name = "findutils-4.7.0";

  src = fetchurl {
    url = "mirror://gnu/findutils/${name}.tar.xz";
    sha256 = "c5fefbdf9858f7e4feb86f036e1247a54c79fc2d8e4b7064d5aaa1f47dfa789a";
  };

  # We don't want to depend on bootstrap-tools
  ac_cv_path_SORT = "sort";

  postInstall = optionalString (type != "full") ''
    rm -r "$out"/share
  '';

  dontPatchShebangs = true;

  allowedReferences = [
    "out"
  ] ++ stdenv.cc.runtimeLibcLibs;

  meta = with stdenv.lib; {
    description = "GNU Find Utilities, basic directory searching utilities";
    homepage = http://www.gnu.org/software/findutils/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
