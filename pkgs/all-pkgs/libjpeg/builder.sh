source "${stdenv}/setup"

preConfigure() {

  # Workarounds for the ancient libtool shipped by libjpeg.
  ln -svf "${libtool}/bin/libtool" .
  cp -v "${libtool}/share/libtool/config.guess" .
  cp -v "${libtool}/share/libtool/config.sub" .

}

preInstall() {

  mkdir -p "${out}/bin"
  mkdir -p "${out}/lib"
  mkdir -p "${out}/include"
  mkdir -p "${out}/man/man1"

}

patchPhase() {

  for i in "${patches}" ; do
    patch < "${i}"
  done

}

genericBuild
