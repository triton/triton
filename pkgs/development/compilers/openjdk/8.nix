{ stdenv, fetchurl, cpio, file, which, unzip, zip, xorg, cups, freetype
, alsa-lib, bootjdk, cacert, perl, liberation_ttf, fontconfig, zlib
, setJavaClassPath
, minimal ? false
, enableInfinality ? true # font rendering patch
}:

let

  /**
   * The JRE libraries are in directories that depend on the CPU.
   */
  architecture =
    if stdenv.system == "i686-linux" then
      "i386"
    else if stdenv.system == "x86_64-linux" then
      "amd64"
    else
      throw "openjdk requires i686-linux or x86_64 linux";

  update = "77";
  build = "03";
  baseurl = "http://hg.openjdk.java.net/jdk8u/jdk8u";
  repover = "jdk8u${update}-b${build}";

  fetchjava = name: sha256: fetchurl {
    name = "${repover}-${name}.tar.gz";
    url = "${baseurl}/${name}/archive/${repover}.tar.gz";
    inherit sha256;
  };

  openjdk8 = stdenv.mkDerivation {
    name = "openjdk-8u${update}b${build}";

    srcs = [
      (fetchjava "" "4de7ac9e083b577c61b861660e1883c8e3d36024860ac95390fe5113cd51aa85")
      (fetchjava "langtools" "40d450dc4a1799a0d913af40b97ad22bd713974f29f2b4bcc4fbfae2c1dc3412")
      (fetchjava "hotspot" "166058d86a5f078094f6de2ba534b28837124bcc7688b72c67dc3b6beb41a013")
      (fetchjava "corba" "8e556b9cb8321a1007894358405365f43a5138e04647436aea2dabd4457a5c11")
      (fetchjava "jdk" "3c0bcc0afda1f4bb27ae8f15ed5ebaafc7ce90e9d304e3cb53e202ac911a8de5")
      (fetchjava "jaxws" "240313419da136cac61293ff867568fd4342faff1d66688af66d4fd0d45047c4")
      (fetchjava "jaxp" "f671cdb170bd50681d1c97051740b69952764d3eda17a5d1523a0a830ab401ab")
      (fetchjava "nashorn" "eab31307c8325823667ed376cee0ebea5cafe90d1bff8eec66457532fddd72a7")
    ];

    sourceRoot = ".";

    outputs = [ "out" "jre" ];

    # Enabling optimizations breaks compilation
    fortifySource = false;
    optimize = false;

    buildInputs = [
      cpio file which unzip zip
      xorg.libX11 xorg.libXt xorg.libXext xorg.libXrender xorg.libXtst
      xorg.libXi xorg.libXinerama xorg.libXcursor xorg.lndir
      cups freetype alsa-lib perl liberation_ttf fontconfig bootjdk zlib
    ];

    prePatch = ''
      ls | grep jdk | grep -v '^jdk8u' | awk -F- '{print $1}' | while read p; do
        mv $p-* $(ls | grep '^jdk8u')/$p
      done
      cd $(ls | grep '^jdk8u')
    '';

    patches = [
      ./fix-java-home-jdk8.patch
      ./read-truststore-from-env-jdk8.patch
      ./currency-date-range-jdk8.patch
    ] ++ (if enableInfinality then [
      ./004_add-fontconfig.patch
      ./005_enable-infinality.patch
    ] else []);

    preConfigure = ''
      chmod +x configure
      substituteInPlace configure --replace /bin/bash "$shell"
      substituteInPlace hotspot/make/linux/adlc_updater --replace /bin/sh "$shell"
    '';

    configureFlags = [
      "--with-freetype=${freetype}"
      "--with-boot-jdk=${bootjdk.home}"
      "--with-update-version=${update}"
      "--with-build-number=${build}"
      "--with-milestone=fcs"
      "--enable-unlimited-crypto"
      "--disable-debug-symbols"
      "--disable-freetype-bundling"
    ] ++ (if minimal then [
      "--disable-headful"
      "--with-zlib=bundled"
      "--with-giflib=bundled"
    ] else [
      "--with-zlib=system"
    ]);

    NIX_LDFLAGS= if minimal then null else "-lfontconfig";

    buildFlags = "all";

    # Explicitly does not support parallel building at all
    parallelBuild = false;
    parallelCheck = false;
    parallelInstall = false;

    installPhase = ''
      mkdir -p $out/lib/openjdk $out/share $jre/lib/openjdk

      cp -av build/*/images/j2sdk-image/* $out/lib/openjdk

      # Move some stuff to top-level.
      mv $out/lib/openjdk/include $out/include
      mv $out/lib/openjdk/man $out/share/man

      # jni.h expects jni_md.h to be in the header search path.
      ln -s $out/include/linux/*_md.h $out/include/

      # Remove some broken manpages.
      rm -rf $out/share/man/ja*

      # Remove crap from the installation.
      rm -rf $out/lib/openjdk/demo $out/lib/openjdk/sample

      # Move the JRE to a separate output and setup fallback fonts
      mv $out/lib/openjdk/jre $jre/lib/openjdk/
      mkdir $out/lib/openjdk/jre
      mkdir -p $jre/lib/openjdk/jre/lib/fonts/fallback
      lndir ${liberation_ttf}/share/fonts/truetype $jre/lib/openjdk/jre/lib/fonts/fallback
      lndir $jre/lib/openjdk/jre $out/lib/openjdk/jre

      rm -rf $out/lib/openjdk/jre/bina
      ln -s $out/lib/openjdk/bin $out/lib/openjdk/jre/bin

      # Make sure cmm/*.pf are not symlinks:
      # https://youtrack.jetbrains.com/issue/IDEA-147272
      rm -rf $out/lib/openjdk/jre/lib/cmm
      ln -s {$jre,$out}/lib/openjdk/jre/lib/cmm

      # Remove duplicate binaries.
      for i in $(cd $out/lib/openjdk/bin && echo *); do
        if [ "$i" = java ]; then continue; fi
        if cmp -s $out/lib/openjdk/bin/$i $jre/lib/openjdk/jre/bin/$i; then
          ln -sfn $jre/lib/openjdk/jre/bin/$i $out/lib/openjdk/bin/$i
        fi
      done

      # Generate certificates.
      pushd $jre/lib/openjdk/jre/lib/security
      rm cacerts
      perl ${./generate-cacerts.pl} $jre/lib/openjdk/jre/bin/keytool ${cacert}/etc/ssl/certs/ca-bundle.crt
      popd

      ln -s $out/lib/openjdk/bin $out/bin
      ln -s $jre/lib/openjdk/jre/bin $jre/bin
    '';

    # FIXME: this is unnecessary once the multiple-outputs branch is merged.
    preFixup = ''
      prefix=$jre stripDirs "$stripDebugList" "''${stripDebugFlags:--S}"
      patchELF $jre
      propagatedNativeBuildInputs+=" $jre"

      # Propagate the setJavaClassPath setup hook from the JRE so that
      # any package that depends on the JRE has $CLASSPATH set up
      # properly.
      mkdir -p $jre/nix-support
      echo -n "${setJavaClassPath}" > $jre/nix-support/propagated-native-build-inputs

      # Set JAVA_HOME automatically.
      mkdir -p $out/nix-support
      cat <<EOF > $out/nix-support/setup-hook
      if [ -z "\$JAVA_HOME" ]; then export JAVA_HOME=$out/lib/openjdk; fi
      EOF
    '';

    postFixup = ''
      # Build the set of output library directories to rpath against
      LIBDIRS=""
      for output in $outputs; do
        LIBDIRS="$(find $(eval echo \$$output) -name \*.so\* -exec dirname {} \; | sort | uniq | tr '\n' ':'):$LIBDIRS"
      done

      # Add the local library paths to remove dependencies on the bootstrap
      for output in $outputs; do
        OUTPUTDIR="$(eval echo \$$output)"
        BINLIBS="$(find $OUTPUTDIR/bin/ -type f; find $OUTPUTDIR -name \*.so\*)"
        echo "$BINLIBS" | while read i; do
          patchelf --set-rpath "$LIBDIRS:$(patchelf --print-rpath "$i")" "$i" || true
          patchelf --shrink-rpath "$i" || true
        done
      done

      # Test to make sure that we don't depend on the bootstrap
      for output in $outputs; do
        if grep -q -r '${bootjdk}' $(eval echo \$$output); then
          echo "Extraneous references to ${bootjdk} detected"
          exit 1
        fi
      done
    '';

    meta = with stdenv.lib; {
      homepage = http://openjdk.java.net/;
      license = licenses.gpl2;
      description = "The open-source Java Development Kit";
      maintainers = with maintainers; [ edwtjo ];
      platforms = platforms.linux;
    };

    passthru = {
      inherit architecture;
      home = "${openjdk8}/lib/openjdk";
    };
  };
in openjdk8
