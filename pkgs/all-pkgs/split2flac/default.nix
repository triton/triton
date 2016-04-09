{ stdenv
, fetchFromGitHub
, makeWrapper

#, aacgain
, cuetools
, enca
, faac
, flac
, gawk
, imagemagick
, lame
, mac
#, mp3gain
, mp4v2
, python2Packages
, shntool
#, ttaenc
, vorbis-tools
#, vorbisgain
, wavpack

# iconv?
}:

stdenv.mkDerivation rec {
  name = "split2flac-${version}";
  version = "122";

  src = fetchFromGitHub {
    owner = "ftrvxmtrx";
    repo = "split2flac";
    rev = version;
    sha256 = "163b757cb6efa69c1d731484bb9fe701c65859b62f24072ef14aedbc2343bce4";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  postPatch =
    /* split2flac uses $0 to determine what format to convert to, but
       makeWrapper renames the file breaking the expected behavior */ ''
      sed -i split2flac \
        -e "s/\''${0##\*split2}/\''${SPLIT2FLAC_CALLER##\*split2}/"
    '';

  doConfigure = false;

  doBuild = false;

  installPhase = ''
    install -D -m755 -v 'split2flac' "$out/bin/split2flac"
    ln -sv $out/bin/split2flac $out/bin/split2m4a
    ln -sv $out/bin/split2flac $out/bin/split2mp3
    ln -sv $out/bin/split2flac $out/bin/split2ogg
    ln -sv $out/bin/split2flac $out/bin/split2wav

    install -D -m644 -v 'split2flac-bash-completion.sh' \
      "$out/share/bash-completion/split2flac-bash-completion.sh"
  '';

  preFixup = ''
    wrapProgram $out/bin/split2flac \
      --set 'SPLIT2FLAC_CALLER' "\$0" \
      --prefix 'PATH' : "${cuetools}/bin" \
      --prefix 'PATH' : "${enca}/bin" \
      --prefix 'PATH' : "${faac}/bin" \
      --prefix 'PATH' : "${flac}/bin" \
      --prefix 'PATH' : "${gawk}/bin" \
      --prefix 'PATH' : "${imagemagick}/bin" \
      --prefix 'PATH' : "${lame}/bin" \
      --prefix 'PATH' : "${mac}/bin" \
      --prefix 'PATH' : "${mp4v2}/bin" \
      --prefix 'PATH' : "${python2Packages.mutagen}/bin" \
      --prefix 'PATH' : "${shntool}/bin" \
      --prefix 'PATH' : "${vorbis-tools}/bin" \
      --prefix 'PATH' : "${wavpack}/bin"
  '';

  meta = with stdenv.lib; {
    description = "Split flac/ape/wv/wav using cue sheet into separate tracks";
    homepage = https://github.com/ftrvxmtrx/split2flac;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}