{ stdenv, fetchurl, audiofile
, openglSupport ? false, mesa ? null
, alsaSupport ? true, alsa-lib
, x11Support ? true, xlibsWrapper, xorg
, pulseaudioSupport ? true, pulseaudio_lib
}:

assert openglSupport -> (mesa != null && x11Support);
assert x11Support -> (xlibsWrapper != null && xorg != null);
assert alsaSupport -> alsa-lib != null;
assert pulseaudioSupport -> pulseaudio_lib != null;

let
  configureFlagsFun = attrs: ''
        --disable-oss --disable-x11-shared
        --disable-pulseaudio-shared --disable-alsa-shared
        ${if alsaSupport then "--with-alsa-prefix=${attrs.alsa-lib}/lib" else ""}
        ${if (!x11Support) then "--without-x" else ""}
      '';
in
stdenv.mkDerivation rec {
  name = "SDL2-2.0.4";

  src = fetchurl {
    url = "http://www.libsdl.org/release/${name}.tar.gz";
    sha256 = "0jqp46mxxbh9lhpx1ih6sp93k752j2smhpc0ad0q4cb3px0famfs";
  };

  buildInputs = [ audiofile ] ++
    stdenv.lib.optionals x11Support [ xlibsWrapper xorg.libXrandr ] ++
    stdenv.lib.optional pulseaudioSupport pulseaudio_lib ++
    stdenv.lib.optional openglSupport mesa ++
    stdenv.lib.optional alsaSupport alsa-lib;

  # https://bugzilla.libsdl.org/show_bug.cgi?id=1431
  dontDisableStatic = true;

  # XXX: By default, SDL wants to dlopen() PulseAudio, in which case
  # we must arrange to add it to its RPATH; however, `patchelf' seems
  # to fail at doing this, hence `--disable-pulseaudio-shared'.
  configureFlags = configureFlagsFun { inherit alsa-lib; };

  postInstall = ''
    rm $out/lib/*.a
  '';

  passthru = {inherit openglSupport;};

  meta = {
    description = "A cross-platform multimedia library";
    homepage = http://www.libsdl.org/;
    license = stdenv.lib.licenses.zlib;
    platforms = stdenv.lib.platforms.all;
    maintainers = [ ];
  };
}
