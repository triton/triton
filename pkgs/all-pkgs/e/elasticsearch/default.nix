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
    "5.5" = {
      version = "5.5.2";
      sha1Confirm = "91b3b3c823fafce54609ed5c9075d9cf50b2edff";
      sha256 = "0870e2c0c72e6eda976effa07aa1cdd06a9500302320b5c22ed292ce21665bf1";
    };
    "6.0" = {
      version = "6.0.0-beta2";
      sha1Confirm = "c3f7c1685fc4925a4fac96fa4dfb1706c85acde6";
      sha256 = "0c200154c4980ad6e278d9c9ee9e2ca22d2c501c4c67e6fe748adde31aa36b0e";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "elasticsearch-${source.version}";

  src = fetchurl {
    url = "https://artifacts.elastic.co/downloads/elasticsearch/${name}.tar.gz";
    inherit (source) sha1Confirm sha256;
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    openjdk
    util-linux_full
  ];

  postPatch = optionalString (channel == "5.0") ''
    # ES_HOME defaults to install prefix which is read-only
    sed -i bin/elasticsearch{,-plugin} \
      -e 's,ES_HOME=`dirname "$SCRIPT"`/..,,'
    # Prevent elastic search from loading from impure paths
    sed -i bin/elasticsearch \
      -e '/x$ES_INCLUDE/,+16 d'
    rm -f bin/elasticsearch.in.sh
  '' + optionalString (channel == "6.0") ''
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
