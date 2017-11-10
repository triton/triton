{ stdenv
, fetchurl
, lib
, makeWrapper

, openjdk
, util-linux_full

, channel
}:

let
  inherit (lib)
    optionalString;

  sources = {
    "5" = {
      version = "5.6.4";
      sha256 = "1098fc776fae8c74e65f8e17cf2ea244c1d07c4e6711340c9bb9f6df56aa45b0";
    };
    "6" = {
      version = "6.0.0-rc2";
      sha256 = "b128ba3d23854510f05e85ee61a276b40cbfffeb5d31d53bea04496afab37424";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "elasticsearch-${source.version}";

  src = fetchurl {
    url = "https://artifacts.elastic.co/downloads/elasticsearch/${name}.tar.gz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    openjdk
    util-linux_full
  ];

  postPatch = optionalString (channel == "5") ''
    # ES_HOME defaults to install prefix which is read-only
    sed -i bin/elasticsearch{,-plugin} \
      -e 's,ES_HOME=`dirname "$SCRIPT"`/..,,'
    # Prevent elastic search from loading from impure paths
    sed -i bin/elasticsearch \
      -e '/x$ES_INCLUDE/,+16 d'
    rm -f bin/elasticsearch.in.sh
  '' + optionalString (channel == "6") ''
    # 1: ES_HOME defaults to install prefix which is read-only
    # 2: Remove broken code, we hard code the path anyways
    sed -i bin/elasticsearch-env \
      -e '/ES_HOME=`dirname "$SCRIPT"`/d' \
      -e '/basename "$ES_HOME"/,+3 d'
  '';

  configurePhase = ''
    # Remove unused files
    rm -f bin/*.bat
    rm -f bin/*.exe
  '';

  buildPhase = ":";

  installPhase = ''
    mkdir -p $out
    cp -R bin config lib modules $out
  '';

  preFixup = ''
    wrapProgram $out/bin/elasticsearch \
      --prefix 'ES_CLASSPATH' : "$out/lib/*" \
      --prefix 'PATH' : "${util-linux_full}/bin/" \
      --set 'JAVA_HOME' "${openjdk}" \
      --set 'ES_JVM_OPTIONS' "$out/config/jvm.options" \
      --run 'if [ -z "$ES_HOME" ]; then echo "\$ES_HOME not set" >&2; exit 1; fi' \
      --run 'if [ ! -d "$ES_HOME" ]; then echo "$ES_HOME: ES_HOME directory does not exist" >&2; exit 1; fi' \
      --run "ln -sf \"$out\"/{lib,modules} \"\$ES_HOME\""

    wrapProgram $out/bin/elasticsearch-plugin \
      --set JAVA_HOME "${openjdk}"
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha512Url = map (n: "${n}.sha512") src.urls;
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Distributed RESTful search engine built on top of Lucene";
    homepage = https://www.elastic.co/products/elasticsearch;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
