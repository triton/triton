{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "freetype2-infinality-ultimate-2016-04-22";

  src = fetchFromGitHub {
    owner = "bohoomil";
    repo = "fontconfig-ultimate";
    rev = "5e27febebe53db1ea454c015911b7b7b2b1bfe46";
    sha256 = "c6f2036d11aa8ce4f8f0454c305da32e97127857850050709b623c44352ef2fe";
  };

  installPhase = ''
    mkdir -pv $out/share/freetype2-infinality-ultimate

    # The patch naming isn't very consistent so include all patches
    # in the freetype directory.
    find ./freetype -type f -name '*.patch' -maxdepth 1 |
    while read Patch ; do
      install -D -m644 -v "$Patch" \
      "$out/share/freetype2-infinality-ultimate/$(basename "$Patch")"
    done

    if [ -z "$(find "$out/share/freetype2-infinality-ultimate" \
               -type f -maxdepth 1 -name '*.patch')" ] ; then
      echo "Installing patches has failed"
      return 1
    fi
  '';

  meta = with stdenv.lib; {
    description = "Patches to freetype2 for improved font rendering";
    homepage = https://bohoomil.com/;
    license = licenses.mit;
    maintainers = [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
