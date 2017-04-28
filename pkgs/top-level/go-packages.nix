/* This file defines the composition for Go packages. */

{ stdenv
, buildGoPackage
, fetchFromBitbucket
, fetchFromGitHub
, fetchTritonPatch
, fetchzip
, go
, overrides
, pkgs
}:

let
  self = _self // overrides; _self = with self; {

  inherit go buildGoPackage;

  fetchGxPackage = { src, sha256 }: stdenv.mkDerivation {
    name = "gx-src-${src.name}";

    impureEnvVars = [ "IPFS_API" ];

    buildCommand = ''
      if ! [ -f /etc/ssl/certs/ca-certificates.crt ]; then
        echo "Missing /etc/ssl/certs/ca-certificates.crt" >&2
        echo "Please update to a version of nix which supports ssl." >&2
        exit 1
      fi

      start="$(date -u '+%s')"

      unpackDir="$TMPDIR/src"
      mkdir "$unpackDir"
      cd "$unpackDir"
      unpackFile "${src}"
      cd *

      echo "Environment:" >&2
      echo "  IPFS_API: $IPFS_API" >&2

      mtime=$(find . -type f -print0 | xargs -0 -r stat -c '%Y' | sort -n | tail -n 1)
      if [ "$start" -lt "$mtime" ]; then
        str="The newest file is too close to the current date:\n"
        str+="  File: $(date -u -d "@$mtime")\n"
        str+="  Current: $(date -u)\n"
        echo -e "$str" >&2
        exit 1
      fi
      echo -n "Clamping to date: " >&2
      date -d "@$mtime" --utc >&2

      gx --verbose install --global

      echo "Building GX Archive" >&2
      cd "$unpackDir"
      ${src.tar}/bin/tar --sort=name --owner=0 --group=0 --numeric-owner \
        --no-acls --no-selinux --no-xattrs \
        --mode=go=rX,u+rw,a-s \
        --clamp-mtime --mtime=@$mtime \
        -c . | ${src.brotli}/bin/brotli --quality 6 --output "$out"
    '';

    buildInputs = [ gx.bin ];
    outputHashAlgo = "sha256";
    outputHashMode = "flat";
    outputHash = sha256;
    preferLocalBuild = true;
  };

  nameFunc =
    { rev
    , goPackagePath
    , name ? null
    , date ? null
    }:
    let
      name' =
        if name == null then
          baseNameOf goPackagePath
        else
          name;
      version =
        if date != null then
          date
        else if builtins.stringLength rev != 40 then
          rev
        else
          stdenv.lib.strings.substring 0 7 rev;
    in
      "${name'}-${version}";

  buildFromGitHub =
    { rev
    , date ? null
    , owner
    , repo
    , sha256
    , version
    , gxSha256 ? null
    , goPackagePath ? "github.com/${owner}/${repo}"
    , name ? null
    , ...
    } @ args:
    buildGoPackage (args // (let
      name' = nameFunc {
        inherit
          rev
          goPackagePath
          name
          date;
      };
    in {
      inherit rev goPackagePath;
      name = name';
      src = let
        src' = fetchFromGitHub {
          name = name';
          inherit rev owner repo sha256 version;
        };
      in if gxSha256 == null then
        src'
      else
        fetchGxPackage { src = src'; sha256 = gxSha256; };
    }));

  ## OFFICIAL GO PACKAGES

  appengine = buildFromGitHub {
    version = 2;
    rev = "170382fa85b10b94728989dfcf6cc818b335c952";
    owner = "golang";
    repo = "appengine";
    sha256 = "1byg4xqlg3g1j9ms3yb93yspdfa4mp1fn34kb5rp9faslbx1wbas";
    goPackagePath = "google.golang.org/appengine";
    excludedPackages = "aetest";
    propagatedBuildInputs = [
      protobuf
      net
    ];
    postPatch = ''
      find . -name \*_classic.go -delete
      rm internal/main.go
    '';
    date = "2017-04-10";
  };

  crypto = buildFromGitHub {
    version = 2;
    rev = "c7af5bf2638a1164f2eb5467c39c6cffbd13a02e";
    date = "2017-04-25";
    owner    = "golang";
    repo     = "crypto";
    sha256 = "0p72s05fim01yjbk1q1lzqblawz1792grys72qgyssphbax0j90z";
    goPackagePath = "golang.org/x/crypto";
    goPackageAliases = [
      "code.google.com/p/go.crypto"
      "github.com/golang/crypto"
    ];
    buildInputs = [
      net_crypto_lib
      sys
    ];
  };

  debug = buildFromGitHub {
    version = 2;
    rev = "fb508927b491eca48a708e9d000fdb7afa53c32b";
    date = "2016-06-20";
    owner  = "golang";
    repo   = "debug";
    sha256 = "19g7hcsp24z5plbb2d2y5z16h0z0nc4fmf3lx7m3avf60zvwhns9";
    goPackagePath = "golang.org/x/debug";
    excludedPackages = "\\(testdata\\)";
  };

  geo = buildFromGitHub {
    version = 2;
    rev = "d6335c766376e743cb50b2c92e981e3219f405d7";
    owner = "golang";
    repo = "geo";
    sha256 = "0g615g057qqsdn89h1dywj2xr400cj82p17rsfq45qh1slkgvym1";
    date = "2017-04-25";
  };

  glog = buildFromGitHub {
    version = 1;
    rev = "23def4e6c14b4da8ac2ed8007337bc5eb5007998";
    date = "2016-01-25";
    owner  = "golang";
    repo   = "glog";
    sha256 = "0wj30z2r6w1zdbsi8d14cx103x13jszlqkvdhhanpglqr22mxpy0";
  };

  net = buildFromGitHub {
    version = 2;
    rev = "da118f7b8e5954f39d0d2130ab35d4bf0e3cb344";
    date = "2017-04-24";
    owner  = "golang";
    repo   = "net";
    sha256 = "1c1qhh55i9br7c8ka3qqqpmdixb52wyajch88lvjackk4crkhqy9";
    goPackagePath = "golang.org/x/net";
    goPackageAliases = [
      "github.com/hashicorp/go.net"
      "github.com/golang/net"
    ];
    excludedPackages = "h2demo";
    propagatedBuildInputs = [
      text
      crypto
    ];
  };

  net_crypto_lib = buildFromGitHub {
    inherit (net) rev date owner repo sha256 version goPackagePath;
    subPackages = [
      "context"
    ];
  };

  oauth2 = buildFromGitHub {
    version = 2;
    rev = "a6bd8cefa1811bd24b86f8902872e4e8225f74c4";
    date = "2017-04-12";
    owner = "golang";
    repo = "oauth2";
    sha256 = "1yqlhdimg51wvgfcwq1pg8f9qh8ffsiz1jwr8rmah6w2n27fhn55";
    goPackagePath = "golang.org/x/oauth2";
    goPackageAliases = [ "github.com/golang/oauth2" ];
    propagatedBuildInputs = [
      appengine
      google-cloud-go-compute-metadata
      net
    ];
  };


  protobuf = buildFromGitHub {
    version = 2;
    rev = "2bba0603135d7d7f5cb73b2125beeda19c09f4ef";
    date = "2017-03-31";
    owner = "golang";
    repo = "protobuf";
    sha256 = "18w6xwgvd8g9l1gmja4jsgr1l4f7q3v5yh160d42dzns6qzfc059";
    goPackagePath = "github.com/golang/protobuf";
    goPackageAliases = [
      "code.google.com/p/goprotobuf"
    ];
    buildInputs = [
      genproto_protobuf
    ];
  };

  protobuf_genproto = buildFromGitHub {
    inherit (protobuf) version rev date owner repo goPackagePath sha256;
    subPackages = [
      "proto"
      "ptypes/any"
    ];
  };

  snappy = buildFromGitHub {
    version = 2;
    rev = "553a641470496b2327abcac10b36396bd98e45c9";
    date = "2017-02-16";
    owner  = "golang";
    repo   = "snappy";
    sha256 = "1p27dax5jy6isvxmhnssz99pz9mzwcr1wbvdp1m3s6ap0qq708gg";
    goPackageAliases = [
      "code.google.com/p/snappy-go/snappy"
    ];
  };

  sync = buildFromGitHub {
    version = 2;
    rev = "de49d9dcd27d4f764488181bea099dfe6179bcf0";
    date = "2017-04-18";
    owner  = "golang";
    repo   = "sync";
    sha256 = "0g5pxdz62n2kpk68wb7z60q3jddmzvz2bdz3yn21hhalhsg9cm1f";
    goPackagePath = "golang.org/x/sync";
    propagatedBuildInputs = [
      net
    ];
  };

  sys = buildFromGitHub {
    version = 3;
    rev = "9ccfe848b9db8435a24c424abbc07a921adf1df5";
    date = "2017-04-27";
    owner  = "golang";
    repo   = "sys";
    sha256 = "0lxhb9r9yg3d6cnvd88w9bpxww2i2k6ac88s6a7mv9pl5iqqbri5";
    goPackagePath = "golang.org/x/sys";
    goPackageAliases = [
      "github.com/golang/sys"
    ];
  };

  text = buildFromGitHub {
    version = 3;
    rev = "470f45bf29f4147d6fbd7dfd0a02a848e49f5bf4";
    date = "2017-04-27";
    owner = "golang";
    repo = "text";
    sha256 = "0vccx9c47c9nxf06h993hwhgk0z70nls5si8x9r8jhhy918gp8p7";
    goPackagePath = "golang.org/x/text";
    goPackageAliases = [ "github.com/golang/text" ];
    excludedPackages = "cmd";
  };

  time = buildFromGitHub {
    version = 2;
    rev = "8be79e1e0910c292df4e79c241bb7e8f7e725959";
    date = "2017-04-24";
    owner  = "golang";
    repo   = "time";
    sha256 = "1swqcy5a5l03ni8j3v0798q6nnrdw0apy4ii413pnsmk1w81ig7w";
    goPackagePath = "golang.org/x/time";
    propagatedBuildInputs = [
      net
    ];
  };

  tools = buildFromGitHub {
    version = 3;
    rev = "2382e3994d48b1d22acc2c86bcad0a2aff028e32";
    date = "2017-04-28";
    owner = "golang";
    repo = "tools";
    sha256 = "1i8rfq2l6vfdsj358k9fran2h1cc4dr28kncv17s4gw5w9zd9iya";
    goPackagePath = "golang.org/x/tools";
    goPackageAliases = [ "code.google.com/p/go.tools" ];

    preConfigure = ''
      # Make the builtin tools available here
      mkdir -p $bin/bin
      eval $(go env | grep GOTOOLDIR)
      find $GOTOOLDIR -type f | while read x; do
        ln -sv "$x" "$bin/bin"
      done
      export GOTOOLDIR=$bin/bin
    '';

    excludedPackages = "\\("
      + stdenv.lib.concatStringsSep "\\|" ([ "testdata" ] ++ stdenv.lib.optionals (stdenv.lib.versionAtLeast go.meta.branch "1.5") [ "vet" "cover" ])
      + "\\)";

    buildInputs = [
      appengine
      crypto
      net
    ];

    # Do not copy this without a good reason for enabling
    # In this case tools is heavily coupled with go itself and embeds paths.
    allowGoReference = true;

    postPatch = ''
      grep -r '+build appengine' -l | xargs rm
    '';

    # Set GOTOOLDIR for derivations adding this to buildInputs
    postInstall = ''
      mkdir -p $bin/nix-support
      echo "export GOTOOLDIR=$bin/bin" >> $bin/nix-support/setup-hook
    '';
  };


  ## THIRD PARTY

  ace = buildFromGitHub {
    version = 2;
    owner = "yosssi";
    repo = "ace";
    rev = "v0.0.5";
    sha256 = "0i3jfkgwvaz5w1cgz7sqqa7pnpz6hd0dniw2j89yhq6qgb4ikjy0";
    buildInputs = [
      gohtml
    ];
  };

  aeshash = buildFromGitHub {
    version = 2;
    rev = "8ba92803f64b76c91b111633cc0edce13347f0d1";
    owner  = "tildeleb";
    repo   = "aeshash";
    sha256 = "0p1nbk5nx2xhl8kan4bd6lcpmjrh7c60lyy9nf4rafyv2j7qqhnk";
    goPackagePath = "leb.io/aeshash";
    date = "2016-11-30";
    subPackages = [
      "."
    ];
    propagatedBuildInputs = [
      hashland_for_aeshash
    ];
  };

  afero = buildFromGitHub {
    version = 2;
    owner = "spf13";
    repo = "afero";
    rev = "9be650865eab0c12963d8753212f4f9c66cdcf12";
    date = "2017-02-17";
    sha256 = "0xg09gigsv4c57zixvwnhfh2vfbg5banyhp426kbfs57hda697l8";
    propagatedBuildInputs = [
      sftp
      text
    ];
  };

  amber = buildFromGitHub {
    version = 2;
    owner = "eknkc";
    repo = "amber";
    rev = "f0d8fdb67f9f4a2c0d02fb6ce4830b8b6754de10";
    date = "2017-04-15";
    sha256 = "1ryrllxs3zyxla31c6wij3pajgaj5jhk0mi2i51gyfkx1smp6cxc";
  };

  amqp = buildFromGitHub {
    version = 2;
    owner = "streadway";
    repo = "amqp";
    rev = "afe8eee29a74d213b1f3fb2586058157c397da60";
    date = "2017-03-13";
    sha256 = "1pmpmy8miiimibhkmznz17fawhnvkl0l2jnl30aj302l2lshil9d";
  };

  ansi = buildFromGitHub {
    version = 2;
    owner = "mgutz";
    repo = "ansi";
    rev = "9520e82c474b0a04dd04f8a40959027271bab992";
    date = "2017-02-06";
    sha256 = "1180ng6y5b1cnxschbswxaq2cp4yjchhwqjzimspnxj2mh16syhd";
    propagatedBuildInputs = [
      go-colorable
    ];
  };

  ansicolor = buildFromGitHub {
    version = 1;
    date = "2015-11-20";
    rev = "a422bbe96644373c5753384a59d678f7d261ff10";
    owner  = "shiena";
    repo   = "ansicolor";
    sha256 = "1qfq4ax68d7a3ixl60fb8kgyk0qx0mf7rrk562cnkpgzrhkdcm0w";
  };

  asn1-ber = buildFromGitHub {
    version = 2;
    rev = "b144e4fe15d4968eb8d6e33d70761727d124814e";
    owner  = "go-asn1-ber";
    repo   = "asn1-ber";
    sha256 = "1n5x5y71f8g1p63x5dnpj2pj79625j2j3d8swgyrbi845frrskdd";
    goPackageAliases = [
      "github.com/nmcclain/asn1-ber"
      "github.com/vanackere/asn1-ber"
      "gopkg.in/asn1-ber.v1"
    ];
    date = "2016-09-13";
  };

  atomic = buildFromGitHub {
    version = 2;
    owner = "uber-go";
    repo = "atomic";
    rev = "v1.2.0";
    sha256 = "0k6r1x6i8vz2axyf9scmmh39c78mwgw4vv9wa8s9hsna9dmzsgfm";
    goPackagePath = "go.uber.org/atomic";
  };

  auroradnsclient = buildFromGitHub {
    version = 2;
    rev = "v1.0.1";
    owner  = "edeckers";
    repo   = "auroradnsclient";
    sha256 = "0pcjz19aycd01v4v52zbfldhr81rxy6aj7jh1y09issnqr8kgc4h";
    propagatedBuildInputs = [
      logrus
    ];
  };

  aws-sdk-go = buildFromGitHub {
    version = 3;
    rev = "v1.8.17";
    owner  = "aws";
    repo   = "aws-sdk-go";
    sha256 = "08zkm1w1f6pcmi6jxlqwx67x0hls9nc4zpfwx12i9nwgm9gy7anj";
    excludedPackages = "\\(awstesting\\|example\\)";
    buildInputs = [
      tools
    ];
    propagatedBuildInputs = [
      ini
      go-jmespath
      net
    ];
    preBuild = ''
      pushd go/src/$goPackagePath
      make generate
      popd
    '';
  };

  azure-sdk-for-go = buildFromGitHub {
    version = 2;
    date = "2017-04-21";
    rev = "8dd1f3ff407c300cff0a4bfedd969111ca5a7903";
    owner  = "Azure";
    repo   = "azure-sdk-for-go";
    sha256 = "11i0lwr8h1y3jjmwf5ihrw259b5wvadnb63p6pz4kms38ykz23z5";
    excludedPackages = "\\(Gododir\\|storageimportexport\\)";
    buildInputs = [
      crypto
      decimal
      satori_uuid
    ];
    propagatedBuildInputs = [
      go-autorest
    ];
  };

  azure-storage-go = buildFromGitHub {
    version = 2;
    rev = "v0.1.
    nae0";
    owner  = "Azure";
    repo   = "azure-storage-go";
    sha256 = "1p6n6s9xhrbh67k0dkpd2ph598qmnlnaaayq6pdqwrh0q5pgwx6s";
    goPackageAliases = [
      "github.com/Azure/azure-sdk-for-go/storage"
    ];
    propagatedBuildInputs = [
      go-autorest
    ];
  };

  b = buildFromGitHub {
    version = 2;
    date = "2017-04-13";
    rev = "6955404bf550e1eae1bf83121739078b027f4547";
    owner  = "cznic";
    repo   = "b";
    sha256 = "1kr8nh3hknlp50c10hnryh9mbdhqxqpkf7yiz8839wbqdhnnnxzj";
    excludedPackages = "example";
  };

  barcode = buildFromGitHub {
    version = 2;
    owner = "boombuler";
    repo = "barcode";
    rev = "059b33dac2e9f716cf906bc5071ebb42e607228f";
    date = "2017-04-17";
    sha256 = "0rlbykck5zq9rcp2p9k20zqm89hx5mqcv73mci96hyz1z31abqsc";
  };

  bigfft = buildFromGitHub {
    version = 1;
    date = "2013-09-13";
    rev = "a8e77ddfb93284b9d58881f597c820a2875af336";
    owner = "remyoudompheng";
    repo = "bigfft";
    sha256 = "1cj9zyv3shk8n687fb67clwgzlhv47y327180mvga7z741m48hap";
  };

  binary = buildFromGitHub {
    version = 2;
    owner = "alecthomas";
    repo = "binary";
    rev = "ec810c4448fb8161fd00898b18c6f72ec661216a";
    date = "2017-01-11";
    sha256 = "1lpaqcxgd0pgrawn1hfss0mcv7wp1h0xdy5q3w75ydblay9g7ri8";
  };

  binding = buildFromGitHub {
    version = 2;
    date = "2016-12-22";
    rev = "48920167fa152d02f228cfbece7e0f1e452d200a";
    owner = "go-macaron";
    repo = "binding";
    sha256 = "0dnkwgdx9y2dq7x3q9703371c7ph8w3aqr9q64vcrb086lisbj7z";
    buildInputs = [
      com
      compress
      macaron_v1
    ];
  };

  blackfriday = buildFromGitHub {
    version = 2;
    owner = "russross";
    repo = "blackfriday";
    rev = "b253417e1cb644d645a0a3bb1fa5034c8030127c";
    sha256 = "06ippbfd1d0agsggyndxbj2n24fh8rf05hsbn6cwfvnpnamjl1ii";
    propagatedBuildInputs = [
      sanitized-anchor-name
    ];
    date = "2017-04-13";
  };

  blake2b-simd = buildFromGitHub {
    version = 2;
    owner = "minio";
    repo = "blake2b-simd";
    date = "2016-07-23";
    rev = "3f5f724cb5b182a5c278d6d3d55b40e7f8c2efb4";
    sha256 = "5ead55b23a24393a96cb6504b0a64c48812587c4af12527101c3a7c79c2d35e5";
  };

  bolt = buildFromGitHub {
    version = 1;
    rev = "v1.3.0";
    owner  = "boltdb";
    repo   = "bolt";
    sha256 = "1kjbih12cs9x380d5fb0qrx6n63pkfb2j9hnqrr95gz2215pqczp";
    buildInputs = [
      sys
    ];
  };

  btcd = buildFromGitHub {
    version = 2;
    owner = "btcsuite";
    repo = "btcd";
    date = "2017-03-22";
    rev = "4b348c1d33373d672edd83fc576892d0e46686d2";
    sha256 = "1r22j6wm348yagd06inignzx06g5vvrsbyszlz5d6y8z3a4pwgdg";
    subPackages = [
      "btcec"
    ];
  };

  btree = buildFromGitHub {
    version = 2;
    rev = "316fb6d3f031ae8f4d457c6c5186b9e3ded70435";
    owner  = "google";
    repo   = "btree";
    sha256 = "1wjicavprwxpa0rmvc8wz6k0gxl2q4rpsg7ci5hjvkb2j56r4rwk";
    date = "2016-12-17";
  };

  bufio_v1 = buildFromGitHub {
    version = 1;
    date = "2014-06-18";
    rev = "567b2bfa514e796916c4747494d6ff5132a1dfce";
    owner  = "go-bufio";
    repo   = "bufio";
    sha256 = "07dwsbh2c584wrm72hwnqsk22mr936hshsxma2jaxpgpkf6z1f3c";
    goPackagePath = "gopkg.in/bufio.v1";
  };

  bufs = buildFromGitHub {
    version = 1;
    date = "2014-08-18";
    rev = "3dcccbd7064a1689f9c093a988ea11ac00e21f51";
    owner  = "cznic";
    repo   = "bufs";
    sha256 = "0551h2slsb7lg3r6yif65xvf6k8f0izqwyiigpipm3jhlln37c6p";
  };

  cachecontrol = buildFromGitHub {
    version = 2;
    owner = "pquerna";
    repo = "cachecontrol";
    rev = "9299cc36e57c32f83e47ffb3c25d8a3dec10ea0b";
    date = "2017-03-29";
    sha256 = "1mjnxp0k3sr503smgp0bbrfv4x0dghimwyldw5j6f2lihy4bmj04";
  };

  cascadia = buildFromGitHub {
    version = 2;
    date = "2016-12-24";
    rev = "349dd0209470eabd9514242c688c403c0926d266";
    owner  = "andybalholm";
    repo   = "cascadia";
    sha256 = "0xhdlrsvzsv3va4in3iw9v1nz2f6n8zca98mq4swl8zwfdly2jj8";
    propagatedBuildInputs = [
      net
    ];
  };

  cast = buildFromGitHub {
    version = 2;
    owner = "spf13";
    repo = "cast";
    rev = "v1.1.0";
    sha256 = "0b7i6dwk06w710cjcd0wnhgyrf15m344lmhm9jpfhfs678bg7va5";
    buildInputs = [
      jwalterweatherman
    ];
  };

  cbauth = buildFromGitHub {
    version = 1;
    date = "2016-06-09";
    rev = "ae8f8315ad044b86ced2e0be9e3598e9dd94f38e";
    owner = "couchbase";
    repo = "cbauth";
    sha256 = "185c10ab80cn4jxdp915h428lm0r9zf1cqrfsjs71im3w3ankvsn";
  };

  ccache = buildFromGitHub {
    version = 2;
    rev = "v2.0.2";
    owner = "karlseguin";
    repo = "ccache";
    sha256 = "11zg85f5v89dfqy1s5xs42cs56sxdqs768l9wx73yksxqkidddbh";
  };

  certificate-transparency = buildFromGitHub {
    version = 2;
    owner = "google";
    repo = "certificate-transparency";
    rev = "173728300b695a5336f65f4dfb6645ad1b1665e2";
    date = "2017-02-24";
    sha256 = "73627100e0e5874e268903118a4a7852ece1bcb78a18cfc99136cacd850deaa5";
    propagatedBuildInputs = [
      go-sqlite3
      net
      ratelimit
    ];
  };

  chalk = buildFromGitHub {
    version = 2;
    rev = "22c06c80ed312dcb6e1cf394f9634aa2c4676e22";
    owner  = "ttacon";
    repo   = "chalk";
    sha256 = "0s5ffh4cilfg77bfxabr5b07sllic4xhbnz5ck68phys5jq9xhfs";
    date = "2016-06-26";
  };

  check = buildFromGitHub {
    version = 2;
    date = "2016-12-08";
    rev = "20d25e2804050c1cd24a7eea1e7a6447dd0e74ec";
    owner = "go-check";
    repo = "check";
    goPackagePath = "gopkg.in/check.v1";
    goPackageAliases = [
      "github.com/go-check/check"
    ];
    sha256 = "003qj5rpr27923bjvgd3mbgack3blw0m4izrq9plpxkha1glylz3";
  };

  circbuf = buildFromGitHub {
    version = 1;
    date = "2015-08-26";
    rev = "bbbad097214e2918d8543d5201d12bfd7bca254d";
    owner  = "armon";
    repo   = "circbuf";
    sha256 = "0wgpmzh0ga2kh51r214jjhaqhpqr9l2k6p0xhy5a006qypk5fh2m";
  };

  circonus-gometrics = buildFromGitHub {
    version = 2;
    rev = "v0.1.0";
    owner  = "circonus-labs";
    repo   = "circonus-gometrics";
    sha256 = "1hkpsargcvzj21rw5ccf9sckzdbi2n6nqqpbrxsi5xmdmch5868g";
    propagatedBuildInputs = [
      circonusllhist
      go-retryablehttp
    ];
  };

  circonusllhist = buildFromGitHub {
    version = 2;
    date = "2016-11-21";
    rev = "7d649b46cdc2cd2ed102d350688a75a4fd7778c6";
    owner  = "circonus-labs";
    repo   = "circonusllhist";
    sha256 = "0hp4s4zvkwnd3q6s06mhwxi8hhdhcpsp2911qkrq4m8r670xhzc1";
  };

  cli_minio = buildFromGitHub {
    version = 2;
    owner = "minio";
    repo = "cli";
    rev = "v1.3.0";
    sha256 = "08z1g5g3f07inpgyb93ip037f4y1cnhsm2wvg63qnnnry9chwy36";
    buildInputs = [
      elastic_v5
      toml
      urfave_cli
      yaml_v2
    ];
  };

  AudriusButkevicius_cli = buildFromGitHub {
    version = 2;
    rev = "7f561c78b5a4aad858d9fd550c92b5da6d55efbb";
    owner = "AudriusButkevicius";
    repo = "cli";
    sha256 = "0m9vi5cw611mddyxs7i7ss0j45xq2zmjdrf4mzi5d2khija7iirm";
    date = "2014-07-27";
  };

  mitchellh_cli = buildFromGitHub {
    version = 2;
    date = "2017-03-28";
    rev = "ee8578a9c12a5bb9d55303b9665cc448772c81b8";
    owner = "mitchellh";
    repo = "cli";
    sha256 = "0zg7f4l7gh0264i7np1srs630i8sqqd64k30md190dy0ln4mnb41";
    propagatedBuildInputs = [
      crypto
      go-isatty
      go-radix
      speakeasy
    ];
  };

  urfave_cli = buildFromGitHub {
    version = 2;
    rev = "v1.19.1";
    owner = "urfave";
    repo = "cli";
    sha256 = "0083s7jjxcgkssh5kpr34f5razf1x04f6n1kk9mrdsk1s1xw6h1k";
    goPackagePath = "gopkg.in/urfave/cli.v1";
    goPackageAliases = [
      "github.com/codegangsta/cli"
      "github.com/urfave/cli"
    ];
    buildInputs = [
      toml
      yaml_v2
    ];
  };

  clock = buildFromGitHub {
    version = 2;
    owner = "jmhodges";
    repo = "clock";
    rev = "880ee4c335489bc78d01e4d0a254ae880734bc15";
    date = "2016-05-18";
    sha256 = "6290b02c154e2ac0a6360133cef7584a9fe2008086002dff94846bcbc167109b";
  };

  clockwork = buildFromGitHub {
    version = 2;
    rev = "v0.1.0";
    owner = "jonboulle";
    repo = "clockwork";
    sha256 = "1hwdrck8k4nxdc0zpbd4hbxsyh8xhip9k7d71cv4ziwlh71sci5g";
  };

  clog = buildFromGitHub {
    version = 1;
    date = "2016-06-09";
    rev = "ae8f8315ad044b86ced2e0be9e3598e9dd94f38e";
    owner = "couchbase";
    repo = "clog";
    sha256 = "185c10ab80cn4jxdp915h428lm0r9zf1cqrfsjs71im3w3ankvsn";
  };

  cmux = buildFromGitHub {
    version = 2;
    date = "2017-01-10";
    rev = "30d10be492927e2dcae0089c374c455d42414fcb";
    owner = "cockroachdb";
    repo = "cmux";
    sha256 = "07g8dff49mg9plpd3v23bgbfyaj3g1vj38yixay1sgl2k4p6ip98";
    propagatedBuildInputs = [
      net
    ];
  };

  cobra = buildFromGitHub {
    version = 3;
    owner = "spf13";
    repo = "cobra";
    rev = "7b1b6e8dc027253d45fc029bc269d1c019f83a34";
    date = "2017-04-27";
    sha256 = "0wnpnc1m879ds092fimlpa0h45snqv4dshb9037g302q18nz2425";
    buildInputs = [
      mousetrap
      pflag
      viper
    ];
    propagatedBuildInputs = [
      go-md2man
      yaml_v2
    ];
  };

  color = buildFromGitHub {
    version = 2;
    rev = "v1.4.1";
    owner  = "fatih";
    repo   = "color";
    sha256 = "1g3z1344vjkl1aqxbmvaz43lvfm6pzinaz15zbrq6h4ir72i9hdm";
    propagatedBuildInputs = [
      go-colorable
      go-isatty
    ];
  };

  colorstring = buildFromGitHub {
    version = 1;
    rev = "8631ce90f28644f54aeedcb3e389a85174e067d1";
    owner  = "mitchellh";
    repo   = "colorstring";
    sha256 = "14dgak39642j795miqg5x7sb4ncpjgikn7vvbymxc5azy7z764hx";
    date = "2015-09-17";
  };

  columnize = buildFromGitHub {
    version = 2;
    rev = "ddeb643de91b4ee0d9d87172c931a4ea3d81d49a";
    owner  = "ryanuber";
    repo   = "columnize";
    sha256 = "0r26l715451slfx62f7m92w7c5dqcxmz1adzx2p84w2y77bphy71";
    date = "2017-02-08";
  };

  com = buildFromGitHub {
    version = 2;
    rev = "0db4a625e949e956314d7d1adea9bf82384cc10c";
    owner  = "Unknwon";
    repo   = "com";
    sha256 = "0flgww88p314wh3nikmmqmrnx2p7nq523cx40dsj2rh3kyxchy6i";
    date = "2017-02-13";
  };

  compress = buildFromGitHub {
    version = 2;
    rev = "v1.2.1";
    owner  = "klauspost";
    repo   = "compress";
    sha256 = "0ycfchs0brgxlvz48km955pzw0b71a9ipx3r2dqdawbf6zds5ix4";
    propagatedBuildInputs = [
      cpuid
      crc32
    ];
  };

  configure = buildFromGitHub {
    version = 2;
    rev = "4e0f2df8846ee9557b5c88307a769ff2f85e89cd";
    owner = "gravitational";
    repo = "configure";
    sha256 = "04qdmaz5pyd6nn7r5mdc2chzsx1zr2q0wv245xzzahx5n9m2x34x";
    date = "2016-10-02";
    propagatedBuildInputs = [
      gojsonschema
      kingpin_v2
      trace
      yaml_v2
    ];
    excludedPackages = "test";
  };

  consul = buildFromGitHub rec {
    version = 2;
    rev = "v0.8.1";
    owner = "hashicorp";
    repo = "consul";
    sha256 = "1m0gcz2mws9xcj0j0lfpi0m8y6d3divhj8inil5gshj4r3sbh6gg";

    buildInputs = [
      armon_go-metrics
      aws-sdk-go
      circbuf
      columnize
      copystructure
      dns
      errors
      go-bindata-assetfs
      go-checkpoint
      go-dockerclient
      go-memdb
      go-multierror
      go-radix
      go-rootcerts
      go-sockaddr
      go-syslog
      go-version
      golang-lru
      golang-text
      google-api-go-client
      gopsutil
      hashicorp_go-uuid
      hcl
      hil
      logutils
      mapstructure
      memberlist
      mitchellh_cli
      net-rpc-msgpackrpc
      oauth2
      raft-boltdb_v2
      raft_v2
      scada-client
      ugorji_go
      yamux
    ];

    propagatedBuildInputs = [
      go-cleanhttp
      serf
    ];

    postPatch = let
      v = stdenv.lib.substring 1 (stdenv.lib.stringLength rev - 1) rev;
    in ''
      sed \
        -e 's,\(Version[ \t]*= "\)unknown,\1${v},g' \
        -e 's,\(VersionPrerelease[ \t]*= "\)unknown,\1,g' \
        -i version/version.go
    '';

    # Keep consul.ui for backward compatability
    passthru.ui = pkgs.consul-ui;
  };

  consul_api = buildFromGitHub {
    inherit (consul) rev owner repo sha256 version;
    propagatedBuildInputs = [
      go-cleanhttp
      go-rootcerts
      serf
    ];
    subPackages = [
      "api"
      "lib"
      "tlsutil"
    ];
  };

  consulfs = buildFromGitHub {
    version = 2;
    rev = "6e4498b7b673f45b190f2fef31d79935385e87e3";
    owner = "bwester";
    repo = "consulfs";
    sha256 = "16n8g6vgaxbykxnal7vrnmj77n984ip4p9kcxg1akqdxz77r92dd";
    date = "2017-01-20";
    buildInputs = [
      consul_api
      fuse
      logrus
      net
    ];
  };

  consul-template = buildFromGitHub {
    version = 2;
    rev = "v0.18.2";
    owner = "hashicorp";
    repo = "consul-template";
    sha256 = "0g3wjrc0280hapyi49nn6mzjcprjdwaz3cybz72xh4im6ks3xlf2";

    propagatedBuildInputs = [
      consul_api
      errors
      go-homedir
      go-multierror
      go-rootcerts
      go-shellwords
      go-syslog
      hcl
      logutils
      mapstructure
      toml
      yaml_v2
      vault_api
    ];
  };

  context = buildFromGitHub {
    version = 1;
    rev = "v1.1";
    owner = "gorilla";
    repo = "context";
    sha256 = "0fsm31ayvgpcddx3bd8fwwz7npyd7z8d5ja0w38lv02yb634daj6";
  };

  copystructure = buildFromGitHub {
    version = 2;
    date = "2017-01-15";
    rev = "f81071c9d77b7931f78c90b416a074ecdc50e959";
    owner = "mitchellh";
    repo = "copystructure";
    sha256 = "0d4bjp8dhzxjgwsxrjcysyhjwjxifpbq1d5p6j6vq6kyjncslbli";
    propagatedBuildInputs = [ reflectwalk ];
  };

  core = buildFromGitHub {
    version = 2;
    rev = "e8409d73255791843585964791443dbad877058c";
    owner = "go-xorm";
    repo = "core";
    sha256 = "17b7i7p2jgh2y1pi077ckya4l9ksv341har3xmlpc7jzzysmm25b";
    date = "2017-03-17";
  };

  cors = buildFromGitHub {
    version = 2;
    owner = "rs";
    repo = "cors";
    date = "2017-04-20";
    rev = "2d7dd2a10331137ae3f931ba08c21fd00cbf208d";
    sha256 = "0l9fbh3sf53gfq79381icch8aywgsh4m4sml23hx1vpalqjgwbii";
    propagatedBuildInputs = [
      net
      xhandler
    ];
  };

  cpuid = buildFromGitHub {
    version = 1;
    rev = "v1.0";
    owner  = "klauspost";
    repo   = "cpuid";
    sha256 = "1bwp3mx8dik8ib8smf5pwbnp6h8p2ai4ihqijncd0f981r31c6ms";
    excludedPackages = "testdata";
  };

  crc32 = buildFromGitHub {
    version = 2;
    rev = "v1.1";
    owner  = "klauspost";
    repo   = "crc32";
    sha256 = "0kzb3yhk6s0919b5w0xy99fwv0xw02k79iw8issy07mx6an9dh31";
  };

  cronexpr = buildFromGitHub {
    version = 2;
    rev = "d520615e531a6bf3fb69406b9eba718261285ec8";
    owner  = "gorhill";
    repo   = "cronexpr";
    sha256 = "0cjnck67s18sdrlx8cv0yys5vaf1sknywbzd2dyq2l144cjrsj7h";
    date = "2016-12-05";
  };

  cuckoo = buildFromGitHub {
    version = 2;
    rev = "44c50ab64b38d3a9e59e352d1f316ba363d66d3b";
    owner  = "tildeleb";
    repo   = "cuckoo";
    sha256 = "12q72scaa5h3dnzf9qhj5a75nzg4dq6ahlfsfvwa6rra0x9ylap6";
    date = "2016-12-04";
    goPackagePath = "leb.io/cuckoo";
    goPackageAliases = [
      "github.com/tildeleb/cuckoo"
    ];
    excludedPackages = "\\(example\\|dstest\\|primes/primes\\)";
    propagatedBuildInputs = [
      aeshash
      binary
    ];
  };

  crypt = buildFromGitHub {
    version = 1;
    owner = "xordataexchange";
    repo = "crypt";
    rev = "749e360c8f236773f28fc6d3ddfce4a470795227";
    date = "2015-05-23";
    sha256 = "0zc00mpvqv7n1pz6fn6570wf9j8dc5d2m49yrqqygs52r2iarpx5";
    propagatedBuildInputs = [
      consul_api
      crypto
      go-etcd
    ];
    postPatch = ''
      sed -i backend/consul/consul.go \
        -e 's,"github.com/armon/consul-api",consulapi "github.com/hashicorp/consul/api",'
    '';
  };

  cssmin = buildFromGitHub {
    version = 1;
    owner = "dchest";
    repo = "cssmin";
    rev = "fb8d9b44afdc258bfff6052d3667521babcb2239";
    date = "2015-12-10";
    sha256 = "1m9zqdaw2qycvymknv6vx2i4jlpdj6lcjysxd18czbf5kp6pcri4";
  };

  datadog-go = buildFromGitHub {
    version = 3;
    rev = "1.1.0";
    owner = "DataDog";
    repo = "datadog-go";
    sha256 = "1xxr9xjcx0is2y4477as03gxnxkc10cg65818s5kzlv8b2y1m15n";
  };

  dbus = buildFromGitHub {
    version = 2;
    rev = "b038411ec341afd52c6d36d8baae92a29e6e8a9e";
    owner = "godbus";
    repo = "dbus";
    sha256 = "01j2nsvqgzd3i454c1cv8z743a22s6vq6c3xcc6bmlk2v24vbfpv";
    date = "2017-03-22";
  };

  decimal = buildFromGitHub {
    version = 2;
    rev = "3526cd0bdb7f64e1178943b7dee81a0cc3d86a69";
    owner  = "shopspring";
    repo   = "decimal";
    sha256 = "1804v4jabw93kbswybdl1kf5g0y9yvgbkdlh1jhl78mx7m6lsdzv";
    date = "2017-02-23";
  };

  distribution = buildFromGitHub {
    version = 2;
    rev = "e85ef3c019a2809b3397771d385581ee09fc7649";
    owner = "docker";
    repo = "distribution";
    sha256 = "15dc0ip1b3y7sd902m5kl5blbizyi3210all48dlic9f9q6mpq0s";
    propagatedBuildInputs = [
      cobra
      gorelic
      logrus
      mux
      net
      pflag
      resumable
      swift
    ];
    meta.useUnstable = true;
    date = "2017-04-25";
  };

  distribution_for_engine-api = buildFromGitHub {
    inherit (distribution) date rev owner repo sha256 version meta;
    subPackages = [
      "digestset"
      "reference"
    ];
    propagatedBuildInputs = [
      go-digest
    ];
  };

  distribution_for_docker = buildFromGitHub {
    inherit (distribution) date rev owner repo sha256 version meta;
    subPackages = [
      "."
      "context"
      "digestset"
      "reference"
      "registry/api/v2"
      "registry/api/errcode"
      "registry/client"
      "registry/client/auth"
      "registry/client/auth/challenge"
      "registry/client/transport"
      "registry/storage/cache"
      "registry/storage/cache/memory"
      "uuid"
    ];
    propagatedBuildInputs = [
      go-digest
      logrus
      mux
      net
    ];
  };

  dns = buildFromGitHub {
    version = 2;
    rev = "113c7538ea6d8f429071f901bd26af59cc9676fe";
    date = "2017-04-26";
    owner  = "miekg";
    repo   = "dns";
    sha256 = "0qfyx23xglny4xc8qj9kji30pjkmmjrzv984f5s84sm5p16gsv16";
  };

  dnsimple-go = buildFromGitHub {
    version = 2;
    rev = "v0.14.0";
    owner  = "dnsimple";
    repo   = "dnsimple-go";
    sha256 = "0bvgl8wwkkl98kfn86lx2y74zfvc05dwqrzd46v4blw7vcm3wya5";
    propagatedBuildInputs = [
      go-querystring
    ];
  };

  dnspod-go = buildFromGitHub {
    version = 2;
    rev = "68650ee11e182e30773781d391c66a0c80ccf9f2";
    owner = "decker502";
    repo = "dnspod-go";
    sha256 = "0iinhizgg6882nrbbvwhyw10g8p50gc45z9ycj1dr09rhpiw2k30";
    date = "2017-01-26";
  };

  docker = buildFromGitHub {
    version = 2;
    rev = "94465adaf05edd16f518f255cd7ad3c5ca23e2ac";
    owner = "docker";
    repo = "docker";
    sha256 = "0bv9m9ammhkbf8lh4xzkm15s375w24s7q9z492c1mvlxh86kq5ba";
    meta.useUnstable = true;
    date = "2017-04-26";
    propagatedBuildInputs = [
      distribution_for_docker
      errors
      gotty
      go-connections
      go-digest
      go-units
      libtrust
      net
      pflag
      logrus
    ];
  };

  docker_for_nomad = buildFromGitHub {
    inherit (docker) rev date owner repo sha256 version meta;
    subPackages = [
      "api/types"
      "api/types/blkiodev"
      "api/types/container"
      "api/types/filters"
      "api/types/mount"
      "api/types/network"
      "api/types/registry"
      "api/types/strslice"
      "api/types/swarm"
      "api/types/versions"
      "cli/config/configfile"
      "opts"
      "pkg/httputils"
      "pkg/ioutils"
      "pkg/jsonlog"
      "pkg/jsonmessage"
      "pkg/longpath"
      "pkg/random"
      "pkg/stringid"
      "pkg/tarsum"
      "pkg/term"
      "pkg/term/windows"
      "reference"
      "registry"
    ];
    propagatedBuildInputs = [
      distribution_for_docker
      errors
      gotty
      go-ansiterm
      go-connections
      go-digest
      go-units
      net
      pflag
      logrus
    ];
  };

  docker_for_runc = buildFromGitHub {
    inherit (docker) rev date owner repo sha256 version meta;
    subPackages = [
      "pkg/longpath"
      "pkg/mount"
      "pkg/symlink"
      "pkg/system"
      "pkg/term"
      "pkg/term/windows"
    ];
    propagatedBuildInputs = [
      go-ansiterm
      go-units
      go-winio
      logrus
      sys
    ];
  };

  docker_for_go-dockerclient = buildFromGitHub {
    inherit (docker) rev date owner repo sha256 version meta;
    subPackages = [
      "api/types"
      "api/types/blkiodev"
      "api/types/container"
      "api/types/filters"
      "api/types/mount"
      "api/types/network"
      "api/types/registry"
      "api/types/strslice"
      "api/types/swarm"
      "api/types/versions"
      "opts"
      "pkg/archive"
      "pkg/fileutils"
      "pkg/homedir"
      "pkg/idtools"
      "pkg/ioutils"
      "pkg/jsonlog"
      "pkg/jsonmessage"
      "pkg/longpath"
      "pkg/pools"
      "pkg/promise"
      "pkg/stdcopy"
      "pkg/system"
      "pkg/term"
      "pkg/term/windows"
    ];
    propagatedBuildInputs = [
      check
      engine-api
      gotty
      go-ansiterm
      go-connections
      go-units
      go-winio
      logrus
      net
      runc
      sys
    ];
  };

  docker_for_teleport = buildFromGitHub {
    inherit (docker) rev date owner repo sha256 version meta;
    subPackages = [
      "pkg/term"
      "pkg/term/windows"
    ];
    buildInputs = [
      go-ansiterm
      logrus
    ];
  };

  docopt-go = buildFromGitHub {
    version = 1;
    rev = "0.6.2";
    owner  = "docopt";
    repo   = "docopt-go";
    sha256 = "11cxmpapg7l8f4ar233f3ybvsir3ivmmbg1d4dbnqsr1hzv48xrf";
  };

  du = buildFromGitHub {
    version = 2;
    rev = "v1.0.1";
    owner  = "calmh";
    repo   = "du";
    sha256 = "00l7y5f2si43pz9iqnfccfbx6z6wni00aqc6jgkj1kwpjq5q9ya4";
  };

  duo_api_golang = buildFromGitHub {
    version = 2;
    date = "2016-06-27";
    rev = "2b2d787eb38e28ce4fd906321d717af19fad26a6";
    owner = "duosecurity";
    repo = "duo_api_golang";
    sha256 = "17vi9qg1dd02pmqjajqkspvdl676f0jhfzh4vzr4rxrcwgnqxdwx";
  };

  dropbox = buildFromGitHub {
    version = 2;
    owner = "stacktic";
    repo = "dropbox";
    rev = "58f839b21094d5e0af7caf613599830589233d20";
    date = "2016-04-24";
    sha256 = "4e9d14fa3be992f94b7672a21a90abfa746429d5ee260dcbfa11b391012595ad";
    propagatedBuildInputs = [
      net
      oauth2
    ];
  };

  dsync = buildFromGitHub {
    version = 2;
    owner = "minio";
    repo = "dsync";
    date = "2017-04-19";
    rev = "535db94aebce49cacce4de9c6f5f5821601281cd";
    sha256 = "0f3lc7yszyl3yv9rq7bsyda2yfp56xydvh834qrpplf998973yii";
  };

  easyjson = buildFromGitHub {
    version = 2;
    owner = "mailru";
    repo = "easyjson";
    rev = "3f09c2282fc5ad74b3d04a485311f3173c2431d3";
    date = "2017-04-26";
    sha256 = "172ipqpsy52sxga19s6qwbxfy7b3c160yv18qnhl8ml4vpgj83xz";
    excludedPackages = "benchmark";
  };

  ed25519 = buildFromGitHub {
    version = 2;
    owner = "agl";
    repo = "ed25519";
    rev = "5312a61534124124185d41f09206b9fef1d88403";
    sha256 = "0kb8jidncc30cn3dwwczxl7wnzjl862vy6p3rcrcnbgpygz6jhjf";
    date = "2017-01-16";
  };

  egoscale = buildFromGitHub {
    version = 2;
    rev = "ab4b0d7ff424c462da486aef27f354cdeb29a319";
    date = "2017-01-11";
    owner  = "pyr";
    repo   = "egoscale";
    sha256 = "5af0d24c309225f7243d71665b7f5558ae4403179663f40c01b1ba62a405eae5";
    meta.autoUpdate = false;
    subPackages = [
      "src/egoscale"
    ];
  };

  elastic_v2 = buildFromGitHub {
    version = 2;
    owner = "olivere";
    repo = "elastic";
    rev = "v2.0.54";
    sha256 = "9360c71601d67abd5b611ff6221ad92d02985d555046c874af61ef1d9bdb7fb7";
    goPackagePath = "gopkg.in/olivere/elastic.v2";
  };

  elastic_v3 = buildFromGitHub {
    version = 2;
    owner = "olivere";
    repo = "elastic";
    rev = "v3.0.59";
    sha256 = "dc2549cfdb71d8cbd901d339f3bb8a8844eede858f96842661986e990735aade";
    goPackagePath = "gopkg.in/olivere/elastic.v3";
    propagatedBuildInputs = [
      net
    ];
    meta.autoUpdate = false;
  };

  elastic_v5 = buildFromGitHub {
    version = 2;
    owner = "olivere";
    repo = "elastic";
    rev = "v5.0.36";
    sha256 = "1s4zkfg2wcshk8wqrxracrs3my3dn9pdw4nvrb94dn59fswb8vm2";
    goPackagePath = "gopkg.in/olivere/elastic.v5";
    propagatedBuildInputs = [
      net
      sync
    ];
  };

  eme = buildFromGitHub {
    version = 2;
    owner = "rfjakob";
    repo = "eme";
    rev = "da627cc50b6fb2eb623eaffe91fb29d7eddfd06a";
    date = "2017-04-01";
    sha256 = "0g6fhwq4lb0zxm1y9f3n0f1kmd4g26paqn474l89h667bswd4zn4";
    meta.useUnstable = true;
  };

  emoji = buildFromGitHub {
    version = 2;
    owner = "kyokomi";
    repo = "emoji";
    rev = "v1.5";
    sha256 = "0m41n13m8r0i6b75zv297fg6bdd82vrz3klxlkc855is079i0v4f";
  };

  encoding = buildFromGitHub {
    version = 2;
    owner = "jwilder";
    repo = "encoding";
    date = "2017-02-09";
    rev = "27894731927e49b0a9023f00312be26733744815";
    sha256 = "0sha9ghh6i9ca8bkw7qcjhppkb2dyyzh8zm760y4yi9i660r95h4";
  };

  engine-api = buildFromGitHub {
    version = 1;
    rev = "v0.4.0";
    owner = "docker";
    repo = "engine-api";
    sha256 = "1cgqhlngxlvplp6p560jvh4p003nm93pl4wannnlhwhcjrd34vyy";
    propagatedBuildInputs = [
      distribution_for_engine-api
      go-connections
      go-digest
      go-units
      net
    ];
  };

  envpprof = buildFromGitHub {
    version = 1;
    rev = "0383bfe017e02efb418ffd595fc54777a35e48b0";
    owner = "anacrolix";
    repo = "envpprof";
    sha256 = "0i9d021hmcfkv9wv55r701p6j6r8mj55fpl1kmhdhvar8s92rjgl";
    date = "2016-05-28";
  };

  errors = buildFromGitHub {
    version = 2;
    owner = "pkg";
    repo = "errors";
    rev = "v0.8.0";
    sha256 = "00fi35kiry67anhr4lxryyw5l9c26xj2zc5wzspr4z39paxgb4km";
  };

  errwrap = buildFromGitHub {
    version = 1;
    date = "2014-10-27";
    rev = "7554cd9344cec97297fa6649b055a8c98c2a1e55";
    owner  = "hashicorp";
    repo   = "errwrap";
    sha256 = "02hsk2zbwg68w62i6shxc0lhjxz20p3svlmiyi5zjz988qm3s530";
  };

  escaper = buildFromGitHub {
    version = 2;
    owner = "lucasem";
    repo = "escaper";
    rev = "17fe61c658dcbdcbf246c783f4f7dc97efde3a8b";
    sha256 = "1k0cbipikxxqc4im8dhkiq30ziakbld6h88vzr099c4x00qvpanf";
    goPackageAliases = [
      "github.com/10gen/escaper"
    ];
    date = "2016-08-02";
  };

  etcd = buildFromGitHub {
    version = 2;
    owner = "coreos";
    repo = "etcd";
    rev = "v3.1.6";
    sha256 = "12024ccvyln5v4b9xab3yd8hjgzbh576ky934k9kqx78mzqcmvsp";
    buildInputs = [
      bolt
      btree
      urfave_cli
      ccache
      clockwork
      cobra
      cmux
      crypto
      go-grpc-prometheus
      go-humanize
      go-semver
      go-systemd
      grpc
      grpc-gateway
      net
      pb_v1
      pflag
      pkg
      probing
      prometheus_client_golang
      protobuf
      gogo_protobuf
      pty
      speakeasy
      tablewriter
      time
      ugorji_go
      yaml

      pkgs.libpcap
    ];
  };

  etcd_client = buildFromGitHub {
    inherit (etcd) rev owner repo sha256 version meta;
    subPackages = [
      "client"
      "pkg/fileutil"
      "pkg/pathutil"
      "pkg/tlsutil"
      "pkg/transport"
      "pkg/types"
      "version"
    ];
    buildInputs = [
      go-systemd
      net
    ];
    propagatedBuildInputs = [
      go-semver
      pkg
      ugorji_go
    ];
  };

  etcd_for_vault = buildFromGitHub {
    inherit (etcd) rev owner repo sha256 version meta;
    subPackages = [
      "auth/authpb"
      "client"
      "clientv3"
      "etcdserver/api/v3rpc/rpctypes"
      "etcdserver/etcdserverpb"
      "mvcc/mvccpb"
      "pkg/fileutil"
      "pkg/pathutil"
      "pkg/tlsutil"
      "pkg/transport"
      "pkg/types"
      "version"
    ];
    propagatedBuildInputs = [
      go-grpc-prometheus
      go-semver
      grpc
      grpc-gateway
      net
      pkg
      protobuf
      ugorji_go
      yaml
    ];
    patches = [
      (fetchTritonPatch {
        rev = "4b06ab3e49c8267ba5fa34fd680264fa8c385e3c";
        file = "e/etcd/get-version.patch";
        sha256 = "1de1c765d53972da683985751dd9c5a832f16518cf53a9c6c9c2a5f84aa761fb";
      })
    ];
  };

  ewma = buildFromGitHub {
    version = 2;
    owner = "VividCortex";
    repo = "ewma";
    rev = "c595cd886c223c6c28fc9ae2727a61b5e4693d85";
    date = "2016-08-22";
    sha256 = "0367b039e90b5e08abd501874aeab77ba1c597f7395d5e3b2762642caf653ab9";
    meta.useUnstable = true;
  };

  exp = buildFromGitHub {
    version = 1;
    date = "2016-07-11";
    rev = "888ba4519f76bfc1e26a9b32e52c6775677b36fd";
    owner  = "cznic";
    repo   = "exp";
    sha256 = "1a32kv2wjzz1yfgivrm1bp4hzg878jwfmv9qy9hvdx0kccy7rvpw";
    propagatedBuildInputs = [ bufs fileutil mathutil sortutil zappy ];
  };

  fifo = buildFromGitHub {
    version = 2;
    owner = "tonistiigi";
    repo = "fifo";
    rev = "8cf41abe4d87641cd48738771bf25a20d06ca0b2";
    date = "2017-02-24";
    sha256 = "83ef31b8e00f05d73bc0a2070c4d9a84e65cb1bb1541d6b80ed01ccbaca397d3";
    propagatedBuildInputs = [
      errors
      net
    ];
  };

  fileutil = buildFromGitHub {
    version = 2;
    date = "2017-03-22";
    rev = "90cf820aafe8f7df39416fdbb932029ff99bd1ab";
    owner  = "cznic";
    repo   = "fileutil";
    sha256 = "036igc9nll1wnyzymnrkhf81jy4jq5wy6qfwwdacyrqp2glc87dr";
    buildInputs = [
      mathutil
    ];
  };

  fileutils = buildFromGitHub {
    version = 2;
    date = "2016-09-30";
    rev = "4ee1cc9a80582a0c75febdd5cfa779ee4361cbca";
    owner  = "mrunalp";
    repo   = "fileutils";
    sha256 = "1x1war04ck4kkwjfjzjksgldzkplv246qkkivwahfcfqcx8dapr3";
  };

  flagfile = buildFromGitHub {
    version = 2;
    date = "2017-02-23";
    rev = "3836a321743b3e6c4c4585da402fd2390b358c86";
    owner  = "spacemonkeygo";
    repo   = "flagfile";
    sha256 = "17sg1ydkr84j3sqkbd7ij06awdcmla5vj0br473mvichkck37i30";
  };

  fs = buildFromGitHub {
    version = 1;
    date = "2013-11-07";
    rev = "2788f0dbd16903de03cb8186e5c7d97b69ad387b";
    owner  = "kr";
    repo   = "fs";
    sha256 = "16ygj65wk30cspvmrd38s6m8qjmlsviiq8zsnnvkhfy5l0gk4c86";
  };

  fsnotify = buildFromGitHub {
    version = 2;
    owner = "fsnotify";
    repo = "fsnotify";
    rev = "v1.4.2";
    sha256 = "1kbs526vl358dd9rrcdnniwnzhcxkbswkmkl80dl2sgi9x0w45g6";
    propagatedBuildInputs = [
      sys
    ];
  };

  fsnotify_v1 = buildFromGitHub {
    version = 2;
    owner = "fsnotify";
    repo = "fsnotify";
    rev = "v1.4.2";
    sha256 = "1f3zshxdd3kj08b87106gxj68fjljfb7b3r9i8xjrj0i79wy6phn";
    goPackagePath = "gopkg.in/fsnotify.v1";
    propagatedBuildInputs = [
      sys
    ];
  };

  fsync = buildFromGitHub {
    version = 2;
    owner = "spf13";
    repo = "fsync";
    rev = "12a01e648f05a938100a26858d2d59a120307a18";
    date = "2017-03-20";
    sha256 = "1vn313i08byzsmzvq98xqb074iiz1fx7hi912gzbzwrzxk81bish";
    buildInputs = [
      afero
    ];
  };

  fuse = buildFromGitHub {
    version = 2;
    owner = "bazil";
    repo = "fuse";
    rev = "371fbbdaa8987b715bdd21d6adc4c9b20155f748";
    date = "2016-08-11";
    sha256 = "1f3cb9274f037e14c2437126fa17d39e6284f40f0ddb93b2dbb59d5bab6b97d0";
    goPackagePath = "bazil.org/fuse";
    propagatedBuildInputs = [
      net
      sys
    ];
  };

  fwd = buildFromGitHub {
    version = 2;
    date = "2016-01-28";
    rev = "98c11a7a6ec829d672b03833c3d69a7fae1ca972";
    owner  = "philhofer";
    repo   = "fwd";
    sha256 = "15wamyn4xfxvdnf6d2figrl8my1lm00n49m6l3qxdxcdkfa69qnv";
  };

  gabs = buildFromGitHub {
    version = 2;
    owner = "Jeffail";
    repo = "gabs";
    rev = "1.0";
    sha256 = "1pbsgk0pmhzi8crds5ys8nsrxyra6q6w9rmv6i09zqyf7icn9wwa";
  };

  gateway = buildFromGitHub {
    version = 1;
    date = "2016-05-22";
    rev = "edad739645120eeb82866bc1901d3317b57909b1";
    owner  = "calmh";
    repo   = "gateway";
    sha256 = "0gzwns51jl2jm62ii99c7caa9p7x2c8p586q1cjz8bpv2mcd8njg";
    goPackageAliases = [
      "github.com/jackpal/gateway"
    ];
  };

  gax-go = buildFromGitHub {
    version = 2;
    date = "2017-03-21";
    rev = "9af46dd5a1713e8b5cd71106287eba3cefdde50b";
    owner  = "googleapis";
    repo   = "gax-go";
    sha256 = "09j0pix0wfl24k9lzp53nv2ph7akz39g2qdbvpkkpw49yf6fcrvg";
    propagatedBuildInputs = [
      grpc_for_gax-go
      net
    ];
  };

  genproto = buildFromGitHub {
    version = 2;
    date = "2017-04-04";
    rev = "411e09b969b1170a9f0c467558eb4c4c110d9c77";
    owner  = "google";
    repo   = "go-genproto";
    goPackagePath = "google.golang.org/genproto";
    sha256 = "0wn4yflplv9kpf4qahg4fyb0l52513y416wvn9pxrl66rfpig8ic";
    propagatedBuildInputs = [
      grpc
      net
      protobuf
    ];
  };

  genproto_protobuf = buildFromGitHub {
    inherit (genproto) version date rev owner repo goPackagePath sha256;
    subPackages = [
      "protobuf"
    ];
    buildInputs = [
      protobuf_genproto
    ];
  };

  genproto_for_grpc = buildFromGitHub {
    inherit (genproto) version date rev owner repo goPackagePath sha256;
    subPackages = [
      "googleapis/rpc/status"
    ];
    buildInputs = [
      protobuf
    ];
  };

  geoip2-golang = buildFromGitHub {
    version = 2;
    rev = "v1.1.0";
    owner = "oschwald";
    repo = "geoip2-golang";
    sha256 = "0qs7v3hbhih7a99nd9xqc5mz2bgdvhknlzv3hr15fd1w5w49yv1b";
    propagatedBuildInputs = [
      maxminddb-golang
    ];
  };

  gettext = buildFromGitHub {
    version = 2;
    rev = "v0.9";
    owner = "gosexy";
    repo = "gettext";
    sha256 = "1zrxfzwlv04gadxxyn8whmdin83ij735bbggxrnf3mcbxs8svs96";
    buildInputs = [
      go-flags
      go-runewidth
    ];
  };

  ginkgo = buildFromGitHub {
    version = 2;
    rev = "v1.3.1";
    owner = "onsi";
    repo = "ginkgo";
    sha256 = "1ssa4lm68zfy9lim4xw294fvsinyfrnjvdj28sxb2hah9dw557nk";
    buildInputs = [
      sys
    ];
  };

  gitmap = buildFromGitHub {
    version = 2;
    rev = "dcb907b39a0690430d435eb8f63cd8811961231f";
    date = "2017-02-17";
    owner = "bep";
    repo = "gitmap";
    sha256 = "1zykf519xplb23lj0rjggpgbmd375l0zhzx29q4vxrsppyjsqzkk";
  };

  gjson = buildFromGitHub {
    version = 2;
    owner = "tidwall";
    repo = "gjson";
    date = "2017-04-18";
    rev = "e30a9c1037e0f9fbde93a6a9848a2dd5c59d3b91";
    sha256 = "0pq282wrj5ksj69xl7b4jcz812mkcpf4cjxgs1gzabkh04731732";
    propagatedBuildInputs = [
      match
    ];
  };

  glob = buildFromGitHub {
    version = 2;
    rev = "v0.2.2";
    owner = "gobwas";
    repo = "glob";
    sha256 = "1mzn45p24qn7qdagfb9mlj96jlmwk3kgk637kxnb4qaqnl8bkkh1";
  };

  siddontang_go = buildFromGitHub {
    version = 2;
    date = "2017-04-11";
    rev = "6463c3972685bfea94e6dc1f6817bee41b20269f";
    owner = "siddontang";
    repo = "go";
    sha256 = "0zik54j2cprpixf5drb8givxzyinqy18a8pg2lk869fnak94xf0c";
  };

  ugorji_go = buildFromGitHub {
    version = 2;
    date = "2017-03-12";
    rev = "708a42d246822952f38190a8d8c4e6b16a0e600c";
    owner = "ugorji";
    repo = "go";
    sha256 = "0jx44bnpx3wy6ka3pidsfjp0n0ns1spcp7wy3ixvcfpixz3pfl46";
    goPackageAliases = [
      "github.com/hashicorp/go-msgpack"
    ];
  };

  go-acd = buildFromGitHub {
    version = 2;
    owner = "ncw";
    repo = "go-acd";
    rev = "96a49aad3fc3889629f2eceb004927386884bd92";
    date = "2017-03-06";
    sha256 = "0a737iq3chdsgl1wwmk5vjppkpb60qpj6pmma5k2hmbh9p2d51nz";
    propagatedBuildInputs = [
      go-querystring
    ];
  };

  go-ansiterm = buildFromGitHub {
    version = 2;
    owner = "Azure";
    repo = "go-ansiterm";
    rev = "fa152c58bc15761d0200cb75fe958b89a9d4888e";
    date = "2016-06-22";
    sha256 = "1iwkrl0vxp08hxjw6lvgl6b11ciky3r6fbxwidbaamp08naaglzp";
    buildInputs = [
      logrus
    ];
  };

  go-httpclient = buildFromGitHub {
    version = 2;
    owner = "mreiferson";
    repo = "go-httpclient";
    rev = "31f0106b4474f14bc441575c19d3a5fa21aa1f6c";
    date = "2016-06-30";
    sha256 = "e9fb80be94f61a8df23ee201be2988688cceba4d1c7339b60b955a66daebd3e3";
  };

  go4 = buildFromGitHub {
    version = 2;
    date = "2017-04-25";
    rev = "cababa4e44509c51b2718c014b5e522659af5d1b";
    owner = "camlistore";
    repo = "go4";
    sha256 = "1gddb99s1ppy62wd861kblga3s4bpqg10j474lh9xw9rqr460181";
    goPackagePath = "go4.org";
    goPackageAliases = [
      "github.com/camlistore/go4"
    ];
    buildInputs = [
      google-api-go-client
      google-cloud-go
      oauth2
      net
      sys
    ];
  };

  gocapability = buildFromGitHub {
    version = 2;
    rev = "e7cb7fa329f456b3855136a2642b197bad7366ba";
    owner = "syndtr";
    repo = "gocapability";
    sha256 = "0k8nbsg4h9b8srd2ykkilf73m19b8lm6ib2cx98n5s6m0af4m7y7";
    date = "2016-09-28";
  };

  gocql = buildFromGitHub {
    version = 2;
    rev = "7e9748ccda7fd5135a7db13ba03f09cad0c86bed";
    owner  = "gocql";
    repo   = "gocql";
    sha256 = "1kq9yxqc1jij8s44fln2nsbfjnbkmsbvjc6rk0d281b56dv8wgpk";
    propagatedBuildInputs = [
      inf_v0
      snappy
      hailocab_go-hostpool
      net
    ];
    date = "2017-04-19";
  };

  gofuzz = buildFromGitHub {
    version = 2;
    rev = "44d81051d367757e1c7c6a5a86423ece9afcf63c";
    owner  = "google";
    repo   = "gofuzz";
    sha256 = "0kj873dl0c5bav3lacz4qijxvkni61b8w5zwjshbr95xymk33zgp";
    date = "2016-11-22";
  };

  gojsonpointer = buildFromGitHub {
    version = 2;
    rev = "6fe8760cad3569743d51ddbb243b26f8456742dc";
    owner  = "xeipuuv";
    repo   = "gojsonpointer";
    sha256 = "0gfg90ibq0f6smmysj5svn1b04a39sc4w7xw38rgr4kyszhv4zj5";
    date = "2017-02-25";
  };

  gojsonreference = buildFromGitHub {
    version = 1;
    rev = "e02fc20de94c78484cd5ffb007f8af96be030a45";
    owner  = "xeipuuv";
    repo   = "gojsonreference";
    sha256 = "1c2yhjjxjvwcniqag9i5p159xsw4452vmnc2nqxnfsh1whd8wpi5";
    date = "2015-08-08";
    propagatedBuildInputs = [ gojsonpointer ];
  };

  gojsonschema = buildFromGitHub {
    version = 2;
    rev = "20fdae500baa62c0de724a741df80b695c8ac756";
    owner  = "xeipuuv";
    repo   = "gojsonschema";
    sha256 = "1fx1g14k310v95p5hvwgh95zvv0di77yz9f5y9036k8q80mg7qw0";
    date = "2017-04-22";
    propagatedBuildInputs = [ gojsonreference ];
  };

  gomemcache = buildFromGitHub {
    version = 2;
    rev = "1952afaa557dc08e8e0d89eafab110fb501c1a2b";
    date = "2017-02-08";
    owner = "bradfitz";
    repo = "gomemcache";
    sha256 = "1h1sjgjv4ay6y26g25vg2q0iawmw8fnlam7r66qiq0hclzb72fcn";
  };

  gomemcached = buildFromGitHub {
    version = 2;
    rev = "f8b076f89aa2033c375ff86c3b52cdce72da5572";
    date = "2017-04-21";
    owner = "couchbase";
    repo = "gomemcached";
    sha256 = "17lv8cs89f22hrk7b0cwvk93ymss063m3ldavvlf8qk7v5svxvkq";
    propagatedBuildInputs = [
      goutils_logging
    ];
  };

  gopacket = buildFromGitHub {
    version = 2;
    rev = "a9784fc2b9489431cc621a74e8b54893ec145c97";
    owner = "google";
    repo = "gopacket";
    sha256 = "00hy07jdx705yqcfb3g4k4mp690x0diclkq0kf7mkaj3s8ybzhv2";
    buildInputs = [
      pkgs.libpcap
      pkgs.pf-ring
    ];
    propagatedBuildInputs = [
      net
      sys
    ];
    date = "2017-04-26";
  };

  google-cloud-go = buildFromGitHub {
    version = 3;
    date = "2017-04-27";
    rev = "ba86ddfb382944d62e1ddfe1c479a9b8421d2f51";
    owner = "GoogleCloudPlatform";
    repo = "google-cloud-go";
    sha256 = "0iw9jp9p064ywgnawx284f69mqfx0j400khlr8zq2nvliq9rpa4a";
    goPackagePath = "cloud.google.com/go";
    goPackageAliases = [
      "google.golang.org/cloud"
    ];
    propagatedBuildInputs = [
      debug
      gax-go
      genproto
      geo
      glog
      google-api-go-client
      grpc
      net
      oauth2
      protobuf
      sync
      text
      time
    ];
    postPatch = ''
      sed -i 's,bundler.Close,bundler.Stop,g' logging/logging.go
    '';
    excludedPackages = "\\(oauth2\\|readme\\)";
    meta.useUnstable = true;
  };

  google-cloud-go-compute-metadata = buildFromGitHub {
    inherit (google-cloud-go) rev date owner repo sha256 version goPackagePath goPackageAliases meta;
    subPackages = [
      "compute/metadata"
      "internal"
    ];
    propagatedBuildInputs = [
      gax-go
      net
    ];
  };

  gopcap = buildFromGitHub {
    version = 2;
    rev = "00e11033259acb75598ba416495bb708d864a010";
    date = "2015-07-28";
    owner = "akrennmair";
    repo = "gopcap";
    sha256 = "189skp51bd7aqpqs63z20xqm0pj5dra23g51m993rbq81zsvp0yq";
    buildInputs = [
      pkgs.libpcap
    ];
  };

  goprocess = buildFromGitHub {
    version = 2;
    rev = "b497e2f366b8624394fb2e89c10ab607bebdde0b";
    date = "2016-08-25";
    owner = "jbenet";
    repo = "goprocess";
    sha256 = "1i4spw84hlka1l8xxizpiqklsqyc3hxxjz3wbpn3i2ql68raylbx";
  };

  goredis = buildFromGitHub {
    version = 1;
    rev = "760763f78400635ed7b9b115511b8ed06035e908";
    date = "2015-03-24";
    owner = "siddontang";
    repo = "goredis";
    sha256 = "193n28jaj01q0k8lx2ijvgzmlh926jy6cg2ph3446k90pl5r118c";
  };

  gorelic = buildFromGitHub {
    version = 2;
    rev = "ae09aa139a2b7f638e2412baceaceebd41eff115";
    date = "2016-06-16";
    owner = "yvasiyarov";
    repo = "gorelic";
    sha256 = "1x9hd2hlq796lf87h1jipqrf7vj7c1qxmg49f3qk5s4cvs5gzb5m";
  };

  goreq = buildFromGitHub {
    version = 2;
    rev = "b5b0f5eb2d16f20345cce0a544a75163579c0b00";
    date = "2017-04-18";
    owner = "franela";
    repo = "goreq";
    sha256 = "1bf0nqxrrs9grf0hd2rbyfxb2sj72jd5hd4nb5v5n5mrxhpmmaf4";
  };

  goterm = buildFromGitHub {
    version = 2;
    rev = "bc6c333206f446a53cac4db5d2e6a4316139d737";
    date = "2017-03-17";
    owner = "buger";
    repo = "goterm";
    sha256 = "0awypcapx6n1csx2kchbjsd667vb4l6s433ndvnz1wafrfw4pzfz";
  };

  gotty = buildFromGitHub {
    version = 2;
    rev = "cd527374f1e5bff4938207604a14f2e38a9cf512";
    date = "2012-06-04";
    owner = "Nvveen";
    repo = "Gotty";
    sha256 = "16slr2a0mzv2bi90s5pzmb6is6h2dagfr477y7g1s89ag1dcayp8";
  };

  goutils = buildFromGitHub {
    version = 2;
    rev = "82b8055850965344f7d89d8a0abe364ac09dfa5e";
    date = "2017-04-21";
    owner = "couchbase";
    repo = "goutils";
    sha256 = "1l7rszrqiv31431fnmc2vcbkiv2vpkqwfgf4g5nchacpj98x8qsb";
    buildInputs = [
      cbauth
      go-couchbase
      gomemcached
    ];
  };

  goutils_logging = buildFromGitHub {
    inherit (goutils) rev date owner repo sha256 version;
    subPackages = [
      "logging"
    ];
  };

  golang-lru = buildFromGitHub {
    version = 1;
    date = "2016-08-13";
    rev = "0a025b7e63adc15a622f29b0b2c4c3848243bbf6";
    owner  = "hashicorp";
    repo   = "golang-lru";
    sha256 = "1nq6q2l5ml3dljxm0ks4zivcci1yg2f2lmam9kvykkwm03m85qy1";
  };

  golang-petname = buildFromGitHub {
    version = 2;
    rev = "4f77bdee0b67a08d17afadc0d5a4a3d1cb7d8d14";
    owner  = "dustinkirkland";
    repo   = "golang-petname";
    sha256 = "1z9g7m2gx7k68w1hig5bxdbj292b6vvk3i991qmycfflfmwj399p";
    date = "2017-04-10";
  };

  golang-text = buildFromGitHub {
    version = 2;
    rev = "048ed3d792f7104850acbc8cfc01e5a6070f4c04";
    owner  = "tonnerre";
    repo   = "golang-text";
    sha256 = "188nzg7dcr3xl8ipgdiks6h3wxi51391y4jza4jcbvw1z1mi7iig";
    date = "2013-09-25";
    propagatedBuildInputs = [
      pty
      kr_text
    ];
    meta.useUnstable = true;
  };

  golang_protobuf_extensions = buildFromGitHub {
    version = 1;
    rev = "v1.0.0";
    owner  = "matttproud";
    repo   = "golang_protobuf_extensions";
    sha256 = "0r1sv4jw60rsxy5wlnr524daixzmj4n1m1nysv4vxmwiw9mbr6fm";
    buildInputs = [ protobuf ];
  };

  goleveldb = buildFromGitHub {
    version = 2;
    rev = "8c81ea47d4c41a385645e133e15510fc6a2a74b4";
    date = "2017-04-09";
    owner = "syndtr";
    repo = "goleveldb";
    sha256 = "08yqjwp6652f9kc7h69xgwzllw501m6s7brydfy871rfgb00nzhf";
    propagatedBuildInputs = [ ginkgo gomega snappy ];
  };

  gomega = buildFromGitHub {
    version = 2;
    rev = "v1.1.0";
    owner  = "onsi";
    repo   = "gomega";
    sha256 = "0j00hpga37272rd4ncw9l0v6skrwmxy7srqmdadndwy4hw5pdf4a";
    propagatedBuildInputs = [
      protobuf
      yaml_v2
    ];
  };

  google-api-go-client = buildGoPackage rec {
    name = nameFunc {
      inherit
        goPackagePath
        rev;
      date = "2017-04-21";
    };
    rev = "fbbaff1827317122a8a0e1b24de25df8417ce87b";
    goPackagePath = "google.golang.org/api";
    src = fetchzip {
      version = 2;
      stripRoot = false;
      purgeTimestamps = true;
      inherit name;
      url = "https://code.googlesource.com/google-api-go-client/+archive/${rev}.tar.gz";
      sha256 = "1fm8wy6abzql82dg55n5m0jxr6kypqbc0jaw7xfhs6ds9n1s9r6x";
    };
    buildInputs = [
      appengine
      genproto
      grpc
      net
      oauth2
      sync
    ];
  };

  goorgeous = buildFromGitHub {
    version = 2;
    rev = "23d6dd16373c7b089678a754522710f69db08853";
    date = "2017-04-26";
    owner = "chaseadamsio";
    repo = "goorgeous";
    sha256 = "198xgwwzv92rh8isp8zqmv9sx5g5glvk84nlq82hh0m913sv8542";
    propagatedBuildInputs = [
      blackfriday
      sanitized-anchor-name
    ];
  };

  gopass = buildFromGitHub {
    version = 2;
    date = "2017-01-09";
    rev = "bf9dde6d0d2c004a008c27aaee91170c786f6db8";
    owner = "howeyc";
    repo = "gopass";
    sha256 = "0chij9mja3pwgmyvjcbp86xh9h9v1ljgpvscph6jxa1k1pp9dfah";
    propagatedBuildInputs = [
      crypto
      sys
    ];
  };

  gopsutil = buildFromGitHub {
    version = 2;
    rev = "v2.17.03";
    owner  = "shirou";
    repo   = "gopsutil";
    sha256 = "1dg1wr4r5dhpi5h8fjmbl3195cg395zassb7ixga84z3lvmnbqgq";
    buildInputs = [
      w32
      wmi
    ];
  };

  goquery = buildFromGitHub {
    version = 2;
    rev = "v1.1.0";
    owner  = "PuerkitoBio";
    repo   = "goquery";
    sha256 = "1c8q4ijhdm7ly26cvhr61kqla9gqc49c9s4v906k0shnbf3ygmm5";
    propagatedBuildInputs = [
      cascadia
      net
    ];
  };

  goskiplist = buildFromGitHub {
    version = 1;
    rev = "2dfbae5fcf46374f166f8969cb07e167f1be6273";
    owner  = "ryszard";
    repo   = "goskiplist";
    sha256 = "1dr6n2w5ikdddq9c1fwqnc0m383p73h2hd04302cfgxqbnymabzq";
    date = "2015-03-12";
  };

  govalidator = buildFromGitHub {
    version = 2;
    rev = "4918b99a7cb949bb295f3c7bbaf24b577d806e35";
    owner = "asaskevich";
    repo = "govalidator";
    sha256 = "0dqz805n844f7d5gmp3h2519f2wz1bz4v0jb30ch09fcz1f6vd47";
    date = "2017-04-25";
  };

  go-autorest = buildFromGitHub {
    version = 2;
    rev = "v7.3.1";
    owner  = "Azure";
    repo   = "go-autorest";
    sha256 = "0irgvzzwlx0dqy73ndwvpflpfqnjq11sdwzhjiks4ws4ddqsmixb";
    propagatedBuildInputs = [
      crypto
      jwt-go
    ];
  };

  go-base58 = buildFromGitHub {
    version = 1;
    rev = "1.0.0";
    owner  = "jbenet";
    repo   = "go-base58";
    sha256 = "0sbss2611iri3mclcz3k9b7kw2sqgwswg4yxzs02vjk3673dcbh2";
  };

  go-bindata-assetfs = buildFromGitHub {
    version = 2;
    rev = "30f82fa23fd844bd5bb1e5f216db87fd77b5eb43";
    owner   = "elazarl";
    repo    = "go-bindata-assetfs";
    sha256 = "0pval4z7k1bbcdx1hqd4cw9x5l01pikkya0n61c4wrfi0ghx25ln";
    date = "2017-02-27";
  };

  go-bits = buildFromGitHub {
    version = 2;
    owner = "dgryski";
    repo = "go-bits";
    date = "2016-06-01";
    rev = "2ad8d707cc05b1815ce6ff2543bb5e8d8f9298ef";
    sha256 = "d77d906fb806bb9bd9af7f54f0c3277d6b86d84015e198cb367f1d7788c8b938";
  };

  go-bitstream = buildFromGitHub {
    version = 2;
    owner = "dgryski";
    repo = "go-bitstream";
    date = "2016-07-01";
    rev = "7d46cd22db7004f0cceb6f7975824b560cf0e486";
    sha256 = "32a82d1220c6d2ec05cf2d6150ed8f2a3ce6c544f626cc7574acaa57e31bbd9c";
  };

  go-buffruneio = buildFromGitHub {
    version = 2;
    owner = "pelletier";
    repo = "go-buffruneio";
    rev = "v0.2.0";
    sha256 = "080mjg20yp2h04pk5g2ls3jg7z2h80wjj0qv254k2hga63xkk3k6";
  };

  go-cache = buildFromGitHub {
    version = 2;
    rev = "7ac151875ffb48b9f3ccce9ea20f020b0c1596c8";
    owner = "patrickmn";
    repo = "go-cache";
    sha256 = "0cxfikqd2wn1q004zlcky4kjrm5kkgs3hcj8xh32y7xqysj6pnx2";
    date = "2017-04-18";
  };
  go-checkpoint = buildFromGitHub {
    version = 1;
    date = "2016-08-16";
    rev = "f8cfd20c53506d1eb3a55c2c43b84d009fab39bd";
    owner  = "hashicorp";
    repo   = "go-checkpoint";
    sha256 = "066rs0gbflz5jbfpvklc3vg5zs7l1fdfjrfy21y4c4j5vkm49gz5";
    buildInputs = [
      go-cleanhttp
    ];
  };

  go-cleanhttp = buildFromGitHub {
    version = 2;
    date = "2017-02-10";
    rev = "3573b8b52aa7b37b9358d966a898feb387f62437";
    owner = "hashicorp";
    repo = "go-cleanhttp";
    sha256 = "1q6fzddda47f0n2n04iz7lpz77j1lfs14477qd6ajjj6q0a6sii4";
  };

  go-collectd = buildFromGitHub {
    version = 2;
    owner = "collectd";
    repo = "go-collectd";
    rev = "bf0e31aeedfea7fb13f821e0831cfe2b5974d1e9";
    sha256 = "1zz7l4cz9pasnnj3gjc43skw481rxncflsyvyw7n0k4aawklr14b";
    goPackagePath = "collectd.org";
    buildInputs = [
      grpc
      net
      pkgs.collectd
      protobuf
    ];
    preBuild = ''
      # Regerate protos
      srcDir="$(pwd)"/go/src
      pushd go/src/$goPackagePath >/dev/null
      find . -name \*pb.go -delete
      for file in $(find . -name \*.proto | sort | uniq); do
        pushd "$(dirname "$file")" > /dev/null
        echo "Regenerating protobuf: $file" >&2
        protoc -I "$srcDir" -I "$srcDir/$goPackagePath" -I . --go_out=plugins=grpc:. "$(basename "$file")"
        popd >/dev/null
      done
      popd >/dev/null

      # Create a config.h and proper headers
      export COLLECTD_SRC="$(pwd)/collectd-src"
      mkdir -pv "$COLLECTD_SRC"
      pushd "$COLLECTD_SRC" >/dev/null
        unpackFile "${pkgs.collectd.src}"
      popd >/dev/null
      srcdir="$(echo "$COLLECTD_SRC"/collectd-*)"
      # Run configure to generate config.h
      pushd "$srcdir" >/dev/null
        ./configure
      popd >/dev/null
      export CGO_CPPFLAGS="-I$srcdir/src/daemon -I$srcdir/src"
    '';
    date = "2017-04-11";
  };

  go-colorable = buildFromGitHub {
    version = 2;
    rev = "v0.0.7";
    owner  = "mattn";
    repo   = "go-colorable";
    sha256 = "0r7qqrdpy19whvkifcpc6w53am83rq05vmax1ajaw2ywl0gwvvlq";
    buildInputs = [
      go-isatty
    ];
  };

  go-connections = buildFromGitHub {
    version = 2;
    rev = "e15c02316c12de00874640cd76311849de2aeed5";
    owner  = "docker";
    repo   = "go-connections";
    sha256 = "154a8z0jcqqqgnn1x08q1yffb09hz90qvpqs5h45676anb7cb8a8";
    propagatedBuildInputs = [
      errors
      go-winio
      logrus
      net
      runc
    ];
    date = "2017-03-31";
  };

  go-couchbase = buildFromGitHub {
    version = 2;
    rev = "2beb5c5532c7b37b6e9d8624c6ccfd4eb18967c9";
    owner  = "couchbase";
    repo   = "go-couchbase";
    sha256 = "185kb7i2wxq7fy86l745x2lcwbn6mafdz43iy3sa34k2raamdzw8";
    date = "2017-04-26";
    goPackageAliases = [
      "github.com/couchbaselabs/go-couchbase"
    ];
    propagatedBuildInputs = [
      gomemcached
      goutils_logging
    ];
    excludedPackages = "\\(perf\\|example\\)";
  };

  go-crypto = buildFromGitHub {
    version = 2;
    rev = "0ee3e17034decab4941145296c0b0f4def213a7b";
    owner  = "keybase";
    repo   = "go-crypto";
    sha256 = "12nn4gqn4kyff4499advw0rwsl0ynh22slr5li90mw0asgphbmpr";
    date = "2017-04-19";
    propagatedBuildInputs = [
      ed25519
    ];
  };

  go-deadlock = buildFromGitHub {
    version = 2;
    rev = "v0.1.0";
    owner  = "sasha-s";
    repo   = "go-deadlock";
    sha256 = "0d7kl9fw4d5mpn1ivd2hicnxp3fxp8yhmd287nz39appgl0gwkf8";
  };

  go-difflib = buildFromGitHub {
    version = 1;
    rev = "v1.0.0";
    owner  = "pmezard";
    repo   = "go-difflib";
    sha256 = "0zb1bmnd9kn0qbyn2b62r9apbkpj3752isgbpia9i3n9ix451cdb";
  };

  go-digest = buildFromGitHub {
    version = 2;
    rev = "aa2ec055abd10d26d539eb630a92241b781ce4bc";
    owner  = "opencontainers";
    repo   = "go-digest";
    sha256 = "11zwn00kdhzpmms1585iczj4mqqjlvmxnm332bawmldk1w7qllin";
    date = "2017-01-30";
    goPackageAliases = [
      "github.com/docker/distribution/digest"
    ];
  };

  go-dockerclient = buildFromGitHub {
    version = 2;
    date = "2017-04-19";
    rev = "c64a7161ef25818ebc0c21cf75243f61fe005bac";
    owner = "fsouza";
    repo = "go-dockerclient";
    sha256 = "0kzwpy46g89isgmpgls08i50kpjgj0v04rzhwzmzpk6j2fxcs6nb";
    propagatedBuildInputs = [
      docker_for_go-dockerclient
      go-cleanhttp
      go-units
      go-winio
      moby_for_go-dockerclient
      mux
      net
    ];
  };

  go-etcd = buildFromGitHub {
    version = 2;
    date = "2015-10-26";
    rev = "003851be7bb0694fe3cc457a49529a19388ee7cf";
    owner  = "coreos";
    repo   = "go-etcd";
    sha256 = "1cijiw77cy4z6p4zhagm0q7ydyn8kk24v1611arx6wmvzgi7lyc3";
    propagatedBuildInputs = [
      ugorji_go
    ];
  };

  go-ethereum = buildFromGitHub {
    version = 2;
    date = "2017-04-25";
    rev = "8dce4c283dda3a8e10aa30dadab05a8c0dd9e19d";
    owner  = "ethereum";
    repo   = "go-ethereum";
    sha256 = "0cnsnvz9qhp8qw4byx9gsgbbh582dlpbfqpxifdlafc0yp9h4ma2";
    subPackages = [
      "crypto/sha3"
    ];
  };

  go-events = buildFromGitHub {
    version = 2;
    owner = "docker";
    repo = "go-events";
    rev = "aa2e3b613fbbfdddbe055a7b9e3ce271cfd83eca";
    date = "2016-09-06";
    sha256 = "9a343e28d608971d2baec59bc62637a697f1b45c44e61b782b81c212b5ef507b";
    propagatedBuildInputs = [
      logrus
    ];
  };

  go-farm = buildFromGitHub {
    version = 2;
    rev = "83948bc0eb076b6b72c28abe5282fa8cf5240db6";
    owner  = "dgryski";
    repo   = "go-farm";
    sha256 = "1pmai6x37k7qfggzzg12qhm0qg974rbkw43vv1pcqmw8fcljqg00";
    date = "2016-12-02";
  };

  go-flags = buildFromGitHub {
    version = 2;
    rev = "v1.2.0";
    owner  = "jessevdk";
    repo   = "go-flags";
    sha256 = "0cv6vf1vwysblni8lzy0lmyi7fkgqh8jsz4rwn6rvds9n1481nf5";
  };

  go-floodsub = buildFromGitHub {
    version = 2;
    rev = "54f07fdf3c3de6526b986cf6260437b7cd8187f9";
    owner  = "libp2p";
    repo   = "go-floodsub";
    sha256 = "1jhypw45jm9vg5hy6ql1jn1gagbvyxq59c8aircqjdka2a5mz75l";
    date = "2017-03-25";
    propagatedBuildInputs = [
      gogo_protobuf
      go-libp2p-host
      go-libp2p-net
      go-libp2p-peer
      go-libp2p-protocol
      go-log
      go-multiaddr
      timecache
    ];
  };

  go-getter = buildFromGitHub {
    version = 2;
    rev = "e48f67b534e614bf7fbd978fd0020f61a17b7527";
    date = "2017-04-05";
    owner = "hashicorp";
    repo = "go-getter";
    sha256 = "14yhin5rm6nn72486410fx3vc5rbk7rnkfbv4v1952a44z71mc4r";
    propagatedBuildInputs = [
      aws-sdk-go
      go-homedir
      go-netrc
      go-version
    ];
  };

  go-git-ignore = buildFromGitHub {
    version = 2;
    rev = "87c28ffedb6cb7ff29ae89e0440e9ddee0d95a9e";
    date = "2016-12-22";
    owner = "sabhiram";
    repo = "go-git-ignore";
    sha256 = "1c8nsr9c2lnfc7d57wdmszkmk29jd3f82mnc1334dnlz5qls8rbc";
  };

  go-github = buildFromGitHub {
    version = 2;
    date = "2017-04-25";
    rev = "e8d46665e050742f457a58088b1e6b794b2ae966";
    owner = "google";
    repo = "go-github";
    sha256 = "0y6fh1s7bvsn96irfhpq6nyy1p1wccii5dycg7f8zaasxb1asdnf";
    buildInputs = [
      appengine
      oauth2
    ];
    propagatedBuildInputs = [
      go-querystring
    ];
  };

  go-grpc-prometheus = buildFromGitHub {
    version = 2;
    rev = "2500245aa6110c562d17020fb31a2c133d737799";
    owner = "grpc-ecosystem";
    repo = "go-grpc-prometheus";
    sha256 = "143jhgq0jx8h3a6l58r1h213b52vjgh52avdpgrmxw0r4761d3i4";
    propagatedBuildInputs = [
      grpc
      net
      prometheus_client_golang
    ];
    date = "2017-03-30";
  };

  go-homedir = buildFromGitHub {
    version = 2;
    date = "2016-12-03";
    rev = "b8bc1bf767474819792c23f32d8286a45736f1c6";
    owner  = "mitchellh";
    repo   = "go-homedir";
    sha256 = "18j4j5zpxlpqqbdcl7d7cl69gcj747wq3z2m58lb99376w4a5xm6";
  };

  go-homedir_minio = buildFromGitHub {
    version = 2;
    owner = "minio";
    repo = "go-homedir";
    date = "2016-02-15";
    rev = "0b1069c753c94b3633cc06a1995252dbcc27c7a6";
    sha256 = "0e595179466b94fcf18515a1791319cbfdd60b3e12b06dfc2cc7778a79a201c7";
  };

  hailocab_go-hostpool = buildFromGitHub {
    version = 1;
    rev = "e80d13ce29ede4452c43dea11e79b9bc8a15b478";
    date = "2016-01-25";
    owner  = "hailocab";
    repo   = "go-hostpool";
    sha256 = "06ic8irabl0iwhmkyqq4wzq1d4pgp9vk1kmflgv1wd5d9q8qmkgf";
  };

  gohtml = buildFromGitHub {
    version = 2;
    owner = "yosssi";
    repo = "gohtml";
    rev = "1d8dc9c914ff4253a3af95c1891d809210245e69";
    date = "2017-02-06";
    sha256 = "12rnpnl6df52ahzcl8xfx5akhahnzj9y16zkgfipiasw8w248pl0";
    propagatedBuildInputs = [
      net
    ];
  };

  go-humanize = buildFromGitHub {
    version = 2;
    rev = "259d2a102b871d17f30e3cd9881a642961a1e486";
    owner = "dustin";
    repo = "go-humanize";
    sha256 = "17mic4dp33ki0hv7snj5y6q96lh357gswzikbj1pqnkgia0hxbqf";
    date = "2017-02-28";
  };

  go-i18n = buildFromGitHub {
    version = 2;
    rev = "v1.8.0";
    owner  = "nicksnyder";
    repo   = "go-i18n";
    sha256 = "17wi361lgb19bn47bvwyazgax91zm5nl0g9sy0hw51pcgr7abvf4";
    buildInputs = [
      go-toml
      yaml_v2
    ];
  };

  go-immutable-radix = buildFromGitHub {
    version = 2;
    date = "2017-02-13";
    rev = "30664b879c9a771d8d50b137ab80ee0748cb2fcc";
    owner = "hashicorp";
    repo = "go-immutable-radix";
    sha256 = "1akj47vd7p8ysa4apiqhp7s110ms40y10sg0k84yy3n323yyx4mj";
    propagatedBuildInputs = [ golang-lru ];
  };

  go-ipfs-api = buildFromGitHub {
    version = 2;
    rev = "e577e1054cd11374e1f31c4082ce6952916271c3";
    owner  = "ipfs";
    repo   = "go-ipfs-api";
    sha256 = "0b9qw6jx5p303kxd34di6kz4gbvyh4yvgcyc5g3z4vvi17vymlrp";
    excludedPackages = "tests";
    propagatedBuildInputs = [
      go-floodsub
      go-libp2p-peer
      go-multiaddr
      go-multiaddr-net
      go-multipart-files
      tar-utils
    ];
    meta.useUnstable = true;
    date = "2017-04-16";
  };

  go-ipfs-util = buildFromGitHub {
    version = 2;
    rev = "f25fcc891281327394bb48000ef0970d11baff2b";
    owner  = "ipfs";
    repo   = "go-ipfs-util";
    sha256 = "0bcfrsii05cgqnx94hcy07h71l00fr0vchyqirj9096yycgyzyz4";
    date = "2017-03-28";
    buildInputs = [
      go-base58
      go-multihash
    ];
  };

  go-isatty = buildFromGitHub {
    version = 2;
    rev = "v0.0.2";
    owner  = "mattn";
    repo   = "go-isatty";
    sha256 = "1i54jlw90c03c05zifdpsv0mvnbv5q5qs6v0cnjan91smhag4y5x";
    buildInputs = [
      sys
    ];
  };

  go-jmespath = buildFromGitHub {
    version = 1;
    rev = "bd40a432e4c76585ef6b72d3fd96fb9b6dc7b68d";
    owner = "jmespath";
    repo = "go-jmespath";
    sha256 = "1jiz511xlndrai7xkpvr045x7fsda030240gcwjc4yg4y36ck8cg";
    date = "2016-08-03";
  };

  go-jose_v1 = buildFromGitHub {
    version = 2;
    rev = "v1.1.0";
    owner = "square";
    repo = "go-jose";
    sha256 = "b2dac3e4693bbf2ef11c8afd6aec838479acb789c1d156084776e68488bbd64e";
    goPackagePath = "gopkg.in/square/go-jose.v1";
    buildInputs = [
      urfave_cli
      kingpin_v2
    ];
    meta.autoUpdate = false;
  };

  go-jose_v2 = buildFromGitHub {
    version = 2;
    rev = "v2.1.0";
    owner = "square";
    repo = "go-jose";
    sha256 = "0pwclkx1297d9mv835pk82sgsr1a3xjxi1flx9m28kl50rambcwm";
    goPackagePath = "gopkg.in/square/go-jose.v2";
    buildInputs = [
      urfave_cli
      kingpin_v2
    ];
  };

  go-keyspace = buildFromGitHub {
    version = 2;
    rev = "5b898ac5add1da7178a4a98e69cb7b9205c085ee";
    owner = "whyrusleeping";
    repo = "go-keyspace";
    sha256 = "1kf9gyrhfjhqckziaag8qg5kyyy2zmkfz33wmf9c6p6xqypg0bx7";
    date = "2016-03-22";
  };

  go-libp2p-crypto = buildFromGitHub {
    version = 2;
    owner = "libp2p";
    repo = "go-libp2p-crypto";
    date = "2017-03-24";
    rev = "44f2577a272ee92e8597dc08213bf86e1ee21007";
    sha256 = "05l5gqiw6s666cah76p2w1w16jnjdvjgjn5smfxd26cgsyi1d655";
    propagatedBuildInputs = [
      btcd
      ed25519
      go-base58
      go-ipfs-util
      go-multihash
      gogo_protobuf
    ];
  };

  go-libp2p-host = buildFromGitHub {
    version = 2;
    owner = "libp2p";
    repo = "go-libp2p-host";
    date = "2017-03-24";
    rev = "f8f42d4bd009c695860e920525e5df659924ba00";
    sha256 = "167lpqjfxzpj2c698mmlhprh92iykvzv86mwadzqz32almd7clm4";
    propagatedBuildInputs = [
      go-libp2p-net
      go-libp2p-peer
      go-libp2p-peerstore
      go-libp2p-protocol
      go-multiaddr
      go-multistream
      go-semver
    ];
  };

  go-libp2p-interface-conn = buildFromGitHub {
    version = 2;
    owner = "libp2p";
    repo = "go-libp2p-interface-conn";
    date = "2017-03-24";
    rev = "95afdbf0c900237f3b9104f1f7cfd3d56175a241";
    sha256 = "0yxq323kzh2skn1z416g4zb7hmlk5vm9p9l91b8qd99sv7d9jcb9";
    propagatedBuildInputs = [
      go-ipfs-util
      go-libp2p-crypto
      go-libp2p-peer
      go-libp2p-transport
      go-maddr-filter
      go-multiaddr
    ];
  };

  go-libp2p-net = buildFromGitHub {
    version = 2;
    owner = "libp2p";
    repo = "go-libp2p-net";
    date = "2017-04-01";
    rev = "dcad67edbe37dbedcfdb84712ac0fa4c589a5dd3";
    sha256 = "06gz8qcdi4ny9gw7rbv100bq56bqyh9hx05gf8vf2q7cl5xq1w5v";
    propagatedBuildInputs = [
      goprocess
      go-libp2p-interface-conn
      go-libp2p-peer
      go-libp2p-peerstore
      go-libp2p-protocol
      go-multiaddr
    ];
  };

  go-libp2p-peer = buildFromGitHub {
    version = 2;
    owner = "libp2p";
    repo = "go-libp2p-peer";
    date = "2017-03-24";
    rev = "c497a0cf30b2c123a8b46641aa1a420f381581a4";
    sha256 = "02frzv7vld93yidpkkpcj4ql9mnpzl7594mw9681apay8fr4bri1";
    propagatedBuildInputs = [
      go-base58
      go-ipfs-util
      go-libp2p-crypto
      go-log
      go-multihash
    ];
  };

  go-libp2p-peerstore = buildFromGitHub {
    version = 2;
    owner = "libp2p";
    repo = "go-libp2p-peerstore";
    date = "2017-04-01";
    rev = "17c346214383b10eb0f5b4cd9e578af8ce18441b";
    sha256 = "1jajmyp1spj6h7d6pr9dj1vf2ifrwvzb9x6bnrgbmfhjr29r2c88";
    excludedPackages = "test";
    propagatedBuildInputs = [
      go-libp2p-crypto
      go-libp2p-peer
      go-log
      go-keyspace
      go-multiaddr
      go-multiaddr-net
      mafmt
    ];
  };

  go-libp2p-protocol = buildFromGitHub {
    version = 2;
    owner = "libp2p";
    repo = "go-libp2p-protocol";
    date = "2016-10-11";
    rev = "40488c03777c16bfcd65da2f675b192863cbc2dc";
    sha256 = "0mxs1x3cs0srrb2cvqbd2h0361gjhzz9xb7n6pjq013vnq6dyf03";
  };

  go-libp2p-transport = buildFromGitHub {
    version = 2;
    owner = "libp2p";
    repo = "go-libp2p-transport";
    date = "2017-03-24";
    rev = "5d3cb5861b59c26052a5fe184e45c381ec17e22d";
    sha256 = "1w20p1gbw87q8z4scrc9f49vnjq2nci8gff3wv1aw5xkrn1ci387";
    propagatedBuildInputs = [
      go-log
      go-multiaddr
      go-multiaddr-net
      mafmt
    ];
  };

  go-log = buildFromGitHub {
    version = 2;
    owner = "ipfs";
    repo = "go-log";
    date = "2017-03-16";
    rev = "48d644b006ba26f1793bffc46396e981801078e3";
    sha256 = "1s2kjgrg12r1lpickn8qxvi3642rf34i17gda3jwzwn2gp9jyyvr";
    propagatedBuildInputs = [
      whyrusleeping_go-logging
    ];
  };

  whyrusleeping_go-logging = buildFromGitHub {
    version = 2;
    owner = "whyrusleeping";
    repo = "go-logging";
    date = "2016-12-07";
    rev = "0a5b4a6decf577ce8293eca85ec733d7ab92d742";
    sha256 = "057iwrmlhjnr4w9f9nhndicldv8h4007rxblr7l16rpkbski00wb";
  };

  go-logging = buildFromGitHub {
    version = 2;
    owner = "op";
    repo = "go-logging";
    date = "2016-03-15";
    rev = "970db520ece77730c7e4724c61121037378659d9";
    sha256 = "8087016a076abb7ab630f22c6e2b0ae8ce310350aad9792123c7842b299f87a7";
  };

  go-lxc_v2 = buildFromGitHub {
    version = 2;
    rev = "8304875cc3423823032ec93556beee076c6ba687";
    owner  = "lxc";
    repo   = "go-lxc";
    sha256 = "12qh3qsaxfidmh0yjhqwq4rjagr6nlqi3m4cgilwhndglqy969sn";
    goPackagePath = "gopkg.in/lxc/go-lxc.v2";
    buildInputs = [
      pkgs.lxc
    ];
    date = "2017-03-11";
  };

  go-lz4 = buildFromGitHub {
    version = 2;
    rev = "7224d8d8f27ef618c0a95f1ae69dbb0488abc33a";
    owner  = "bkaradzic";
    repo   = "go-lz4";
    sha256 = "1hbbagvmq7kxrlwqkn0i4mz66i3n37ch7y6bm9yncnjgd97kldms";
    date = "2016-09-24";
  };

  go-maddr-filter = buildFromGitHub {
    version = 2;
    owner = "libp2p";
    repo = "go-maddr-filter";
    date = "2017-03-24";
    rev = "90aacb5ee155f0d6f3fa8b34d775de842606c0b1";
    sha256 = "02dpignagmapwl48smmippzrshrw8jmhpsfrkv44d46fwxm7wvk2";
    propagatedBuildInputs = [
      go-multiaddr
      go-multiaddr-net
    ];
  };

  go-md2man = buildFromGitHub {
    version = 2;
    owner = "cpuguy83";
    repo = "go-md2man";
    rev = "v1.0.6";
    sha256 = "1i67z76plrd7ygk66691bgarcx5kfkf1ryvcwdaa099hbliwbai8";
    propagatedBuildInputs = [
      blackfriday
    ];
  };

  go-memdb = buildFromGitHub {
    version = 2;
    date = "2017-04-11";
    rev = "ed59a4bb9146689d4b00d060b70b9e9648b523af";
    owner = "hashicorp";
    repo = "go-memdb";
    sha256 = "0g0lyv0b3vyy51hl4a9jciplfskrj0r2pixa8jrrpy21pfcqb5wd";
    propagatedBuildInputs = [
      go-immutable-radix
    ];
  };

  rcrowley_go-metrics = buildFromGitHub {
    version = 2;
    rev = "1f30fe9094a513ce4c700b9a54458bbb0c96996c";
    date = "2016-11-28";
    owner = "rcrowley";
    repo = "go-metrics";
    sha256 = "1bz5x3i4xr1nnlknliqy5v2544qmr2jw7qb9ssdr9w68l330fpaa";
    propagatedBuildInputs = [ stathat ];
  };

  armon_go-metrics = buildFromGitHub {
    version = 2;
    date = "2017-01-14";
    rev = "93f237eba9b0602f3e73710416558854a81d9337";
    owner = "armon";
    repo = "go-metrics";
    sha256 = "0f1c24krssll6k90ldf3hzf362r05km8j88riqj5lp6m4yxc4dka";
    propagatedBuildInputs = [
      circonus-gometrics
      datadog-go
      prometheus_client_golang
    ];
  };

  go-metro = buildFromGitHub {
    version = 2;
    date = "2015-06-07";
    rev = "d5cb643948fbb1a699e6da1426f0dba75fe3bb8e";
    owner = "dgryski";
    repo = "go-metro";
    sha256 = "5d271cba19ad6aa9b0aaca7e7de6d5473eb4a9e4b682bbb1b7a4b37cca9bb706";
    meta.autoUpdate = false;
  };

  go-mssqldb = buildFromGitHub {
    version = 2;
    rev = "e3bd523cf238e14637d0e028becc25651098a138";
    owner = "denisenkom";
    repo = "go-mssqldb";
    sha256 = "025n6h2dsknpp3jban8j6ad4gccy7k1yw0cv7r0dkxabvcxxinps";
    date = "2017-04-23";
    buildInputs = [
      crypto
      net
    ];
  };

  go-multiaddr = buildFromGitHub {
    version = 2;
    rev = "33741da7b3f5773a599d4a03c333704fc560ef34";
    date = "2017-03-24";
    owner  = "multiformats";
    repo   = "go-multiaddr";
    sha256 = "0i3cykfdi7mdak64pkk7zv9kfi01xi1ji3lyy4nzjwqwcwgy3kvg";
    goPackageAliases = [ "github.com/jbenet/go-multiaddr" ];
    propagatedBuildInputs = [
      go-multihash
    ];
  };

  go-multiaddr-net = buildFromGitHub {
    version = 2;
    rev = "a7b93d11855f04f56908e1385991eb6a400fcc43";
    owner  = "multiformats";
    repo   = "go-multiaddr-net";
    sha256 = "0g2q84a3470kpqiyv9jsg77vyrfnbiv78g99b7g68plvgkqb10g3";
    date = "2017-03-28";
    goPackageAliases = [ "github.com/jbenet/go-multiaddr-net" ];
    propagatedBuildInputs = [
      go-multiaddr
      utp
    ];
  };

  go-multierror = buildFromGitHub {
    version = 2;
    date = "2016-12-16";
    rev = "ed905158d87462226a13fe39ddf685ea65f1c11f";
    owner  = "hashicorp";
    repo   = "go-multierror";
    sha256 = "1lvmjf3mb1qx295djzddzj8w1j86c0cklkg19kfmzr5cbk257rzc";
    propagatedBuildInputs = [
      errwrap
    ];
  };

  go-multihash = buildFromGitHub {
    version = 2;
    rev = "625115a7fb33ddfafa3efe3ccfef9cfe459936b3";
    owner  = "multiformats";
    repo   = "go-multihash";
    sha256 = "1zi395jd0hjm19pl4ypmf2761lzn1c1dn3im5865f7fmzpkjpbzy";
    goPackageAliases = [ "github.com/jbenet/go-multihash" ];
    propagatedBuildInputs = [
      crypto
      go-base58
      go-ethereum
      hashland
      murmur3
    ];
    date = "2017-04-24";
  };

  go-multipart-files = buildFromGitHub {
    version = 1;
    rev = "3be93d9f6b618f2b8564bfb1d22f1e744eabbae2";
    owner  = "whyrusleeping";
    repo   = "go-multipart-files";
    sha256 = "0fdzi6v6rshh172hzxf8v9qq3d36nw3gc7g7d79wj88pinnqf5by";
    date = "2015-09-03";
  };

  go-multistream = buildFromGitHub {
    version = 2;
    rev = "b8f1996688ab586031517919b49b1967fca8d5d9";
    date = "2017-03-17";
    owner  = "multiformats";
    repo   = "go-multistream";
    sha256 = "0110p4bk3m9xri96bn65kfibi5ir0ima6xbfsv7m8drijgzjyx3a";
  };

  go-nat-pmp = buildFromGitHub {
    version = 1;
    rev = "452c97607362b2ab5a7839b8d1704f0396b640ca";
    owner  = "AudriusButkevicius";
    repo   = "go-nat-pmp";
    sha256 = "0jjwqvanxxs15nhnkdx0mybxnyqm37bbg6yy0jr80czv623rp2bk";
    date = "2016-05-22";
    buildInputs = [
      gateway
    ];
  };

  go-netrc = buildFromGitHub {
    version = 2;
    owner = "bgentry";
    repo = "go-netrc";
    date = "2014-05-22";
    rev = "9fd32a8b3d3d3f9d43c341bfe098430e07609480";
    sha256 = "68984543a73f4d7ad4b58708207a483bd74fc9388ac582eac532434b11361a9e";
  };

  go-oidc = buildFromGitHub {
    version = 2;
    date = "2017-04-25";
    rev = "5157aa730c25a7531d4b99483e6a440d4ab735a0";
    owner  = "coreos";
    repo   = "go-oidc";
    sha256 = "06l3ma8gfkyicgs5xa5iyz498kwg9k1rd6hqdj82kafmfpds53v3";
    propagatedBuildInputs = [
      cachecontrol
      clockwork
      go-jose_v2
      net
      oauth2
      pkg
    ];
  };

  go-okta = buildFromGitHub {
    version = 2;
    rev = "388b6aef4eed400621bd3e3a98d831ef1368582d";
    owner = "sstarcher";
    repo = "go-okta";
    sha256 = "0pqabxarh1hm4r2bwmhp8zlp6k7rf4dypp82pia97nspnisr94dc";
    date = "2016-10-03";
  };

  go-ole = buildFromGitHub {
    version = 2;
    date = "2017-02-09";
    rev = "de8695c8edbf8236f30d6e1376e20b198a028d42";
    owner  = "go-ole";
    repo   = "go-ole";
    sha256 = "127k5hw9ghsqwqfnxirlzf7zvzgb13g1x41654bg533857j2491p";
    excludedPackages = "example";
  };

  go-os-rename = buildFromGitHub {
    version = 1;
    rev = "3ac97f61ef67a6b87b95c1282f6c317ed0e693c2";
    owner  = "jbenet";
    repo   = "go-os-rename";
    sha256 = "0y8rq0y654lcyl7ysijni75j8fpq4hhqnh9qiy2z4hvmnzvb85id";
    date = "2015-04-28";
  };

  go-ovh = buildFromGitHub {
    version = 2;
    rev = "d2207178e10e4527e8f222fd8707982df8c3af17";
    owner = "ovh";
    repo = "go-ovh";
    sha256 = "1kx6n608vwr7njbc59wgbpvwflq1haw7vp6qaa2ymbvjkn1b9ypv";
    date = "2017-01-02";
    propagatedBuildInputs = [
      ini_v1
    ];
  };

  go-plugin = buildFromGitHub {
    version = 2;
    rev = "1ffca25a1118915effa6d7585a0550fec8cb44fd";
    date = "2017-04-19";
    owner  = "hashicorp";
    repo   = "go-plugin";
    sha256 = "1rsra14fl9ml6grdsjm658gsysfcgzkhjdf6kr3i8qr5m7biqi8k";
    buildInputs = [ yamux ];
  };

  go-ps = buildFromGitHub {
    version = 2;
    rev = "4fdf99ab29366514c69ccccddab5dc58b8d84062";
    date = "2017-03-09";
    owner  = "mitchellh";
    repo   = "go-ps";
    sha256 = "1x70gc6y9licdi6qww1lkwx1wkwwkqylzhkfl0wpnizl8m7vpdmp";
  };

  go-python = buildFromGitHub {
    version = 2;
    owner = "sbinet";
    repo = "go-python";
    date = "2017-03-14";
    rev = "ba7e58341058bdefb92b359870caf2dc0a05cfcf";
    sha256 = "1jkkkg5nrdqz6iv6bzlbxg7gycmq4bjc5mrpw3r3lvzqn73sdga7";
    nativeBuildInputs = [
      pkgs.pkgconfig
    ];
    buildInputs = [
      pkgs.python2Packages.python
    ];
  };

  go-querystring = buildFromGitHub {
    version = 2;
    date = "2017-01-11";
    rev = "53e6ce116135b80d037921a7fdd5138cf32d7a8a";
    owner  = "google";
    repo   = "go-querystring";
    sha256 = "1ibpx1hpqjkvcmn4gsz54k9p62sl1iac2kgb97spcl630nn4p0yj";
  };

  go-radix = buildFromGitHub {
    version = 1;
    rev = "4239b77079c7b5d1243b7b4736304ce8ddb6f0f2";
    owner  = "armon";
    repo   = "go-radix";
    sha256 = "0b5vksrw462w1j5ipsw7fmswhpnwsnaqgp6klw714dc6ppz57aqv";
    date = "2016-01-15";
  };

  go-restful = buildFromGitHub {
    version = 2;
    rev = "ff4f55a206334ef123e4f79bbf348980da81ca46";
    owner = "emicklei";
    repo = "go-restful";
    sha256 = "1rj2mklgkx5y5h8qr4jxxxd2h1l2pp78mvf4770iw494af13dbpi";
    date = "2017-04-10";
  };

  go-restful-swagger12 = buildFromGitHub {
    version = 2;
    rev = "1.0.1";
    owner = "emicklei";
    repo = "go-restful-swagger12";
    sha256 = "1ngfny928f2prwn1dgsih0z3fdhwqnnix89n045pk5q56dpd8b5s";
    goPackageAliases = [
      "github.com/emicklei/go-restful/swagger"
    ];
    propagatedBuildInputs = [
      go-restful
    ];
  };

  go-retryablehttp = buildFromGitHub {
    version = 2;
    rev = "2d5f5dbd904dbad432492c3ca2c12c72c9e3045a";
    owner = "hashicorp";
    repo = "go-retryablehttp";
    sha256 = "1jdjjk5lrrkss81cinb092i4c63nzs0xra08p6zwz2ny9b6a5z54";
    date = "2017-04-21";
    propagatedBuildInputs = [
      go-cleanhttp
    ];
  };

  go-rootcerts = buildFromGitHub {
    version = 1;
    rev = "6bb64b370b90e7ef1fa532be9e591a81c3493e00";
    owner = "hashicorp";
    repo = "go-rootcerts";
    sha256 = "0wi9ar5av0s4a2xarxh360kml3nkicrcdzzmhq1d406p10c3qjp2";
    date = "2016-05-03";
    buildInputs = [
      go-homedir
    ];
  };

  go-runewidth = buildFromGitHub {
    version = 2;
    rev = "v0.0.2";
    owner = "mattn";
    repo = "go-runewidth";
    sha256 = "1j99da81h9s528g3lmhgy1pvmzhhcxl8g3p9dzg8byxdsvjadxia";
  };

  go-semver = buildFromGitHub {
    version = 2;
    rev = "5e3acbb5668c4c3deb4842615c4098eb61fb6b1e";
    owner  = "coreos";
    repo   = "go-semver";
    sha256 = "1msmlbkv0mp25p0x74d1k8l1zrkz1prs9mcxhck77inzckq4fg81";
    date = "2017-02-09";
  };

  go-shellwords = buildFromGitHub {
    version = 2;
    rev = "v1.0.3";
    owner  = "mattn";
    repo   = "go-shellwords";
    sha256 = "11prxlsk3kwgq6v5ikdsjv5vjv4hfihvw55qc27jip1ia2grcxvz";
  };

  go-simplejson = buildFromGitHub {
    version = 2;
    rev = "da1a8928f709389522c8023062a3739f3b4af419";
    owner  = "bitly";
    repo   = "go-simplejson";
    sha256 = "0qrqmhi7wng3nb42ch4pp7xly2yia8grg3mkifqnra5d9pr7q91j";
    date = "2017-02-06";
  };

  go-snappy = buildFromGitHub {
    version = 1;
    rev = "d8f7bb82a96d89c1254e5a6c967134e1433c9ee2";
    owner  = "siddontang";
    repo   = "go-snappy";
    sha256 = "18ikmwl43nqdphvni8z15jzhvqksqfbk8rspwd11zy24lmklci7b";
    date = "2014-07-04";
  };

  go-sockaddr = buildFromGitHub {
    version = 2;
    rev = "acd314c5781ea706c710d9ea70069fd2e110d61d";
    owner  = "hashicorp";
    repo   = "go-sockaddr";
    sha256 = "14pgn6b8wy69b71n5sc5s10nf8c25rn2ln436acbrsphzhav627v";
    date = "2017-03-24";
    propagatedBuildInputs = [
      mitchellh_cli
      columnize
      errwrap
      go-wordwrap
    ];
  };

  go-spew = buildFromGitHub {
    version = 2;
    rev = "v1.1.0";
    owner  = "davecgh";
    repo   = "go-spew";
    sha256 = "1a3hlwra1nbd6pl37dqj82i2q6vy36fdab31z4nj59gpgji35zy3";
  };

  go-sqlite3 = buildFromGitHub {
    version = 2;
    rev = "v1.2.0";
    owner  = "mattn";
    repo   = "go-sqlite3";
    sha256 = "0s6s46achp1dczxcp9fw3n71wkhw8y5x5kd8izyllygrbs56h28c";
    excludedPackages = "test";
    buildInputs = [
      goquery
    ];
    propagatedBuildInputs = [
      net
    ];
  };

  go-stun = buildFromGitHub {
    version = 2;
    rev = "04a4eed61c57ecc9903f8983d1d2c17b88d2e9e1";
    owner  = "ccding";
    repo   = "go-stun";
    sha256 = "1sadm5cr2108z25glyvsdkkxf8pr0jis67vyv56bbk01bqpvgkql";
    date = "2017-03-23";
  };

  go-syslog = buildFromGitHub {
    version = 2;
    date = "2016-12-13";
    rev = "b609c7d9de4658cded34a7336b90886c56f9dbdb";
    owner  = "hashicorp";
    repo   = "go-syslog";
    sha256 = "0py0lgqxcwyjhjl68bi6psrgs0vqhd38nd06jihk235wdxq6149a";
  };

  go-systemd = buildFromGitHub {
    version = 2;
    rev = "1f9909e51b2dab2487c26d64c8f2e7e580e4c9f5";
    owner = "coreos";
    repo = "go-systemd";
    sha256 = "0xfagwn3hd3j5x4bzsl0i10jxlf3azjh7s3cxacy9bghj1zzp0g9";
    propagatedBuildInputs = [
      dbus
      pkg
      pkgs.systemd_lib
    ];
    date = "2017-03-24";
  };

  go-systemd_journal = buildFromGitHub {
    inherit (go-systemd) rev owner repo sha256 version date;
    subPackages = [
      "journal"
    ];
  };

  go-toml = buildFromGitHub {
    version = 2;
    owner = "pelletier";
    repo = "go-toml";
    rev = "fe206efb84b2bc8e8cfafe6b4c1826622be969e3";
    sha256 = "0jq9vg62knhqmkikmbcccjgrkj68fma80lm6dgn4mdambn255izk";
    propagatedBuildInputs = [
      go-buffruneio
    ];
    meta.useUnstable = true;
    date = "2017-04-05";
  };

  go-units = buildFromGitHub {
    version = 2;
    rev = "0dadbb0345b35ec7ef35e228dabb8de89a65bf52";
    owner = "docker";
    repo = "go-units";
    sha256 = "19xnz75m0qmydh2pgcgb6im6hmp4606jwagfxf892rs446vn2wqi";
    date = "2017-01-27";
  };

  go-unsnap-stream = buildFromGitHub {
    version = 2;
    rev = "87275cecd8e984c5875577d22da7ce8945df780e";
    owner = "glycerine";
    repo = "go-unsnap-stream";
    sha256 = "1bgwgfg34s3zb39g2ifp5sj65gibvsj9b82dy05vk6wv9zxqh5n2";
    date = "2016-12-13";
    propagatedBuildInputs = [
      snappy
    ];
  };

  hashicorp_go-uuid = buildFromGitHub {
    version = 1;
    rev = "64130c7a86d732268a38cb04cfbaf0cc987fda98";
    date = "2016-07-16";
    owner  = "hashicorp";
    repo   = "go-uuid";
    sha256 = "072c84wn90di09qxrg0ml8vjfb5k10zk2n4k0rgxk1n45wyghkjx";
  };

  go-version = buildFromGitHub {
    version = 2;
    rev = "03c5bf6be031b6dd45afec16b1cf94fc8938bc77";
    owner  = "hashicorp";
    repo   = "go-version";
    sha256 = "0py0cmlj4c1zfxnszr0jqgvqgrpa1iwk8r0iai5p0vvzf4zafbkj";
    date = "2017-02-02";
  };

  go-winio = buildFromGitHub {
    version = 2;
    rev = "v0.3.9";
    owner  = "Microsoft";
    repo   = "go-winio";
    sha256 = "0v172ar2aa1m1wyb60i87vcmcng39xz4fpscpzwah9p73i7x64wq";
    buildInputs = [
      sys
    ];
  };

  go-wordwrap = buildFromGitHub {
    version = 2;
    rev = "ad45545899c7b13c020ea92b2072220eefad42b8";
    owner  = "mitchellh";
    repo   = "go-wordwrap";
    sha256 = "0yj17x3c1mr9l3q4dwvy8y2xgndn833rbzsjf10y48yvr12zqjd0";
    date = "2015-03-14";
  };

  go-zookeeper = buildFromGitHub {
    version = 2;
    rev = "1d7be4effb13d2d908342d349d71a284a7542693";
    date = "2016-10-28";
    owner  = "samuel";
    repo   = "go-zookeeper";
    sha256 = "15jwlcscvqpj6yfsjmi7735q45zn5pv1h0by3dzggfry6y0h44fs";
  };

  goconfig = buildFromGitHub {
    version = 2;
    owner = "Unknwon";
    repo = "goconfig";
    rev = "87a46d97951ee1ea20ed3b24c25646a79e87ba5d";
    date = "2016-11-21";
    sha256 = "4b1e8153d3bcaa0e5f929b1cd09e4fb780a4753d4aaf8df12b4915c6a65eb70a";
  };

  gorequest = buildFromGitHub {
    version = 2;
    owner = "parnurzeal";
    repo = "gorequest";
    rev = "v0.2.15";
    sha256 = "0r3jidgjrnh43slhxhggwy11ka90gd05blsh102x48di7pxz3kn8";
    propagatedBuildInputs = [
      errors
      http2curl
      net
    ];
  };

  grafana = buildFromGitHub {
    version = 2;
    owner = "grafana";
    repo = "grafana";
    rev = "v4.2.0";
    sha256 = "125m7l1wad5sffkpfyzggybvwca01syyi5bh0pyz05q3b0d4razx";
    buildInputs = [
      amqp
      aws-sdk-go
      binding
      urfave_cli
      color
      goreq
      go-spew
      go-sqlite3
      go-version
      gzip
      inject
      ini_v1
      ldap
      log15
      macaron_v1
      net
      oauth2
      session
      slug
      toml
      websocket
      xorm
    ];
  };

  graphite-golang = buildFromGitHub {
    version = 2;
    owner = "marpaia";
    repo = "graphite-golang";
    date = "2016-11-29";
    rev = "c474c9b821b4d0a4574edc6412b0003fbce233c4";
    sha256 = "0gvm8x29y4y2cv358hr1cs6sr8p6snbcmnmag6pa0a2sjwahj7i0";
  };

  groupcache = buildFromGitHub {
    version = 2;
    date = "2017-04-21";
    rev = "b710c8433bd175204919eb38776e944233235d03";
    owner  = "golang";
    repo   = "groupcache";
    sha256 = "1vjwgr23yf206l4hymdnr3lczlq6v7q5yr5wh20v7m4dd63362k2";
    buildInputs = [ protobuf ];
  };

  grpc = buildFromGitHub {
    version = 3;
    date = "2017-04-27";
    rev = "277e90a4321cba6ad9f9ca4a832165265002c3a5";
    owner = "grpc";
    repo = "grpc-go";
    sha256 = "18x55b85w5v05h3772b9ls630dcwhz7kksgdh78zhm70axan06dx";
    goPackagePath = "google.golang.org/grpc";
    goPackageAliases = [
      "github.com/grpc/grpc-go"
    ];
    excludedPackages = "\\(test\\|benchmark\\)";
    propagatedBuildInputs = [
      genproto_for_grpc
      glog
      net
      oauth2
      protobuf
    ];
    meta.useUnstable = true;
  };

  grpc_for_gax-go = buildFromGitHub {
    inherit (grpc) version date rev owner repo sha256 goPackagePath goPackageAliases meta;
    propagatedBuildInputs = [
      genproto_for_grpc
      net
      protobuf
    ];
    subPackages = [
      "."
      "codes"
      "credentials"
      "grpclb/grpc_lb_v1"
      "grpclog"
      "internal"
      "keepalive"
      "metadata"
      "naming"
      "peer"
      "stats"
      "status"
      "tap"
      "transport"
    ];
  };

  grpc-gateway = buildFromGitHub {
    version = 2;
    rev = "v1.2.2";
    owner = "grpc-ecosystem";
    repo = "grpc-gateway";
    sha256 = "0cd3c038hdkb64myqdq2bhcp6l44bbm1fdd7sb66rkqb461aikkw";
    propagatedBuildInputs = [
      genproto
      glog
      grpc
      net
      protobuf
    ];
  };


  gucumber = buildFromGitHub {
    version = 1;
    date = "2016-07-14";
    rev = "71608e2f6e76fd4da5b09a376aeec7a5c0b5edbc";
    owner = "gucumber";
    repo = "gucumber";
    sha256 = "0ghz0x1zdm1ypp9ycw871r2rcklik84z7pqgs2i88sk2s4m4igar";
    buildInputs = [ testify ];
    propagatedBuildInputs = [ ansicolor ];
  };

  gx = buildFromGitHub {
    version = 2;
    rev = "v0.11.0";
    owner = "whyrusleeping";
    repo = "gx";
    sha256 = "0pmwyscmbbqxdkpzncffn70d01vb7gb0ikg1gnhzkd8nwbx2kqzz";
    propagatedBuildInputs = [
      go-git-ignore
      go-homedir
      go-multiaddr
      go-multihash
      go-multiaddr-net
      go-os-rename
      json-filter
      semver
      stump
      urfave_cli
      go-ipfs-api
    ];
    excludedPackages = [
      "tests"
    ];
  };

  gx-go = buildFromGitHub {
    version = 2;
    rev = "c083961707697e230e779d56b0a3e2ac632139ed";
    owner = "whyrusleeping";
    repo = "gx-go";
    sha256 = "09v2x0y63imy6cfjcs0b1p4ljc1y6267v2mg18jd47k3az8wl24q";
    buildInputs = [
      urfave_cli
      fs
      go-homedir
      gx
      stump
    ];
    date = "2017-04-26";
  };

  gzip = buildFromGitHub {
    version = 1;
    date = "2016-02-21";
    rev = "cad1c6580a07c56f5f6bc52d66002a05985c5854";
    owner = "go-macaron";
    repo = "gzip";
    sha256 = "1myrzvymwxxck5xw9jbm1fp9aazhvqdp2sc2snymvnnlxwc8f0an";
    propagatedBuildInputs = [
      compress
      macaron_v1
    ];
  };

  gziphandler = buildFromGitHub {
    version = 2;
    date = "2017-04-03";
    rev = "22d4470af89e09998fc16b35029df973932df4ae";
    owner = "NYTimes";
    repo = "gziphandler";
    sha256 = "1yb6zq2g3nr3r8c4wp60b9dlfw2rfn422l2x36ym1sikjm5g1gj1";
  };

  hashland = buildFromGitHub {
    version = 2;
    rev = "e13accbe55f7fa03c73c74ace4cca4c425e47260";
    owner  = "tildeleb";
    repo   = "hashland";
    sha256 = "0gws01aq8fy53kljpngs4y5l02aqjm5jd6pa3l7j1h56pk2n2zs8";
    goPackagePath = "leb.io/hashland";
    date = "2016-11-30";
    excludedPackages = "example";
    propagatedBuildInputs = [
      aeshash
      cuckoo
      go-farm
      go-metro
      hrff
    ];
  };

  hashland_for_aeshash = buildFromGitHub {
    version = 2;
    rev = "e13accbe55f7fa03c73c74ace4cca4c425e47260";
    owner  = "tildeleb";
    repo   = "hashland";
    sha256 = "0gws01aq8fy53kljpngs4y5l02aqjm5jd6pa3l7j1h56pk2n2zs8";
    goPackagePath = "leb.io/hashland";
    date = "2016-11-30";
    subPackages = [
      "nhash"
    ];
  };

  handlers = buildFromGitHub {
    version = 2;
    owner = "gorilla";
    repo = "handlers";
    rev = "v1.2";
    sha256 = "12n6brnjmzlrvki6c8cz12vfaqamdk6487viy6swpnaqr9iicf2c";
  };

  hashstructure = buildFromGitHub {
    version = 2;
    date = "2017-01-15";
    rev = "ab25296c0f51f1022f01cd99dfb45f1775de8799";
    owner  = "mitchellh";
    repo   = "hashstructure";
    sha256 = "1w7r9c5sj7g68y0j3v6kkdmh9qmci50bwxn2qk6bnnh1dln4acbr";
  };

  hcl = buildFromGitHub {
    version = 2;
    date = "2017-04-20";
    rev = "7fa7fff964d035e8a162cce3a164b3ad02ad651b";
    owner  = "hashicorp";
    repo   = "hcl";
    sha256 = "124n4cn37hh47wlv3i5qiy0zpd1kf967ni393ly9vmi7byx3k699";
  };

  hdrhistogram = buildFromGitHub {
    version = 2;
    date = "2016-10-09";
    rev = "3a0bb77429bd3a61596f5e8a3172445844342120";
    owner  = "codahale";
    repo   = "hdrhistogram";
    sha256 = "0xnsf0yzh4z1iyl0vcbj97cyl19zq37hvjfz533zq91xglgpghmc";
    propagatedBuildInputs = [
      mgo_v2
    ];
  };

  hil = buildFromGitHub {
    version = 2;
    date = "2016-12-21";
    rev = "5b8d13c8c5c2753e109fab25392a1dbfa2db93d2";
    owner  = "hashicorp";
    repo   = "hil";
    sha256 = "1gc7kw6bp3kaixqbaiga92ywhqs1mrdablp9297kgvbgnhdz44gn";
    propagatedBuildInputs = [
      mapstructure
      reflectwalk
    ];
    meta.useUnstable = true;
  };

  hllpp = buildFromGitHub {
    version = 2;
    owner = "retailnext";
    repo = "hllpp";
    date = "2017-03-17";
    rev = "9fdfea05b3e55bebe7beb22d16c7db15d46cd518";
    sha256 = "0b36yn9si929b2z8p13rz8qf74fmkrkmj4igp6slzc8hniv1606r";
  };

  hotp = buildFromGitHub {
    version = 2;
    rev = "c180d57d286b385101c999a60087a40d7f48fc77";
    owner  = "gokyle";
    repo   = "hotp";
    sha256 = "1sv6fq7nw7crnqn7ycg3f5j3x4g0rahxynjprwh8md3cfj1161xr";
    date = "2016-02-17";
    propagatedBuildInputs = [
      rsc
    ];
  };

  hrff = buildFromGitHub {
    version = 2;
    rev = "0b0f30b52b94f5ed2e21ffd14f537f1094ba8ec6";
    owner  = "tildeleb";
    repo   = "hrff";
    sha256 = "009zlvj9qaxxz1zprhgn5w80qyc5mqr2rifm2q6q6a2j3cvm3ccg";
    goPackagePath = "leb.io/hrff";
    date = "2015-09-06";
  };

  http2curl = buildFromGitHub {
    version = 2;
    owner = "moul";
    repo = "http2curl";
    date = "2016-10-31";
    rev = "4e24498b31dba4683efb9d35c1c8a91e2eda28c8";
    sha256 = "1zzdplidhh77s20l6c51fqvrzppmkf830j7mxdv9lf7z5ry169sp";
  };

  httprouter = buildFromGitHub {
    version = 2;
    rev = "6f3f3919c8781ce5c0509c83fffc887a7830c938";
    owner  = "julienschmidt";
    repo   = "httprouter";
    sha256 = "0l4v5kf84xgjds29h549jisiwlnav5csvcsfwizg8h0r2cj0c6jm";
    date = "2017-03-24";
  };

  hugo = buildFromGitHub {
    version = 2;
    owner = "spf13";
    repo = "hugo";
    rev = "v0.20.5";
    sha256 = "0792g0lnyapnad3q67afx4zigg5iypr1j3gr7da6b08ciz97zay2";
    buildInputs = [
      ace
      afero
      amber
      blackfriday
      cast
      cobra
      cssmin
      emoji
      fsnotify
      fsync
      gitmap
      go-i18n
      go-toml
      goorgeous
      inflect
      jwalterweatherman
      mapstructure
      mmark
      nitro
      osext
      pflag
      purell
      text
      viper
      websocket
      yaml_v2
    ];
  };

  inf_v0 = buildFromGitHub {
    version = 1;
    rev = "v0.9.0";
    owner  = "go-inf";
    repo   = "inf";
    sha256 = "0wqf867vifpfa81a1vhazjgfjjhiykqpnkblaxxj6ppyxlzrs3cp";
    goPackagePath = "gopkg.in/inf.v0";
  };

  inflect = buildFromGitHub {
    version = 1;
    owner = "bep";
    repo = "inflect";
    rev = "b896c45f5af983b1f416bdf3bb89c4f1f0926f69";
    date = "2016-04-08";
    sha256 = "13mjcnh6g7ml0gw24rbkfdjmkznjk4hcwfbxcbj5ydyfl0acq8wn";
  };

  influxdb = buildFromGitHub {
    version = 2;
    owner = "influxdata";
    repo = "influxdb";
    rev = "v1.2.3";
    sha256 = "14ng7c4xrxw897j1iwnl9jp9mn05kaiyzw8c4ww7f6x5la2g948b";
    propagatedBuildInputs = [
      bolt
      crypto
      encoding
      go-bits
      go-bitstream
      go-collectd
      hllpp
      jwt-go
      liner
      pat
      gogo_protobuf
      ratecounter
      snappy
      statik
      sys
      toml
      usage-client
      xxhash
      zap
    ];
    goPackageAliases = [
      "github.com/influxdb/influxdb"
    ];
    postPatch = /* Remove broken tests */ ''
      rm -rf services/collectd/test_client
    '';
  };

  influxdb_client = buildFromGitHub {
    inherit (influxdb) owner repo rev sha256 version;
    goPackageAliases = [
      "github.com/influxdb/influxdb"
    ];
    subPackages = [
      "client"
      "models"
      "pkg/escape"
    ];
  };

  ini = buildFromGitHub {
    version = 2;
    rev = "v1.27.0";
    owner  = "go-ini";
    repo   = "ini";
    sha256 = "0c91p8vcwpz1wl2kjlsv962rfi1kd6jk9b0d265dvcnq296i0vhh";
  };

  ini_v1 = buildFromGitHub {
    version = 2;
    rev = "v1.27.0";
    owner  = "go-ini";
    repo   = "ini";
    goPackagePath = "gopkg.in/ini.v1";
    sha256 = "131i2zpdmm687hm6w6vnz3yk2anc67cbrviiqv4myszkmfnkdap3";
  };

  inject = buildFromGitHub {
    version = 1;
    date = "2016-06-28";
    rev = "d8a0b8677191f4380287cfebd08e462217bac7ad";
    owner = "go-macaron";
    repo = "inject";
    sha256 = "1zb5sw83grna85cgsz7nhwpbkkysnyfc6hzk7gksidf08s8s9dmg";
  };

  internal = buildFromGitHub {
    version = 1;
    rev = "fbe290d56cdd8bb25347df893b14e3454f07bf74";
    owner  = "cznic";
    repo   = "internal";
    sha256 = "0x80s83nq75xajyqspzcgj2mq5gxw9psxghvb676q8y96jn1n10k";
    date = "2016-07-19";
    buildInputs = [
      fileutil
      mathutil
      mmap-go
    ];
  };

  iter = buildFromGitHub {
    version = 1;
    rev = "454541ec3da2a73fc34fd049b19ee5777bf19345";
    owner  = "bradfitz";
    repo   = "iter";
    sha256 = "0sv6rwr05v219j5vbwamfvpp1dcavci0nwr3a2fgxx98pjw7hgry";
    date = "2014-01-23";
  };

  ipfs = buildFromGitHub {
    version = 2;
    rev = "v0.4.8";
    owner = "ipfs";
    repo = "go-ipfs";
    sha256 = "0a02vxgf54qcb0z5ynvvr79gfzsh49mwfs2xdj8xkp8yi38mbbaf";
    gxSha256 = "0p90xn2b50ks59qqr35m5wiqj9q6p4j131bjfnirsp4apcs3s324";
    nativeBuildInputs = [
      gx-go.bin
    ];
    # Prevent our Godeps remover from work here
    preConfigure = ''
      mv Godeps "$TMPDIR"
    '';
    postConfigure = ''
      mv "$TMPDIR/Godeps" "go/src/$goPackagePath"
    '';
    postInstall = ''
      find "$bin"/bin -not -name ipfs\* -mindepth 1 -maxdepth 1 -delete
    '';
  };

  jose = buildFromGitHub {
    version = 2;
    owner = "SermoDigital";
    repo = "jose";
    rev = "2bd9b81ac51d6d6134fcd4fd846bd2e7347a15f9";
    date = "2016-12-05";
    sha256 = "1v5df8nkn34m7md3y8qbm71q7224r1la9r6rp06ah9zsakc8pqkb";
  };

  json-filter = buildFromGitHub {
    version = 1;
    owner = "whyrusleeping";
    repo = "json-filter";
    rev = "ff25329a9528f01c5175414f16cc0a6a162a5b8b";
    date = "2016-06-15";
    sha256 = "0y1d6yi09ac0xlf63qrzxsi7dqf10wha3na633qzqjnpjcga97ck";
  };

  jsonpointer = buildFromGitHub {
    version = 2;
    owner = "go-openapi";
    repo = "jsonpointer";
    rev = "779f45308c19820f1a69e9a4cd965f496e0da10f";
    date = "2017-01-02";
    sha256 = "1kdgq87bns9xzvyyybcdk3hj09l8ic8s758dxldj91jjlbd2cc2x";
    propagatedBuildInputs = [
      swag
    ];
  };

  jsonreference = buildFromGitHub {
    version = 2;
    owner = "go-openapi";
    repo = "jsonreference";
    rev = "36d33bfe519efae5632669801b180bf1a245da3b";
    date = "2016-11-05";
    sha256 = "0xqaz9kwlwj205ma9z7dm3j5ad2cl2cs0mvs3xqw3mvd6p0dmg7h";
    propagatedBuildInputs = [
      jsonpointer
      purell
    ];
  };

  jsonx = buildFromGitHub {
    version = 2;
    owner = "jefferai";
    repo = "jsonx";
    rev = "9cc31c3135eef39b8e72585f37efa92b6ca314d0";
    date = "2016-07-21";
    sha256 = "0s5zani868a70hpacqxl1qzzwc8hdappb99qixmbfkf7wdyyzfic";
    propagatedBuildInputs = [
      gabs
    ];
  };

  jwalterweatherman = buildFromGitHub {
    version = 2;
    owner = "spf13";
    repo = "jWalterWeatherman";
    rev = "fa7ca7e836cf3a8bb4ebf799f472c12d7e903d66";
    date = "2017-01-09";
    sha256 = "0qsr7l86vcydaihk5p7051g161i45hrynfh7q8bnyg04rsh6kg71";
    goPackageAliases = [
      "github.com/spf13/jwalterweatherman"
    ];
  };

  jwt-go = buildFromGitHub {
    version = 2;
    owner = "dgrijalva";
    repo = "jwt-go";
    rev = "2268707a8f0843315e2004ee4f1d021dc08baedf";
    sha256 = "164ly3njl7qbd4ddh8slmphwrs7vm7k8p6l5az57qrg3w00aijfy";
    date = "2017-02-01";
  };

  kcp-go = buildFromGitHub {
    version = 2;
    owner = "xtaci";
    repo = "kcp-go";
    rev = "v3.15";
    sha256 = "06b712agm0wfhdnx7n6h7lzpsdqaccmvrwyiwny0gmzjwszrz59w";
    propagatedBuildInputs = [
      crypto
      errors
      net
      reedsolomon
    ];
  };

  gravitational_kingpin = buildFromGitHub {
    version = 2;
    rev = "785686550a08e8e2e77641c91714280a6dfb08ee";
    owner = "gravitational";
    repo = "kingpin";
    sha256 = "0klg0nixdy13r50xkfh7mlhdyfk0x7ymmb1m4l29zj00zmhy07if";
    propagatedBuildInputs = [
      template
      units
    ];
    meta.useUnstable = true;
    date = "2016-02-05";
  };

  kingpin_v2 = buildFromGitHub {
    version = 2;
    rev = "v2.2.4";
    owner = "alecthomas";
    repo = "kingpin";
    sha256 = "1bfayjmh2l2paq306hjdy5k3gjjd8amq4r7w5jmh6w8ymlwwv4aq";
    goPackagePath = "gopkg.in/alecthomas/kingpin.v2";
    propagatedBuildInputs = [
      template
      units
    ];
  };

  kubernetes-client-go_1-4 = buildFromGitHub {
    version = 2;
    rev = "e5fcd1eb6215fb420fbfc95d7e2b3b672ab5d8e8";
    date = "2017-02-11";
    owner  = "kubernetes";
    repo   = "client-go";
    sha256 = "99319ed43886dbd9e730e9fa62dd724717ac34a5932e14af53fdf329dd67d19c";
    goPackageAliases = [
      "k8s.io/client-go"
    ];
    subPackages = [
      "1.4/pkg/util/yaml"
    ];
    buildInputs = [
      glog
      yaml
    ];
    meta.autoUpdate = false;
  };

  kubernetes-client-go_1-5 = buildFromGitHub {
    version = 2;
    rev = "7c07d5a2af693f43ed616271f4b04fae0e0212cc";
    date = "2017-02-11";
    owner  = "kubernetes";
    repo   = "client-go";
    sha256 = "346af30cb4cac1f27db13a3561a7431c19508a47c1622810088e3f0f41c890d1";
    goPackagePath = "k8s.io/client-go";
    excludedPackages = "examples";
    propagatedBuildInputs = [
      distribution_for_engine-api
      glog
      ugorji_go
      gofuzz
      gopass
      go-oidc
      go-restful-swagger12
      go-spew
      groupcache
      inf_v0
      mergo
      net
      oauth2
      pflag
      gogo_protobuf
      ratelimit
      semver
      spec
      yaml
      pborman_uuid
    ];
    meta.autoUpdate = false;
  };


  ldap = buildFromGitHub {
    version = 2;
    rev = "v2.5.0";
    owner  = "go-ldap";
    repo   = "ldap";
    sha256 = "15mc4hrlfvjpbjr89w4s0267x3s3zkmhjd0qj2ls0bk2q3l48vmg";
    goPackageAliases = [
      "github.com/nmcclain/ldap"
      "github.com/vanackere/ldap"
    ];
    propagatedBuildInputs = [
      asn1-ber
    ];
  };

  ledisdb = buildFromGitHub {
    version = 2;
    rev = "5835ab9b2b80e1e3f7dd31b7526836c4a0cbf8b2";
    owner  = "siddontang";
    repo   = "ledisdb";
    sha256 = "0j67spxsggvayd722q8smrfpw1kn66kvq5lsx5phzmkfam6djk81";
    date = "2017-04-18";
    prePatch = ''
      dirs=($(find . -type d -name vendor | sort))
      echo "''${dirs[@]}" | xargs -n 1 rm -r
    '';
    propagatedBuildInputs = [
      siddontang_go
      ugorji_go
      goleveldb
      goredis
      liner
      mmap-go
      siddontang_rdb
      toml
    ];
  };

  lego = buildFromGitHub {
    version = 2;
    rev = "b1fd84c6ffc6896cfd64eca69775bc634d459702";
    owner = "xenolf";
    repo = "lego";
    sha256 = "1f0msaj5s89jfv6abxh2b1jwq1l58jqifjfhm0armzq3hmbvgbwy";
    buildInputs = [
      auroradnsclient
      aws-sdk-go
      azure-sdk-for-go
      urfave_cli
      crypto
      dns
      dnspod-go
      dnsimple-go
      egoscale
      go-autorest
      go-jose_v1
      go-ovh
      google-api-go-client
      linode
      memcache
      ns1-go_v2
      oauth2
      net
      vultr
    ];
    date = "2017-04-26";
  };

  lemma = buildFromGitHub {
    version = 2;
    rev = "cbfbc8381e93147bc50db64509634327d0f6d626";
    owner = "mailgun";
    repo = "lemma";
    sha256 = "1rqg0fw94vavi6a9c0cgc0xg9gy6p25ps2p9bs65flda60cm59ph";
    date = "2016-09-01";
    propagatedBuildInputs = [
      crypto
      metrics
      timetools
      mailgun_ttlmap
    ];
  };

  libseccomp-golang = buildFromGitHub {
    version = 2;
    rev = "v0.9.0";
    owner = "seccomp";
    repo = "libseccomp-golang";
    sha256 = "0kvrysdhq8yqcv4cvf1bmc38f6fwj2cwvw2zd004gka0qdmwhxx3";
    buildInputs = [
      pkgs.libseccomp
    ];
  };

  libtrust = buildFromGitHub {
    version = 2;
    rev = "aabc10ec26b754e797f9028f4589c5b7bd90dc20";
    owner = "docker";
    repo = "libtrust";
    sha256 = "40837c2420436be95f8098bf3a9c1b2820b72ec2b43fd0983a00c006d66ba1e8";
    date = "2016-07-08";
    postPatch = /* Demo uses same package namespace as actual library */ ''
      rm -rfv tlsdemo
    '';
  };

  liner = buildFromGitHub {
    version = 2;
    rev = "88609521dc4b6c858fd4c98b628147da928ce4ac";
    owner = "peterh";
    repo = "liner";
    sha256 = "05jzx3bfj9iqirwydn4lw75khkj3xjwnnx8a6nq6m1avwkmbzn9z";
    date = "2017-03-17";
  };

  linode = buildFromGitHub {
    version = 2;
    rev = "37e84520dcf74488f67654f9c775b9752c232dc1";
    owner = "timewasted";
    repo = "linode";
    sha256 = "13ypkib9nmm8pc2z8yqa97gh3karvrhwas0i4ck88pqhxwi85liw";
    date = "2016-08-29";
  };

  lldb = buildFromGitHub {
    version = 2;
    rev = "bea8611dd5c407f3c5eab9f9c68e887a27dc6f0e";
    owner  = "cznic";
    repo   = "lldb";
    sha256 = "1a3zd71vkvz1c319ihpmrky4zy84lazhsy3gwmnac71f6r8schii";
    buildInputs = [
      fileutil
      mathutil
      sortutil
    ];
    propagatedBuildInputs = [
      mmap-go
    ];
    extraSrcs = [
      {
        inherit (internal)
          goPackagePath
          src;
      }
      {
        inherit (zappy)
          goPackagePath
          src;
      }
    ];
    meta.useUnstable = true;
    date = "2016-11-02";
  };

  log15 = buildFromGitHub {
    version = 2;
    rev = "39bacc234bf1afd0b68573e95b45871f67ba2cd4";
    owner  = "inconshreveable";
    repo   = "log15";
    sha256 = "0sqk1yjya1gbfdy2sr453q07rvhfg3whxm0kj60qv35l68c8sw68";
    propagatedBuildInputs = [
      go-colorable
      stack
    ];
    date = "2017-02-16";
  };

  log15_v2 = buildFromGitHub {
    version = 1;
    rev = "v2.11";
    owner  = "inconshreveable";
    repo   = "log15";
    sha256 = "1krlgq3m0q40y8bgaf9rk7zv0xxx5z92rq8babz1f3apbdrn00nq";
    goPackagePath = "gopkg.in/inconshreveable/log15.v2";
    propagatedBuildInputs = [
      go-colorable
      stack
    ];
  };

  lunny_log = buildFromGitHub {
    version = 2;
    rev = "7887c61bf0de75586961948b286be6f7d05d9f58";
    owner = "lunny";
    repo = "log";
    sha256 = "0jsk5yc7lqlh9zicadbhxh6as3vlhln08f2wxrbnpcw0b1jncnp1";
    date = "2016-09-21";
  };

  mailgun_log = buildFromGitHub {
    version = 2;
    rev = "2f35a4607f1abf71f97f77f99b0de8493ef6f4ef";
    owner = "mailgun";
    repo = "log";
    sha256 = "1akyw7r5as06b6inn16wh9gg16zx3729nxmrgg0c46sgy23xmh9m";
    date = "2015-09-25";
  };

  loghisto = buildFromGitHub {
    version = 2;
    rev = "9d1d8c1fd2a4ac852bf2e312f2379f553345fda7";
    owner = "spacejam";
    repo = "loghisto";
    sha256 = "0dpfgzlf4n0vvppffxk5qwdb72iq6x320srkd1rzys0fd7xyvyz1";
    date = "2016-03-02";
    propagatedBuildInputs = [
      glog
    ];
  };

  logrus = buildFromGitHub {
    version = 2;
    rev = "v0.11.5";
    owner = "Sirupsen";
    repo = "logrus";
    sha256 = "13r9xjrhjfs8kjcbvhy6a53qvqm2iqn48ik3bk1bsfjdbqh326rb";
    buildInputs = [
      sys
    ];
  };

  logutils = buildFromGitHub {
    version = 1;
    date = "2015-06-09";
    rev = "0dc08b1671f34c4250ce212759ebd880f743d883";
    owner  = "hashicorp";
    repo   = "logutils";
    sha256 = "11p4p01x37xcqzfncd0w151nb5izmf3sy77vdwy0dpwa9j8ccgmw";
  };

  logxi = buildFromGitHub {
    version = 2;
    date = "2016-10-27";
    rev = "aebf8a7d67ab4625e0fd4a665766fef9a709161b";
    owner  = "mgutz";
    repo   = "logxi";
    sha256 = "10rvbxihgkwbdbb6pc7pn4jhgjxmq7gvxc8r5hckfi7qmc3z0ahk";
    excludedPackages = "Gododir";
    propagatedBuildInputs = [
      ansi
      go-colorable
      go-isatty
    ];
  };

  luhn = buildFromGitHub {
    version = 1;
    rev = "v1.0.0";
    owner  = "calmh";
    repo   = "luhn";
    sha256 = "13brkbbmj9bh0b9j3avcyrj542d78l9hg3bxj7jjvkp5n5cxwp41";
  };

  lxd = buildFromGitHub {
    version = 2;
    rev = "lxd-2.13";
    owner  = "lxc";
    repo   = "lxd";
    sha256 = "09xslmmfk3xa86bj61icw40pjlm26f1yrbskn6xvcrzc4sd2laz1";
    excludedPackages = "test"; # Don't build the binary called test which causes conflicts
    buildInputs = [
      crypto
      gettext
      gocapability
      golang-petname
      go-colorable
      go-lxc_v2
      go-sqlite3
      log15_v2
      pkgs.lxc
      mux
      pborman_uuid
      pongo2-v3
      protobuf
      tablewriter
      tomb_v2
      yaml_v2
      websocket
    ];
  };

  macaron_v1 = buildFromGitHub {
    version = 2;
    rev = "v1.2.1";
    owner  = "go-macaron";
    repo   = "macaron";
    sha256 = "182xihcysz553g48xl0skcvbimpqngch4ii371fy29mipanis8rj";
    goPackagePath = "gopkg.in/macaron.v1";
    goPackageAliases = [
      "github.com/go-macaron/macaron"
    ];
    propagatedBuildInputs = [
      com
      ini_v1
      inject
    ];
  };

  mafmt = buildFromGitHub {
    version = 2;
    date = "2017-03-24";
    rev = "15300f9d3a2d71db61951a8705d5ea8878764837";
    owner = "whyrusleeping";
    repo = "mafmt";
    sha256 = "1kz254lswq71qf5107abrq8zz8hybkig5nn1ayygkd1fdfhq7grs";
    propagatedBuildInputs = [
      go-multiaddr
    ];
  };

  mapstructure = buildFromGitHub {
    version = 2;
    date = "2017-04-22";
    rev = "cc8532a8e9a55ea36402aa21efdf403a60d34096";
    owner  = "mitchellh";
    repo   = "mapstructure";
    sha256 = "0pa1lpjikxn6ds5c5i413k5zm7iajqc279m10ib22aqrsv7a1c06";
  };

  match = buildFromGitHub {
    version = 2;
    owner = "tidwall";
    repo = "match";
    date = "2016-08-30";
    rev = "173748da739a410c5b0b813b956f89ff94730b4c";
    sha256 = "362da507bd9755044b3a1f9c0f048ec8758012ca55593b9a1dd63edd76e4e5f9";
  };

  mathutil = buildFromGitHub {
    version = 2;
    date = "2017-03-13";
    rev = "1447ad269d64ca91aa8d7079baa40b6fc8b965e7";
    owner = "cznic";
    repo = "mathutil";
    sha256 = "1v1ff44562dwmijs5pnmsa1ylxnskpm916rfcwqf1padgjxmp6bm";
    excludedPackages = "example";
    buildInputs = [
      bigfft
    ];
  };

  maxminddb-golang = buildFromGitHub {
    version = 2;
    rev = "v1.1.0";
    owner  = "oschwald";
    repo   = "maxminddb-golang";
    sha256 = "0z1hbncy2ang3p6zc9pvijbx7y3vgwfi714a4cm5mx6j6125dl49";
    propagatedBuildInputs = [
      sys
    ];
  };

  mc = buildFromGitHub {
    version = 2;
    owner = "minio";
    repo = "mc";
    rev = "61e511cc3e4d80f7910869c37a3a200b2e438d10";
    sha256 = "1yzm7l5nx7sv9izlrsswxj9h2crb43h0flfj3ncmssqvx84mp262";
    propagatedBuildInputs = [
      cli_minio
      color
      go-colorable
      go-homedir_minio
      go-humanize
      go-version
      minio_pkg
      minio-go
      notify
      pb
      profile
      structs
    ];
    date = "2017-04-24";
  };

  mdns = buildFromGitHub {
    version = 2;
    date = "2017-02-21";
    rev = "4e527d9d808175f132f949523e640c699e4253bb";
    owner = "hashicorp";
    repo = "mdns";
    sha256 = "0d7hknw06jsk3w7cvy5hrwg3y4dhzc5d2176vr0g624ww5jdzh64";
    propagatedBuildInputs = [
      dns
      net
    ];
  };

  memberlist = buildFromGitHub {
    version = 2;
    rev = "v0.1.0";
    owner = "hashicorp";
    repo = "memberlist";
    sha256 = "044mwkcf84qx8xdl5imad59ghjbp5r8qj0330pxcq2j600fwmlxz";
    propagatedBuildInputs = [
      dns
      ugorji_go
      armon_go-metrics
      go-multierror
      go-sockaddr
      seed
    ];
  };

  memcache = buildFromGitHub {
    version = 2;
    date = "2015-06-22";
    rev = "1031fa0ce2f20c1c0e1e1b51951d8ea02c84fa05";
    owner = "rainycape";
    repo = "memcache";
    sha256 = "0585b0rblaxn4b2p5q80x3ynlcbhvf43p18yxxhlnm0yf0w3hjl9";
  };

  mergo = buildFromGitHub {
    version = 2;
    date = "2017-03-26";
    rev = "d806ba8c21777d504a2090a2ca4913c750dd3a33";
    owner = "imdario";
    repo = "mergo";
    sha256 = "0izq7mjmpp3m9fa7zizg2qggc89slzc9wz5fmgzid5s3sp1wqlzk";
  };

  metrics = buildFromGitHub {
    version = 2;
    date = "2015-01-23";
    rev = "2b3c4565aafdcd40c8069e50de08ac5379787943";
    owner = "mailgun";
    repo = "metrics";
    sha256 = "01nnm2wl2m1p1bj86rj87r1yf5f9fmvxxamd2v88p04958xbj0jk";
    propagatedBuildInputs = [
      timetools
    ];
  };

  mgo_v2 = buildFromGitHub {
    version = 1;
    rev = "r2016.08.01";
    owner = "go-mgo";
    repo = "mgo";
    sha256 = "0hq8wfypghfcz83035wdb844b39pd1qly43zrv95i99p35fwmx22";
    goPackagePath = "gopkg.in/mgo.v2";
    goPackageAliases = [
      "github.com/10gen/llmgo"
    ];
    excludedPackages = "dbtest";
    buildInputs = [
      pkgs.cyrus-sasl
    ];
  };

  minheap = buildFromGitHub {
    version = 2;
    rev = "7c28d80e2ada649fc8ab1a37b86d30a2633bd47c";
    owner = "mailgun";
    repo = "minheap";
    sha256 = "06lyppnqhyfq1ksc8c50c2czjp3h1ra38jsm8r5mafxrn6rv7p7w";
    date = "2013-12-07";
  };

  minio = buildFromGitHub {
    version = 2;
    owner = "minio";
    repo = "minio";
    rev = "RELEASE.2017-03-16T21-50-32Z";
    sha256 = "09ddcbzh05sv35m7nvabjv4j8n3byr4gfj3iab37712ivpgzx1il";
    buildInputs = [
      amqp
      blake2b-simd
      cli_minio
      color
      cors
      crypto
      dsync
      elastic_v3
      gjson
      go-bindata-assetfs
      go-homedir_minio
      go-humanize
      go-version
      handlers
      jwt-go
      logrus
      mc
      minio-go
      mux
      pb
      profile
      redigo
      reedsolomon
      rpc
      sha256-simd
      skyring-common
      structs
    ];
  };

  # The pkg package from minio, for bootstrapping minio
  minio_pkg = buildFromGitHub {
    inherit (minio) version owner repo rev sha256;
    propagatedBuildInputs = [
      # Propagate minio_pkg_probe from here for consistency
      minio_pkg_probe
      pb
      structs
    ];
    postUnpack = ''
      mv -v "$sourceRoot" "''${sourceRoot}.old"
      mkdir -pv "$sourceRoot"
      mv -v "''${sourceRoot}.old"/pkg "$sourceRoot"/pkg
      rm -rf "''${sourceRoot}.old"
    '';
  };

  # Probe pkg was remove in later releases, but still required by mc
  minio_pkg_probe = buildFromGitHub {
    version = 2;
    inherit (minio) owner repo;
    rev = "RELEASE.2017-03-16T21-50-32Z";
    sha256 = "09ddcbzh05sv35m7nvabjv4j8n3byr4gfj3iab37712ivpgzx1il";
    propagatedBuildInputs = [
      go-humanize
    ];
    postUnpack = ''
      mv -v "$sourceRoot" "''${sourceRoot}.old"
      mkdir -pv "$sourceRoot"/pkg
      mv -v "''${sourceRoot}.old"/pkg/probe "$sourceRoot"/pkg/probe
      rm -rf "''${sourceRoot}.old"
    '';
    meta.autoUpdate = false;
  };

  minio-go = buildFromGitHub {
    version = 2;
    owner = "minio";
    repo = "minio-go";
    rev = "5297a818b482fa329b3dc1a3926e3c4c6fb5d459";
    sha256 = "071g2y3pfrvvzgh1ac5zx5q4zvm0y1ka0cpy43f1q7rn758l476a";
    meta.useUnstable = true;
    date = "2017-04-26";
  };

  missinggo = buildFromGitHub {
    version = 1;
    rev = "f3a48f14358dc22876048390ba49b963a476a5db";
    owner  = "anacrolix";
    repo   = "missinggo";
    sha256 = "d5c34a92445e5ec95d897f68f9f1cce2a02fdc0d6adc372a98a8bbce6a441c84";
    date = "2016-06-18";
    propagatedBuildInputs = [
      b
      btree
      docopt-go
      envpprof
      go-humanize
      goskiplist
      iter
      net
      roaring
      tagflag
    ];
    meta.autoUpdate = false;
  };

  missinggo_lib = buildFromGitHub {
    inherit (missinggo) rev owner repo sha256 version date;
    subPackages = [
      "."
    ];
    propagatedBuildInputs = [
      iter
    ];
    meta.autoUpdate = false;
  };

  mmap-go = buildFromGitHub {
    version = 2;
    owner = "edsrzf";
    repo = "mmap-go";
    rev = "0bce6a6887123b67a60366d2c9fe2dfb74289d2e";
    sha256 = "0svsbzhh9wb800x1gwgnmbi62jvmq269cak78dajpnpjyw2m9a73";
    date = "2017-03-20";
  };

  mmark = buildFromGitHub {
    version = 2;
    owner = "miekg";
    repo = "mmark";
    rev = "8b498b013a3e10b12864c2023a59d490c9d4bf5b";
    date = "2017-04-07";
    sha256 = "0srih857ry0a1bg98clr3yvsxpddlks17pm008igynh93mplvfsh";
    propagatedBuildInputs = [
      toml
    ];
  };

  moby = buildFromGitHub {
    version = 2;
    owner = "moby";
    repo = "moby";
    rev = "94465adaf05edd16f518f255cd7ad3c5ca23e2ac";
    date = "2017-04-26";
    sha256 = "02pdlnjm5z3hyhkjip162cvisc66d94sg2fm96dp0380mk94wss0";
    meta.useUnstable = true;
  };

  moby_for_go-dockerclient = buildFromGitHub {
    inherit (moby) version owner repo rev date sha256 meta;
    subPackages = [
      "api/types/swarm"
      "opts"
      "pkg/archive"
      "pkg/fileutils"
      "pkg/homedir"
      "pkg/jsonmessage"
      "pkg/stdcopy"
    ];
    buildInputs = [
      docker_for_go-dockerclient
      go-connections
      go-units
      gotty
      logrus
      runc
    ];
  };

  mock = buildFromGitHub {
    version = 2;
    owner = "golang";
    repo = "mock";
    rev = "bd3c8e81be01eef76d4b503f5e687d2d1354d2d9";
    date = "2016-01-21";
    sha256 = "5d964bd99a35234ae8a9a0a9ea030665f57ede3459dff10290788475744ba470";
  };

  mongo-tools = buildFromGitHub {
    version = 2;
    rev = "r3.5.6";
    owner  = "mongodb";
    repo   = "mongo-tools";
    sha256 = "15ckk7hn9v8vi9pii7n15di39azy5ngiz34nl6n1bm539kalf2pa";
    buildInputs = [
      crypto
      escaper
      go-cache
      go-flags
      gopacket
      gopass
      mgo_v2
      openssl
      termbox-go
      tomb_v2
    ];

    # Mongodb incorrectly names all of their binaries main
    # Let's work around this with our own installer
    preInstall = ''
      mkdir -p $bin/bin
      while read b; do
        rm -f go/bin/main
        go install $goPackagePath/$b/main
        cp go/bin/main $bin/bin/$b
      done < <(find go/src/$goPackagePath -name main | xargs dirname | xargs basename -a)
      rm -r go/bin
    '';
  };

  mousetrap = buildFromGitHub {
    version = 2;
    rev = "76626ae9c91c4f2a10f34cad8ce83ea42c93bb75";
    owner = "inconshreveable";
    repo = "mousetrap";
    sha256 = "1905y88ajawg5x0ia88jba1fsg85yfdjip82m5x1r0ypgjicvk9n";
    date = "2014-10-17";
  };

  mow-cli = buildFromGitHub {
    version = 2;
    rev = "d3ffbc2f98b83e09dc8efd55ecec75eb5fd656ec";
    owner  = "jawher";
    repo   = "mow.cli";
    sha256 = "1mji6248gv5i61qg1dsbcf1ijy9ajf16x3lv0b8f3jvvb495m8ms";
    date = "2017-02-20";
  };

  ns1-go_v2 = buildFromGitHub {
    version = 2;
    rev = "2abc76c60bf88ba33b15d1d87a13f624d8dff956";
    owner  = "ns1";
    repo   = "ns1-go";
    sha256 = "00c4s5jmiz12b3wqr3vwbc3k4akdw27nwrmczzs2hvsknlg5dxlp";
    goPackagePath = "gopkg.in/ns1/ns1-go.v2";
    date = "2017-03-22";
  };

  msgp = buildFromGitHub {
    version = 2;
    rev = "v1.0";
    owner  = "tinylib";
    repo   = "msgp";
    sha256 = "1m49ahnqqf40yjj9jij30iargq6jm0cm1alpr191nd3x692sc9ds";
    propagatedBuildInputs = [
      fwd
      chalk
      tools
    ];
  };

  multibuf = buildFromGitHub {
    version = 2;
    rev = "565402cd71fbd9c12aa7e295324ea357e970a61e";
    owner  = "mailgun";
    repo   = "multibuf";
    sha256 = "1csjfl3bcbya7dq3xm1nqb5rwrpw5migrqa4ajki242fa5i66mdr";
    date = "2015-07-14";
  };

  murmur3 = buildFromGitHub {
    version = 2;
    rev = "0d12bf811670bf6a1a63828dfbd003eded177fce";
    owner  = "spaolacci";
    repo   = "murmur3";
    sha256 = "1biq3rv8ycnyrma135273bi6pd62866gy84dnv17vqf3pnrcz3bd";
    date = "2015-08-29";
  };

  mux = buildFromGitHub {
    version = 2;
    rev = "v1.3.0";
    owner = "gorilla";
    repo = "mux";
    sha256 = "1h621g4yjccw36nfxawzh28jd1awdpvnrjhfhd3pp6m1dmhnc3gg";
    propagatedBuildInputs = [
      context
    ];
  };

  mysql = buildFromGitHub {
    version = 2;
    rev = "v1.3";
    owner  = "go-sql-driver";
    repo   = "mysql";
    sha256 = "1jy5ak2ka6qi16i99c06b1k6nvf3fbngcj454dzxk1xwrd5y076h";
    postPatch = ''
      grep -r '+build appengine' -l | xargs rm
    '';
  };

  net-rpc-msgpackrpc = buildFromGitHub {
    version = 1;
    date = "2015-11-15";
    rev = "a14192a58a694c123d8fe5481d4a4727d6ae82f3";
    owner = "hashicorp";
    repo = "net-rpc-msgpackrpc";
    sha256 = "007pwdpap465b32cx1i2hmf2q67vik3wk04xisq2pxvqvx81irks";
    propagatedBuildInputs = [ ugorji_go go-multierror ];
  };

  netlink = buildFromGitHub {
    version = 2;
    rev = "2632e243fb1a61b67ad23b04c16a5a48315e9391";
    owner  = "vishvananda";
    repo   = "netlink";
    sha256 = "0gnvx8fzx83ln106wnc9wkz5pvlqv774a0v3mb7bispa8ap96s7v";
    date = "2017-04-25";
    propagatedBuildInputs = [
      netns
    ];
  };

  netns = buildFromGitHub {
    version = 2;
    rev = "54f0e4339ce73702a0607f49922aaa1e749b418d";
    owner  = "vishvananda";
    repo   = "netns";
    sha256 = "0rwb0bk1dcz477di5md4jd643d5cpc3yizwqlq6zfwx7yxi0nqp2";
    date = "2017-02-19";
  };

  nitro = buildFromGitHub {
    version = 1;
    owner = "spf13";
    repo = "nitro";
    rev = "24d7ef30a12da0bdc5e2eb370a79c659ddccf0e8";
    date = "2013-10-03";
    sha256 = "1dbnfac79lxc1pr1j1n3956i292ck4yjrhr8nsd2wp2jccab5zdz";
  };

  nodb = buildFromGitHub {
    version = 1;
    owner = "lunny";
    repo = "nodb";
    rev = "fc1ef06ad4af0da31cdb87e3fa5ec084c67e6597";
    date = "2016-06-21";
    sha256 = "1w46s9mgqjq0faybr743fs96jp0g1pcahrfamfiwi5hz28dqfcsp";
    propagatedBuildInputs = [
      goleveldb
      lunny_log
      go-snappy
      toml
    ];
  };

  nomad = buildFromGitHub {
    version = 2;
    rev = "v0.5.6";
    owner = "hashicorp";
    repo = "nomad";
    sha256 = "1p7qlyqwznyf9y4hgqs4x3qqniy4ibg396hihhd4kqylpaql2gyk";

    nativeBuildInputs = [
      ugorji_go.bin
    ];

    buildInputs = [
      armon_go-metrics
      circbuf
      colorstring
      columnize
      consul-template
      consul_api
      copystructure
      cronexpr
      distribution_for_docker
      docker_for_nomad
      go-checkpoint
      go-cleanhttp
      go-dockerclient
      go-getter
      go-humanize
      go-lxc_v2
      go-memdb
      go-multierror
      go-plugin
      go-ps
      go-rootcerts
      go-syslog
      go-version
      gopsutil
      gziphandler
      hashstructure
      hcl
      logutils
      mapstructure
      memberlist
      mitchellh_cli
      net-rpc-msgpackrpc
      osext
      raft-boltdb_v2
      raft_v2
      runc
      scada-client
      seed
      serf
      snappy
      srslog
      sync
      sys
      tail
      time
      tomb_v1
      tomb_v2
      ugorji_go
      vault_api
      yamux
    ];

    # Rename deprecated ParseNamed to ParseNormalizedNamed
    postPatch = ''
      find . -type f -exec sed -i {} \
        -e 's,.ParseNamed,.ParseNormalizedNamed,g' \
        -e 's,"github.com/docker/docker/reference","github.com/docker/distribution/reference",g' \
        \;
    '';

    preBuild = ''
      pushd go/src/$goPackagePath
      go list ./... | xargs go generate
      popd
    '';

    postInstall = ''
      rm "$bin"/bin/app
    '';
  };

  notify = buildFromGitHub {
    version = 2;
    owner = "rjeczalik";
    repo = "notify";
    date = "2017-04-14";
    rev = "660542b98f76c58910002c82e912b71248f4daa0";
    sha256 = "0l67ba34dbpdnj5fvzbqbrvfkamsxqjkwv0ly1z29gb8ldyrxfn4";
    propagatedBuildInputs = [
      sys
    ];
  };

  objx = buildFromGitHub {
    version = 1;
    date = "2015-09-28";
    rev = "1a9d0bb9f541897e62256577b352fdbc1fb4fd94";
    owner  = "stretchr";
    repo   = "objx";
    sha256 = "0ycjvfbvsq6pmlbq2v7670w1k25nydnz4scx0qgiv0f4llxnr0y9";
  };

  open-golang = buildFromGitHub {
    version = 2;
    owner = "skratchdot";
    repo = "open-golang";
    rev = "75fb7ed4208cf72d323d7d02fd1a5964a7a9073c";
    date = "2016-03-02";
    sha256 = "da900f012522dd61cc0504a16bbb137e3ed2173d0715fbf709046a1e0d923ca3";
  };

  openssl = buildFromGitHub {
    version = 2;
    date = "2016-09-22";
    rev = "5be686e264d836e7a01ca7fc7c53acdb8edbe768";
    owner = "10gen";
    repo = "openssl";
    sha256 = "0jlr0y8812ayj5xfpn7m0m1pfm8pf1g43xbw7ngs4zxcs0ip7l9g";
    goPackageAliases = [
      "github.com/spacemonkeygo/openssl"
    ];
    buildInputs = [
      pkgs.openssl
    ];
    propagatedBuildInputs = [
      spacelog
    ];

    preBuild = ''
      find go/src/$goPackagePath -name \*.go | xargs sed -i 's,spacemonkeygo/openssl,10gen/openssl,g'
    '';
  };

  osext = buildFromGitHub {
    version = 2;
    date = "2017-03-09";
    rev = "9d302b58e975387d0b4d9be876622c86cefe64be";
    owner = "kardianos";
    repo = "osext";
    sha256 = "1p2n6k4bvz375ra1690w13cgv2l0hmazbm70saka11jv9b4m9h3v";
    goPackageAliases = [
      "github.com/bugsnag/osext"
      "bitbucket.org/kardianos/osext"
    ];
  };

  otp = buildFromGitHub {
    version = 2;
    date = "2017-02-23";
    rev = "9e1935374bc73ffe011187dafed51a412b90fe43";
    owner = "pquerna";
    repo = "otp";
    sha256 = "01i40xfnr5wg7l15vq7xsd8p287apj7r2bnj8jnzq5k3ijzmms97";
    propagatedBuildInputs = [
      barcode
    ];
  };

  oxy = buildFromGitHub {
    version = 2;
    owner = "vulcand";
    repo = "oxy";
    date = "2016-07-23";
    rev = "db85f00cac5466def1f6f2667063e6e38c1fe606";
    sha256 = "3c32677900a6399eecd80fc47798e998f47f8df502727574052d6ddc654d4a61";
    goPackageAliases = [ "github.com/mailgun/oxy" ];
    propagatedBuildInputs = [
      hdrhistogram
      mailgun_log
      multibuf
      predicate
      timetools
      mailgun_ttlmap
    ];
    meta.autoUpdate = false;
  };

  pat = buildFromGitHub {
    version = 2;
    owner = "bmizerany";
    repo = "pat";
    date = "2016-02-17";
    rev = "c068ca2f0aacee5ac3681d68e4d0a003b7d1fd2c";
    sha256 = "aad2d84661ea918168e60ed7bab467d4e0fce28fe9372e786c2714c10f6490a7";
  };

  pb = buildFromGitHub {
    version = 2;
    owner = "cheggaaa";
    repo = "pb";
    date = "2017-04-23";
    rev = "ae0201277d45c0006874ce00e4feea56121be5f1";
    sha256 = "0d3awyw5qy95pm18z4jfjlzdmlrs2vdlh21lbxkb3y7wbsk8n7vv";
    propagatedBuildInputs = [
      go-runewidth
    ];
    meta.useUnstable = true;
  };

  pb_v1 = buildFromGitHub {
    version = 2;
    owner = "cheggaaa";
    repo = "pb";
    rev = "v1.0.13";
    sha256 = "0djiphx0grvaj5kshfr7vq6hqa061gk4vivbl9pjh936adcl5lfy";
    goPackagePath = "gopkg.in/cheggaaa/pb.v1";
    propagatedBuildInputs = [
      go-runewidth
    ];
  };

  beorn7_perks = buildFromGitHub {
    version = 1;
    date = "2016-08-04";
    owner  = "beorn7";
    repo   = "perks";
    rev = "4c0e84591b9aa9e6dcfdf3e020114cd81f89d5f9";
    sha256 = "19dw6jcvcbnk0nq4wy9dhrb1d3k85xwnfvwn1ld03f2mzmshf9fr";
  };

  pester = buildFromGitHub {
    version = 2;
    owner = "sethgrid";
    repo = "pester";
    rev = "4f4c0a67b6496764028e1ab9fd8dfb630282ed2f";
    date = "2017-04-08";
    sha256 = "0xydrln1gmzb9kqf0kq7g62xazsxrnza5w8g0jzppdpf25zjnxwm";
  };

  pfilter = buildFromGitHub {
    version = 2;
    owner = "AudriusButkevicius";
    repo = "pfilter";
    rev = "09b3cfdd04de89f0196caecb0b335d7149a6593a";
    date = "2017-02-09";
    sha256 = "1p57lgdsssvl6s0jsf6ggh20z4rj06scnjr5cilp1jpjgrc87xzs";
  };

  pflag = buildFromGitHub {
    version = 3;
    owner = "spf13";
    repo = "pflag";
    rev = "f1d95a35e132e8a1868023a08932b14f0b8b8fcb";
    date = "2017-04-27";
    sha256 = "1ns8ja41h3hj5d6siv2r8a45z6hf2vlxip2zqnax130j9lb3y7g2";
  };

  pkcs7 = buildFromGitHub {
    version = 2;
    owner = "fullsailor";
    repo = "pkcs7";
    rev = "eb67e7e564b9eae64dc7d95fae0784d6086a5fc4";
    date = "2017-02-08";
    sha256 = "0814z5w0pcsnb64pg356xhxamkl4aa1hdal2w6xhnhcz9xmsaxan";
  };

  pkg = buildFromGitHub {
    version = 2;
    date = "2017-04-20";
    owner  = "coreos";
    repo   = "pkg";
    rev = "8dbaa491b063ed47e2474b5363de0c0db91cf9f2";
    sha256 = "0qmwkgad8wakz2iva7qhd9wsp5z81dw1x5bgi3mlwkyfqa0fc3cw";
    buildInputs = [
      crypto
      yaml_v1
    ];
    propagatedBuildInputs = [
      go-systemd_journal
    ];
  };

  pongo2-v3 = buildFromGitHub {
    version = 1;
    rev = "v3.0";
    owner  = "flosch";
    repo   = "pongo2";
    sha256 = "1qjcj7hcjskjqp03fw4lvn1cwy78dck4jcd0rcrgdchis1b84isk";
    goPackagePath = "gopkg.in/flosch/pongo2.v3";
  };

  pq = buildFromGitHub {
    version = 2;
    rev = "2704adc878c21e1329f46f6e56a1c387d788ff94";
    owner  = "lib";
    repo   = "pq";
    sha256 = "1j00p9gzclsnbqn4iv3k06fvpy3jc9iyh2mzsahm880x9njswrnw";
    date = "2017-03-24";
  };

  probing = buildFromGitHub {
    version = 2;
    rev = "07dd2e8dfe18522e9c447ba95f2fe95262f63bb2";
    owner  = "xiang90";
    repo   = "probing";
    sha256 = "140b5bizry0cw2s98dscp5b8zy57h2l5ybkmr7abx9d1c2nrxqnj";
    date = "2016-08-13";
  };

  predicate = buildFromGitHub {
    version = 2;
    rev = "19b9dde14240d94c804ae5736ad0e1de10bf8fe6";
    owner  = "vulcand";
    repo   = "predicate";
    sha256 = "0i2smqnr8vldz7iiid835kgkvs55hb5vjdjj9h87xlwy7f8y9map";
    date = "2016-06-21";
  };

  profile = buildFromGitHub {
    version = 2;
    owner = "pkg";
    repo = "profile";
    rev = "06b906832ed0e32302a942b63b6c5f8359034d26";
    sha256 = "0kqhclpk2i3r6jrgv3scy4149wfv158sg0vk04iq1li20yra4f81";
    date = "2017-04-13";
  };

  prometheus = buildFromGitHub {
    version = 2;
    rev = "v1.6.1";
    owner  = "prometheus";
    repo   = "prometheus";
    sha256 = "02a1wwcpj76a4n20d4kb50yk4vnqm55n0fsahdiq0icqbjk0pga5";
    buildInputs = [
      aws-sdk-go
      azure-sdk-for-go
      consul_api
      dns
      fsnotify_v1
      go-autorest
      goleveldb
      govalidator
      go-zookeeper
      google-api-go-client
      kubernetes-client-go_1-5
      net
      oauth2
      prometheus_client_golang
      prometheus_client_model
      prometheus_common
      protobuf
      snappy
      time
      yaml_v2
    ];
  };

  prometheus_client_golang = buildFromGitHub {
    version = 2;
    rev = "7d9484283ebefa862b5b7727d4344cfdf9a0d138";
    owner = "prometheus";
    repo = "client_golang";
    sha256 = "1fcrblwbbpf9xr0v1ad9hl3kclyk76djxxlyy2dg2w4hlbzfbj1w";
    propagatedBuildInputs = [
      net
      protobuf
      prometheus_client_model
      prometheus_common_for_client
      procfs
      beorn7_perks
    ];
    date = "2017-04-25";
  };

  prometheus_client_model = buildFromGitHub {
    version = 2;
    rev = "6f3806018612930941127f2a7c6c453ba2c527d2";
    date = "2017-02-16";
    owner  = "prometheus";
    repo   = "client_model";
    sha256 = "0a9i3ja3pp6sj2v2qshnp12mdgshngwf73p0jmmhn2yddipbngc0";
    buildInputs = [
      protobuf
    ];
  };

  prometheus_common = buildFromGitHub {
    version = 3;
    date = "2017-04-27";
    rev = "13ba4ddd0caa9c28ca7b7bffe1dfa9ed8d5ef207";
    owner = "prometheus";
    repo = "common";
    sha256 = "0m5f06pfd7r28rw1gws5ya1362jx34cpf6p17j1ca79h030nsrks";
    buildInputs = [
      net
      prometheus_client_model
      protobuf
      sys
    ];
    propagatedBuildInputs = [
      golang_protobuf_extensions
      httprouter
      logrus
      prometheus_client_golang
    ];
  };

  prometheus_common_for_client = buildFromGitHub {
    inherit (prometheus_common) date rev owner repo sha256 version;
    subPackages = [
      "expfmt"
      "model"
      "internal/bitbucket.org/ww/goautoneg"
    ];
    propagatedBuildInputs = [
      golang_protobuf_extensions
      prometheus_client_model
      protobuf
    ];
  };

  procfs = buildFromGitHub {
    version = 2;
    rev = "6ac8c5d890d415025dd5aae7595bcb2a6e7e2fad";
    date = "2017-04-24";
    owner  = "prometheus";
    repo   = "procfs";
    sha256 = "1gsv7r37rl943jnhahgcv7bmzsi28fwx087180i65fgxjb73xaks";
  };

  properties = buildFromGitHub {
    version = 2;
    owner = "magiconair";
    repo = "properties";
    rev = "v1.7.2";
    sha256 = "16v6c3d85r4pv74aqfa5rj6pbyfminvprhjxyqlcl13byi2hjzxh";
  };

  gogo_protobuf = buildFromGitHub {
    version = 2;
    owner = "gogo";
    repo = "protobuf";
    rev = "v0.4";
    sha256 = "17bpsaqg5cqsdfp6da6w14lypjnv7vrdiwd033hbl35m6w6x87xi";
    excludedPackages = "test";
  };

  pty = buildFromGitHub {
    version = 2;
    owner = "kr";
    repo = "pty";
    rev = "v1.0.0";
    sha256 = "1v6xk33d575r598ir2k2zc0myl524ll2mcjkrxbcvg8l5wi7xn0a";
  };

  purell = buildFromGitHub {
    version = 2;
    owner = "PuerkitoBio";
    repo = "purell";
    rev = "v1.1.0";
    sha256 = "0fm0yr5iaxhkg5kkqry6pi0v2hq469x3fwfb1p90afzzav500xsf";
    propagatedBuildInputs = [
      net
      text
      urlesc
    ];
  };

  qart = buildFromGitHub {
    version = 1;
    rev = "0.1";
    owner  = "vitrun";
    repo   = "qart";
    sha256 = "02n7f1j42jp8f4nvg83nswfy6yy0mz2axaygr6kdqwj11n44rdim";
  };

  ql = buildFromGitHub {
    version = 2;
    rev = "v1.1.0";
    owner  = "cznic";
    repo   = "ql";
    sha256 = "0ap19p5zgjrqa31fw87rsi10n0jrh5jydyyqqpbjalkg5qxwd63l";
    propagatedBuildInputs = [
      b
      exp
      go4
      lldb
      mathutil
      strutil
    ];
  };

  rabbit-hole = buildFromGitHub {
    version = 2;
    rev = "v1.3.0";
    owner  = "michaelklishin";
    repo   = "rabbit-hole";
    sha256 = "1xplz3mwj6dia7y7jzgk5r2vdmmi2rk89ndzz1mg2hibq85cs2fr";
  };

  radius = buildFromGitHub {
    version = 2;
    rev = "8ecfc6afafd1730084ea411c01b3618b093a1ccc";
    date = "2016-12-24";
    owner  = "layeh";
    repo   = "radius";
    sha256 = "1l2s1v5zj9fy1jybq3gv2s5ybjx3r70fhpsmilwrmpk45hjrs4lg";
    goPackagePath = "layeh.com/radius";
  };

  raft_v2 = buildFromGitHub {
    version = 2;
    date = "2016-11-09";
    # Use the library-v2-stage-one branch until it is merged
    # into master.
    rev = "aaad9f10266e089bd401e7a6487651a69275641b";
    owner  = "hashicorp";
    repo   = "raft";
    sha256 = "b5a3392c27c22bbd44bc7978ca61f9ce90658caf51bebef7b4db11788d4d5e80";
    propagatedBuildInputs = [
      armon_go-metrics
      logxi
      ugorji_go
    ];
    meta.autoUpdate = false;
  };

  raft-boltdb_v2 = buildFromGitHub {
    version = 2;
    date = "2017-02-09";
    rev = "df631556b57507bd5d0ed4f87468fd93ab025bef";
    owner  = "hashicorp";
    repo   = "raft-boltdb";
    sha256 = "0hhc71684mdz09cm8r9hf9j9m97yzv495ln3kk4cms62pc9yf93b";
    propagatedBuildInputs = [
      bolt
      ugorji_go
      raft_v2
    ];
  };

  ratecounter = buildFromGitHub {
    version = 2;
    owner = "paulbellamy";
    repo = "ratecounter";
    rev = "66b206d2a2d00245e34b1494fcaeef5e99041ea7";
    sha256 = "09h6khbzhvrp22kw1wbfm986lx7c26pr6rkspv8wkhzfrpgbm02v";
    date = "2017-03-30";
  };

  ratelimit = buildFromGitHub {
    version = 2;
    rev = "acf38b000a03e4ab89e40f20f1e548f4e6ac7f72";
    date = "2017-03-14";
    owner  = "juju";
    repo   = "ratelimit";
    sha256 = "04bir651ac5b0zgbl5hlhdxapsrz2l1xw1i4qncl5nnnbms3xysz";
  };

  raw = buildFromGitHub {
    version = 2;
    rev = "4ad22e6f1008c9f1100cb970699da776b45be83c";
    owner  = "feyeleanor";
    repo   = "raw";
    sha256 = "0zb5qwrm7x7p79wzi4lbr4px9q6qm5zz9xwjakf2wb1cnyxim93w";
    date = "2016-12-30";
  };

  rclone = buildFromGitHub {
    version = 2;
    owner = "ncw";
    repo = "rclone";
    rev = "b6517840cae4100c29c6e7ba386b2d2f3ed23bce";
    sha256 = "120bn5m5lggpcjmyccn8kw3s4aa5pndmx2dnwybphxzbd3xa8hs2";
    propagatedBuildInputs = [
      aws-sdk-go
      cobra
      crypto
      dropbox
      eme
      errors
      ewma
      fs
      fuse
      go-acd
      goconfig
      google-api-go-client
      net
      oauth2
      open-golang
      pflag
      sftp
      swift
      sys
      tb
      text
    ];
    excludedPackages = "fstest";
    meta.useUnstable = true;
    date = "2017-04-25";
  };

  cupcake_rdb = buildFromGitHub {
    version = 2;
    date = "2016-08-25";
    rev = "43ba34106c765f2111c0dc7b74cdf8ee437411e0";
    owner = "cupcake";
    repo = "rdb";
    sha256 = "0sqs6l4i5f2pd4i719aijbyjhdss8zqvk3b9195d0ljx2di9y84i";
  };

  siddontang_rdb = buildFromGitHub {
    version = 1;
    date = "2015-03-07";
    rev = "fc89ed2e418d27e3ea76e708e54276d2b44ae9cf";
    owner = "siddontang";
    repo = "rdb";
    sha256 = "1rf7dcxymdqjxjld6mb0fpsprnf342y1mr6m93fr073m5k5ij6kq";
    propagatedBuildInputs = [
      cupcake_rdb
    ];
  };

  redigo = buildFromGitHub {
    version = 2;
    owner = "garyburd";
    repo = "redigo";
    date = "2017-02-16";
    rev = "0d253a66e6e1349f4581d6d2b300ee434ee2da9f";
    sha256 = "1m6xxyalzs5qq2vl0c78ahsmmkhg59axsis603ld45j7vd77hyfx";
    meta.useUnstable = true;
  };

  redis_v2 = buildFromGitHub {
    version = 1;
    rev = "v2.3.2";
    owner  = "go-redis";
    repo   = "redis";
    sha256 = "211e91fd3b5e120ca073aecb8088ba513012ab4513b13934890aaa6791b2923b";
    goPackagePath = "gopkg.in/redis.v2";
    propagatedBuildInputs = [
      bufio_v1
    ];
    meta.autoUpdate = false;
  };

  reedsolomon = buildFromGitHub {
    version = 2;
    owner = "klauspost";
    repo = "reedsolomon";
    date = "2017-02-19";
    rev = "5abf0ee302ccf4834e84f63ff74eca3e8b88e4e2";
    sha256 = "1r6yk16id1nk1qmpn21g6cw4ipy68j2711mc8ysd39js3pginff2";
    propagatedBuildInputs = [
      cpuid
    ];
    meta.useUnstable = true;
  };

  reflectwalk = buildFromGitHub {
    version = 2;
    date = "2017-01-10";
    rev = "417edcfd99a4d472c262e58f22b4bfe97580f03e";
    owner  = "mitchellh";
    repo   = "reflectwalk";
    sha256 = "0kcig5x8bv7hzzyy67g0wsm8akbl6kn8l6r0sdy1yc7jybsnbizq";
  };

  resumable = buildFromGitHub {
    version = 2;
    owner = "stevvooe";
    repo = "resumable";
    date = "2016-09-23";
    rev = "f714bdb9b57a7162bc99aaa0b68a338c0da1c392";
    sha256 = "18jm8ssihjl5flqhahqcvz2s5cifgcl6f7ms23xl70zkls6j0l3a";
  };

  roaring = buildFromGitHub {
    version = 2;
    rev = "v0.3.8";
    owner  = "RoaringBitmap";
    repo   = "roaring";
    sha256 = "0cs9qdnh9kzdd38w8gl8prg7lwpvyx4n6480jgcnif6lgrr3rhym";
    propagatedBuildInputs = [
      go-unsnap-stream
      msgp
    ];
  };

  rollinghash = buildFromGitHub {
    version = 2;
    rev = "v2.0.2";
    owner  = "chmduquesne";
    repo   = "rollinghash";
    sha256 = "1krn9jjsjl8c1w09p8qyn3hfrgdbc3a465jzv6a6399fylxhgipf";
  };

  roundtrip = buildFromGitHub {
    version = 2;
    owner = "gravitational";
    repo = "roundtrip";
    date = "2017-03-20";
    rev = "4162b978cd8cbec3f35dea84aae8d5fc696363c7";
    sha256 = "0s1lmr264wdxhw8jnx7kifc89dcqdyb9sqg8nq2wc42dhrnm9f3m";
    propagatedBuildInputs = [
      trace
    ];
  };

  rpc = buildFromGitHub {
    version = 2;
    owner = "gorilla";
    repo = "rpc";
    rev = "v1.1.0";
    sha256 = "12qqc07dsi4vqc8wkmjlwdiyzh8fdzclmylbx93dxjfrav3psnl5";
  };

  rsc = buildFromGitHub {
    version = 2;
    owner = "mdp";
    repo = "rsc";
    date = "2016-01-31";
    rev = "90f07065088deccf50b28eb37c93dad3078c0f3c";
    sha256 = "0nibwihq09m5chhryi20dcjg9bbk4yy0x2asz0c8ln73hrcijdm1";
    buildInputs = [
      pkgs.qrencode
    ];
  };

  runc = buildFromGitHub {
    version = 2;
    rev = "v1.0.0-rc1";
    owner = "opencontainers";
    repo = "runc";
    sha256 = "f9d79f48bbaf1c385219bf8617a25eb88f9a81f25f1a168830700e8ea9004db1";
    propagatedBuildInputs = [
      dbus
      docker_for_runc
      fileutils
      go-systemd
      go-units
      gocapability
      libseccomp-golang
      logrus
      netlink
      protobuf
      runtime-spec
      urfave_cli
    ];
    meta.autoUpdate = false;
  };

  runtime-spec = buildFromGitHub {
    version = 2;
    rev = "v1.0.0-rc1";
    owner = "opencontainers";
    repo = "runtime-spec";
    sha256 = "f5b8967328a8c42eafac05ae8569f6e23cbb5b23d7af55072ee57c04c4622742";
    buildInputs = [
      gojsonschema
    ];
    meta.autoUpdate = false;
  };

  sanitized-anchor-name = buildFromGitHub {
    version = 2;
    owner = "shurcooL";
    repo = "sanitized_anchor_name";
    rev = "79c90efaf01eddc01945af5bc1797859189b830b";
    date = "2017-04-23";
    sha256 = "1w95v754i47x2lvan927vahx0w7akl0nkm307xf2qx9zx157qm3n";
  };

  scada-client = buildFromGitHub {
    version = 1;
    date = "2016-06-01";
    rev = "6e896784f66f82cdc6f17e00052db91699dc277d";
    owner  = "hashicorp";
    repo   = "scada-client";
    sha256 = "1by4kyd2hrrrghwj7snh9p8fdlqka24q9yr6nyja2acs2zpjgh7a";
    buildInputs = [
      armon_go-metrics
    ];
    propagatedBuildInputs = [
      net-rpc-msgpackrpc
      yamux
    ];
  };

  seed = buildFromGitHub {
    version = 2;
    rev = "e2103e2c35297fb7e17febb81e49b312087a2372";
    owner = "sean-";
    repo = "seed";
    sha256 = "0hnkw8zjiqkyffxfbgh1020dgy0vxzad1kby0kkm8ld3i5g0aq7a";
    date = "2017-03-13";
  };

  semver = buildFromGitHub {
    version = 2;
    rev = "v3.5.0";
    owner = "blang";
    repo = "semver";
    sha256 = "1maxa24la1y37dgngaw7ar7fykcxzix54xy60jhnfap8p0yrzs74";
  };

  serf = buildFromGitHub {
    version = 2;
    rev = "v0.8.1";
    owner  = "hashicorp";
    repo   = "serf";
    sha256 = "1afffipv2msa5062jlb52glmfsz9qh2zp58n847190j7b9mm93j9";

    buildInputs = [
      armon_go-metrics
      circbuf
      columnize
      go-syslog
      logutils
      mapstructure
      mdns
      memberlist
      mitchellh_cli
      ugorji_go
    ];
  };

  session = buildFromGitHub {
    version = 2;
    rev = "b8e286a0dba8f4999042d6b258daf51b31d08938";
    owner  = "go-macaron";
    repo   = "session";
    sha256 = "12a9irqcs1jsvxpfb6i1357r5xn14qchn4k9a211f4w1ddgiiw7d";
    date = "2017-03-20";
    propagatedBuildInputs = [
      gomemcache
      go-couchbase
      com
      ledisdb
      macaron_v1
      mysql
      nodb
      pq
      redis_v2
    ];
  };

  sets = buildFromGitHub {
    version = 1;
    rev = "6c54cb57ea406ff6354256a4847e37298194478f";
    owner  = "feyeleanor";
    repo   = "sets";
    sha256 = "11gg27znzsay5pn9wp7rl427v8bl1rsncyk8nilpsbpwfbz7q7vm";
    date = "2013-02-27";
    propagatedBuildInputs = [
      slices
    ];
  };

  sftp = buildFromGitHub {
    version = 2;
    owner = "pkg";
    repo = "sftp";
    rev = "dddd9cf3c7889aa0fefd2e8a529367a3e1f3b669";
    date = "2017-04-25";
    sha256 = "00nkf5kpf7jr2smkgsrs6426czxalpzn0p0lvgcjzgh0fx7dm59b";
    propagatedBuildInputs = [
      crypto
      errors
      fs
    ];
  };

  sha256-simd = buildFromGitHub {
    version = 2;
    owner = "minio";
    repo = "sha256-simd";
    date = "2017-04-24";
    rev = "f3ec2e4d36d43c3a899ed4b7d9f62188edcf5afd";
    sha256 = "1h446sfh2j000n7sz8qfv7q4jrvcmw0kdl0ibflwi6hy77ni1x9m";
  };

  skyring-common = buildFromGitHub {
    version = 2;
    owner = "skyrings";
    repo = "skyring-common";
    date = "2016-09-29";
    rev = "d1c0bb1cbd5ed8438be1385c85c4f494608cde1e";
    sha256 = "0wr3bw55daf8ryz46hviwvs1wz1l2c6x3rrccr70gllg74lg1wd5";
    buildInputs = [
      go-logging
      go-python
      gorequest
      graphite-golang
      influxdb
      mgo_v2
    ];
    postPatch = /* go-python now uses float64 */ ''
      sed -i tools/gopy/gopy.go \
        -e 's/python.PyFloat_FromDouble(f32)/python.PyFloat_FromDouble(f64)/'
    '';
  };

  slices = buildFromGitHub {
    version = 2;
    rev = "145c47818f5f4e3ab04935822b3bd440e54ffc45";
    owner  = "feyeleanor";
    repo   = "slices";
    sha256 = "1bgzczwymd0498gk9ikrdfw32s5cir9n1skrnz0jh5qwkxdljm9n";
    date = "2016-12-30";
    propagatedBuildInputs = [
      raw
    ];
  };

  slug = buildFromGitHub {
    version = 2;
    rev = "v1.0.3";
    owner  = "gosimple";
    repo   = "slug";
    sha256 = "1vb7bwls06fqpxnkwlsb0lbq0nic2hsd5dpf9g94h59avgnxilrz";
    propagatedBuildInputs = [
      com
      macaron_v1
      #unidecode
    ];
  };

  smux = buildFromGitHub {
    version = 2;
    rev = "v1.0.5";
    owner  = "xtaci";
    repo   = "smux";
    sha256 = "0k22a97v7s50a0d62vf7q9my66jg8h4gi27bf3a30amir75cggzb";
    propagatedBuildInputs = [
      errors
    ];
  };

  sortutil = buildFromGitHub {
    version = 1;
    date = "2015-06-17";
    rev = "4c7342852e65c2088c981288f2c5610d10b9f7f4";
    owner = "cznic";
    repo = "sortutil";
    sha256 = "11iykyi1d7vjmi7778chwbl86j6s1742vnd4k7n1rvrg7kq558xq";
  };

  spacelog = buildFromGitHub {
    version = 2;
    date = "2017-01-06";
    rev = "16604ed16156d8634877b208e8acc9279f399777";
    owner = "spacemonkeygo";
    repo = "spacelog";
    sha256 = "0rcqgs6n9hklscl0ay9wk36yknd4sim3hxkpii3zcf3sis2s1bh2";
    buildInputs = [ flagfile ];
  };

  speakeasy = buildFromGitHub {
    version = 2;
    date = "2017-04-17";
    rev = "4aabc24848ce5fd31929f7d1e4ea74d3709c14cd";
    owner = "bgentry";
    repo = "speakeasy";
    sha256 = "05w4vlyglkzgwhfp2ini4yd3l8zblpx8b5sfsy649hzh8mm5v68p";
  };

  spec = buildFromGitHub {
    version = 2;
    date = "2017-04-13";
    rev = "e51c28f07047ad90caff03f6450908720d337e0c";
    owner  = "go-openapi";
    repo   = "spec";
    sha256 = "0vjwzncllssv75f6q2kpd1y0dfv6spk1zr2vsdsmr70cjpcicir9";
    propagatedBuildInputs = [
      jsonpointer
      jsonreference
      swag
    ];
  };

  srslog = buildFromGitHub {
    version = 2;
    rev = "a974ba6f7fb527d2ddc73ee9c05d3e2ccc0af0dc";
    date = "2017-01-06";
    owner  = "RackSec";
    repo   = "srslog";
    sha256 = "14714h9wkmb2i2flbljpmsa3mjvi27jkqwxc3rz1q67zbkv7vd1w";
  };

  stack = buildFromGitHub {
    version = 1;
    rev = "v1.5.2";
    owner = "go-stack";
    repo = "stack";
    sha256 = "0c75y18wb45n61ppgzb52k59p52g7221zcm435pz3ca0yhjz02q6";
  };

  stathat = buildFromGitHub {
    version = 1;
    date = "2016-07-15";
    rev = "74669b9f388d9d788c97399a0824adbfee78400e";
    owner = "stathat";
    repo = "go";
    sha256 = "19aki04z76qzgdr8l3zlz904mkalspfa46cja2fdjy70sfvfjdp1";
  };

  statik = buildFromGitHub {
    version = 2;
    owner = "rakyll";
    repo = "statik";
    date = "2017-04-10";
    rev = "89fe3459b5c829c32e89bdff9c43f18aad728f2f";
    sha256 = "027iy2yrppplr4yc14ixriaar5m6b1y3x3z0svlfi8b5n62l5frm";
    postPatch = /* Remove recursive import of itself */ ''
      sed -i example/main.go \
        -e '/"github.com\/rakyll\/statik\/example\/statik"/d'
    '';
  };

  structs = buildFromGitHub {
    version = 2;
    rev = "v1.0.0";
    owner  = "fatih";
    repo   = "structs";
    sha256 = "10v55lsqanmxpg1647bmrjdz00fbn4nv4ffali5b8s9lg3j3jgga";
  };

  stump = buildFromGitHub {
    version = 1;
    date = "2016-06-11";
    rev = "206f8f13aae1697a6fc1f4a55799faf955971fc5";
    owner = "whyrusleeping";
    repo = "stump";
    sha256 = "0qmchkr29rzscc148aw2vb2qf5dma2dka0ys96cx5fxa4p516d3i";
  };

  strutil = buildFromGitHub {
    version = 2;
    date = "2017-01-31";
    rev = "43a89592ed56c227c7fdb1fcaf7d1d08be02ec54";
    owner = "cznic";
    repo = "strutil";
    sha256 = "16lv9wc7b8371b08n5hr6mlnllnj60is7mhcpbnk247g25160wp0";
  };

  suture = buildFromGitHub {
    version = 2;
    rev = "v2.0.1";
    owner  = "thejerf";
    repo   = "suture";
    sha256 = "0jhzl8ihadxyw76h58ijwy73nh390knhkxlgnvfnsfwgf7irghd0";
  };

  swag = buildFromGitHub {
    version = 2;
    rev = "24ebf76d720bab64f62824d76bced3184a65490d";
    owner = "go-openapi";
    repo = "swag";
    sha256 = "0ly58lkcvbx0gk0gg374p48dqnd9krbsz8048f2y9scwhsh1bdys";
    date = "2017-04-24";
    propagatedBuildInputs = [
      easyjson
      yaml_v2
    ];
  };

  swift = buildFromGitHub {
    version = 2;
    rev = "8e9b10220613abdbc2896808ee6b43e411a4fa6c";
    owner  = "ncw";
    repo   = "swift";
    sha256 = "0rp54ghj07dvb6501kvhijq8cnl72k6m99baxqk7jjda8fd2kk0r";
    date = "2017-03-15";
  };

  anacrolix_sync = buildFromGitHub {
    version = 2;
    rev = "d29d95568d362a0008c1ffbaea39a3449ea67509";
    owner  = "anacrolix";
    repo   = "sync";
    sha256 = "1bfwg17qh4s91rzd4wgczmvi4c67kfdh71dr8qnbwr76qavybl10";
    date = "2016-12-14";
    buildInputs = [
      missinggo
    ];
  };

  syncthing = buildFromGitHub rec {
    version = 2;
    rev = "v0.14.27";
    owner = "syncthing";
    repo = "syncthing";
    sha256 = "06i7ci4zfi78cgsb27mndsbw6d7vcwb4fn3nq3wyfpdql5hmmvi4";
    buildFlags = [ "-tags noupgrade" ];
    buildInputs = [
      AudriusButkevicius_cli
      crypto
      du
      gateway
      geoip2-golang
      glob
      go-deadlock
      go-lz4
      go-nat-pmp
      go-stun
      gogo_protobuf
      goleveldb
      groupcache
      kcp-go
      luhn
      net
      osext
      pfilter
      pq
      qart
      ql
      rcrowley_go-metrics
      rollinghash
      sha256-simd
      smux
      suture
      text
      time
      xdr
    ];
    postPatch = ''
      # Mostly a cosmetic change
      sed -i 's,unknown-dev,${rev},g' cmd/syncthing/main.go
    '';
    preBuild = ''
      pushd go/src/$goPackagePath
      go run script/genassets.go gui > lib/auto/gui.files.go
      popd
    '';
  };

  syncthing-lib = buildFromGitHub {
    inherit (syncthing) rev owner repo sha256 version;
    subPackages = [
      "lib/sync"
      "lib/logger"
      "lib/protocol"
      "lib/osutil"
      "lib/tlsutil"
      "lib/dialer"
      "lib/relay/client"
      "lib/relay/protocol"
    ];
    propagatedBuildInputs = [ go-lz4 luhn xdr text suture du net ];
  };

  syslogparser = buildFromGitHub {
    version = 1;
    rev = "ff71fe7a7d5279df4b964b31f7ee4adf117277f6";
    date = "2015-07-17";
    owner  = "jeromer";
    repo   = "syslogparser";
    sha256 = "1x1nq7kyvmfl019d3rlwx9nqlqwvc87376mq3xcfb7f5vxlmz9y5";
  };

  tablewriter = buildFromGitHub {
    version = 2;
    rev = "febf2d34b54a69ce7530036c7503b1c9fbfdf0bb";
    date = "2017-01-28";
    owner  = "olekukonko";
    repo   = "tablewriter";
    sha256 = "0wava2c1by6cdrm0kxf1ldkayip6sivlwankgrhiw6sj645w5km9";
    propagatedBuildInputs = [
      go-runewidth
    ];
  };

  tagflag = buildFromGitHub {
    version = 1;
    rev = "e7497e81ffa475caf0fc24e999eb29edc0335040";
    date = "2016-06-15";
    owner  = "anacrolix";
    repo   = "tagflag";
    sha256 = "3515c691c6ecc867e3e539048b9ca331ccb654c1890cde460748b9b3043eba5a";
    propagatedBuildInputs = [
      go-humanize
      iter
      missinggo_lib
      xstrings
    ];
    meta.autoUpdate = false;
  };

  tail = buildFromGitHub {
    version = 2;
    rev = "faf842bde7ed83bbc3c65a2c454fae39bc29a95f";
    owner  = "hpcloud";
    repo   = "tail";
    sha256 = "1mxqwvslhjkpn1qfbzmca5p3r75jz2myi95cq76cdd1w9prigihb";
    propagatedBuildInputs = [
      fsnotify_v1
      tomb_v1
    ];
    date = "2017-02-06";
  };

  tar-split = buildFromGitHub {
    version = 2;
    owner = "vbatts";
    repo = "tar-split";
    rev = "bd4c5d64c3e9297f410025a3b1bd0c58f659e721";
    date = "2016-09-26";
    sha256 = "e317e4bb73fab3e03ff34b96a861fec72e716f61fc01343876131e50dfacc402";
    propagatedBuildInputs = [
      urfave_cli
      logrus
    ];
  };

  tar-utils = buildFromGitHub {
    version = 1;
    rev = "beab27159606f5a7c978268dd1c3b12a0f1de8a7";
    date = "2016-03-22";
    owner  = "whyrusleeping";
    repo   = "tar-utils";
    sha256 = "0p0cmk30b22bgfv4m29nnk2359frzzgin2djhysrqznw3wjpn3nz";
  };

  tb = buildFromGitHub {
    version = 2;
    owner = "tsenart";
    repo = "tb";
    rev = "19f4c3d79d2bd67d0911b2e310b999eeea4454c1";
    date = "2015-12-08";
    sha256 = "fb8fb335f10f48e641b3a6abcfe3eb20737cfb5a71aa6b6dbd3399aaedcb8fad";
  };

  teleport = buildFromGitHub {
    version = 2;
    rev = "v2.0.4";
    owner = "gravitational";
    repo = "teleport";
    sha256 = "0lfbk2511bkavb5v112yij5g8m9rbrc54k2ry2i1xkxvq8c724gn";
    buildInputs = [
      aws-sdk-go
      bolt
      configure
      clockwork
      crypto
      docker_for_teleport
      etcd_client
      go-oidc
      go-shellwords
      goterm
      hotp
      httprouter
      gravitational_kingpin
      kubernetes-client-go_1-4
      lemma
      logrus
      net
      osext
      otp
      oxy
      pty
      roundtrip
      text
      timetools
      trace
      gravitational_ttlmap
      mailgun_ttlmap
      u2f
      pborman_uuid
      yaml
      yaml_v2
    ];
    excludedPackages = "\\(test\\|suite\\)";

    postPatch = ''
      sed \
        -e '/type HostKeyCallback/d' \
        -i lib/utils/utils.go \
        -i lib/client/api.go
      sed \
        -e '\#"golang.org/x/crypto/ssh"#d' \
        -i lib/utils/utils.go
      sed -i 's,HostKeyCallback HostKeyCallback,HostKeyCallback ssh.HostKeyCallback,g' lib/client/api.go
      sed 's,utils\.HostKeyCallback,ssh.HostKeyCallback,g' \
        -i lib/reversetunnel/agent.go \
        -i lib/client/client.go
    '';
  };

  template = buildFromGitHub {
    version = 1;
    rev = "a0175ee3bccc567396460bf5acd36800cb10c49c";
    owner = "alecthomas";
    repo = "template";
    sha256 = "10albmv2bdrrgzzqh1rlr88zr2vvrabvzv59m15wazwx39mqzd7p";
    date = "2016-04-05";
  };

  termbox-go = buildFromGitHub {
    version = 2;
    rev = "7994c181db7761ca3c67a217068cf31826113f5f";
    date = "2017-03-27";
    owner = "nsf";
    repo = "termbox-go";
    sha256 = "0xvim7nlrkapwv5hxfgh7m3p0crg900y58kf4b09z3pr0dnsv3lh";
    propagatedBuildInputs = [
      go-runewidth
    ];
  };

  testify = buildFromGitHub {
    version = 2;
    rev = "v1.1.4";
    owner = "stretchr";
    repo = "testify";
    sha256 = "0n3z8225px7rylkwz6rvf48ykrh591a7p8gc27a2dh2zskny5qsz";
    propagatedBuildInputs = [
      go-difflib
      go-spew
      objx
    ];
  };

  kr_text = buildFromGitHub {
    version = 2;
    rev = "7cafcd837844e784b526369c9bce262804aebc60";
    date = "2016-05-04";
    owner = "kr";
    repo = "text";
    sha256 = "0qmc5rl6rhafiqiqnfrajngzr7qmwfwnj18yccd8jkpd5ix4r70d";
    propagatedBuildInputs = [
      pty
    ];
  };

  timecache = buildFromGitHub {
    version = 2;
    rev = "cfcb2f1abfee846c430233aef0b630a946e0a5a6";
    date = "2016-09-10";
    owner  = "whyrusleeping";
    repo   = "timecache";
    sha256 = "0w65wbpf0fzxdj2f1d8km9hg91yp9519agdgb6v6jnxnjvi7d43j";
  };

  timetools = buildFromGitHub {
    version = 2;
    rev = "fd192d755b00c968d312d23f521eb0cdc6f66bd0";
    date = "2015-05-05";
    owner = "mailgun";
    repo = "timetools";
    sha256 = "0ja8k6b1gp99jifm9ljkwfrqsn00c87pz7alafmy34sc0xlxdcy9";
    propagatedBuildInputs = [
      mgo_v2
    ];
  };

  tokenbucket = buildFromGitHub {
    version = 1;
    rev = "c5a927568de7aad8a58127d80bcd36ca4e71e454";
    date = "2013-12-01";
    owner = "ChimeraCoder";
    repo = "tokenbucket";
    sha256 = "11zasaakzh4fzzmmiyfq5mjqm5md5bmznbhynvpggmhkqfbc28gz";
  };

  tomb_v2 = buildFromGitHub {
    version = 2;
    date = "2016-12-08";
    rev = "d5d1b5820637886def9eef33e03a27a9f166942c";
    owner = "go-tomb";
    repo = "tomb";
    sha256 = "0azb4hkv41wl750wapl4jbnpvn1jg54z1clcnqvvs84rh75ywqj1";
    goPackagePath = "gopkg.in/tomb.v2";
    buildInputs = [
      net
    ];
  };

  tomb_v1 = buildFromGitHub {
    version = 1;
    date = "2014-10-24";
    rev = "dd632973f1e7218eb1089048e0798ec9ae7dceb8";
    owner = "go-tomb";
    repo = "tomb";
    sha256 = "1gn3f185fihpd5ccr04bp2iprj75jyx803a6i9b3avbcmn24w7xa";
    goPackagePath = "gopkg.in/tomb.v1";
  };

  toml = buildFromGitHub {
    version = 2;
    owner = "BurntSushi";
    repo = "toml";
    rev = "v0.3.0";
    sha256 = "1cnryizxrj7si27knhh83dd03abw5r0yhac2vmv861inpl3lflx2";
    goPackageAliases = [ "github.com/burntsushi/toml" ];
  };

  trace = buildFromGitHub {
    version = 2;
    owner = "gravitational";
    repo = "trace";
    rev = "b92ddf40136862e750726ad5f16f892b588d0006";
    sha256 = "0l4l2ip1q918q8jknscnk0ri0b3fi7xkqn1a0jwipb45w8g5yr96";
    date = "2017-03-20";
    propagatedBuildInputs = [
      clockwork
      grpc
      logrus
      net
    ];
  };

  gravitational_ttlmap = buildFromGitHub {
    version = 2;
    owner = "gravitational";
    repo = "ttlmap";
    rev = "348cf76cace4d93fdacc38dfdaa2306f4f0e9c16";
    sha256 = "00z54zc4g5h8qdwdqhkycyjl705sg7bb1iilkmrdh04n602wdwr0";
    date = "2016-04-07";
    propagatedBuildInputs = [
      clockwork
      minheap
    ];
  };

  mailgun_ttlmap = buildFromGitHub {
    version = 2;
    owner = "mailgun";
    repo = "ttlmap";
    rev = "8210f93bcb6393a9f36a22ac02fb3c4f53289850";
    sha256 = "1ir31h07xmjwkn0mnx3hkp6mj0x1qa58ling09czxqjqwm263ab3";
    date = "2016-08-25";
    propagatedBuildInputs = [
      minheap
      timetools
    ];
  };

  u2f = buildFromGitHub {
    version = 2;
    rev = "eb799ce68da4150b16ff5d0c89a24e2a2ad993d8";
    owner = "tstranex";
    repo = "u2f";
    sha256 = "8b2e6912aeced8aa055feedbbe3de2ef065666b81181eb1c9e2826cc6d37f81f";
    date = "2016-05-08";
    meta.autoUpdate = false;
  };

  units = buildFromGitHub {
    version = 1;
    rev = "2efee857e7cfd4f3d0138cc3cbb1b4966962b93a";
    owner = "alecthomas";
    repo = "units";
    sha256 = "1jj055kgx6mfx5zw263ci70axk3z5006db74dqhcilxwk1a2ga23";
    date = "2015-10-22";
  };

  urlesc = buildFromGitHub {
    version = 2;
    owner = "PuerkitoBio";
    repo = "urlesc";
    rev = "bbf7a2afc14f93e1e0a5c06df524fbd75e5031e5";
    sate = "2015-02-08";
    sha256 = "0rmcdn7z2rvms4j3pjbwbydffgl4s9igcjcfyin47sss0ywf6pmd";
    date = "2017-03-24";
  };

  usage-client = buildFromGitHub {
    version = 2;
    owner = "influxdata";
    repo = "usage-client";
    date = "2016-08-29";
    rev = "6d3895376368aa52a3a81d2a16e90f0f52371967";
    sha256 = "37a9a3330c2a7fac370ccb7117c681dd6fafeef57d327b3071ec13a279fa7996";
  };

  utp = buildFromGitHub {
    version = 2;
    rev = "1a2093d4dfa2a614da54529a1d63109e7ae34f93";
    owner  = "anacrolix";
    repo   = "utp";
    sha256 = "1g9np02sb7zymbbw1141vjpmxz8s08msgcxsj9317j1b0yrnf6n6";
    date = "2017-04-12";
    propagatedBuildInputs = [
      envpprof
      missinggo
      anacrolix_sync
    ];
  };

  pborman_uuid = buildFromGitHub {
    version = 2;
    rev = "1b00554d822231195d1babd97ff4a781231955c9";
    owner = "pborman";
    repo = "uuid";
    sha256 = "0frx4d0459axn4s30ipdagfr28xxz491fxl01igg3g03z7flkf5p";
    date = "2017-01-12";
  };

  satori_uuid = buildFromGitHub {
    version = 2;
    rev = "5bf94b69c6b68ee1b541973bb8e1144db23a194b";
    owner = "satori";
    repo = "uuid";
    sha256 = "0qjww7ng1amsn9m3lhnbxalvlv0gndl86g7l6rsxaybhvbcpr15s";
    date = "2017-03-21";
  };

  vault = buildFromGitHub {
    version = 2;
    rev = "v0.7.0";
    owner = "hashicorp";
    repo = "vault";
    sha256 = "1i7jhg1wy513iq1i6b94b2nv3760gppwrqpjdmjdrpp9im0cp3pz";

    nativeBuildInputs = [
      pkgs.protobuf-cpp
      protobuf.bin
    ];

    buildInputs = [
      armon_go-metrics
      aws-sdk-go
      azure-storage-go
      columnize
      consul_api
      copystructure
      crypto
      duo_api_golang
      errwrap
      etcd_for_vault
      go-cleanhttp
      go-colorable
      go-crypto
      go-github
      go-homedir
      go-mssqldb
      go-multierror
      go-okta
      go-radix
      go-rootcerts
      go-semver
      go-syslog
      go-zookeeper
      gocql
      golang-lru
      google-api-go-client
      google-cloud-go
      govalidator
      grpc
      hashicorp_go-uuid
      hcl
      jose
      jsonx
      ldap
      logxi
      mapstructure
      mgo_v2
      mitchellh_cli
      mysql
      net
      oauth2
      pester
      pkcs7
      pq
      protobuf
      rabbit-hole
      radius
      reflectwalk
      scada-client
      structs
      swift
      sys
      yaml
    ];

    patches = [
      (fetchTritonPatch {
        rev = "afbb3f809c7c0fca94d4749ba409ae23e17ec169";
        file = "v/vault/fix-azure.patch";
        sha256 = "fdea3eaa88a15ea3ccf548ea1c3ab92bfaf2e710fb0e390b664e5efba2c52d18";
      })
    ];

    # Remove in 0.7.1
    postPatch = ''
      sed -i 's,Config: \*tlsConfig,Config: tlsConfig,g' builtin/logical/cassandra/util.go
    '';

    # Regerate protos
    preBuild = ''
      srcDir="$(pwd)"/go/src
      pushd go/src/$goPackagePath >/dev/null
      find . -name \*pb.go -delete
      for file in $(find . -name \*.proto | sort | uniq); do
        pushd "$(dirname "$file")" > /dev/null
        echo "Regenerating protobuf: $file" >&2
        protoc -I "$srcDir" -I "$srcDir/$goPackagePath" -I . --go_out=plugins=grpc:. "$(basename "$file")"
        popd >/dev/null
      done
      popd >/dev/null
    '';
  };

  vault_api = buildFromGitHub {
    inherit (vault) rev owner repo sha256 version;
    subPackages = [
      "api"
      "helper/compressutil"
      "helper/jsonutil"
    ];
    propagatedBuildInputs = [
      hcl
      go-cleanhttp
      go-multierror
      go-rootcerts
      mapstructure
      net
      pester
      structs
    ];
  };

  viper = buildFromGitHub {
    version = 2;
    owner = "spf13";
    repo = "viper";
    rev = "0967fc9aceab2ce9da34061253ac10fb99bba5b2";
    date = "2017-04-17";
    sha256 = "1kc3m6637gnw6hm84qsadn0pijiaqd77ih1vbak27swgg7c7dcjn";
    buildInputs = [
      crypt
      pflag
    ];
    propagatedBuildInputs = [
      afero
      cast
      fsnotify
      go-toml
      hcl
      jwalterweatherman
      mapstructure
      properties
      #toml
      yaml_v2
    ];
  };

  vultr = buildFromGitHub {
    version = 2;
    rev = "1.13.0";
    owner  = "JamesClonk";
    repo   = "vultr";
    sha256 = "0ksm28mygg0g7md7n0a1hbcg91rp27v8qnhcwwjv5cncmzmp381n";
    propagatedBuildInputs = [
      crypto
      mow-cli
      tokenbucket
      ratelimit
    ];
  };

  websocket = buildFromGitHub {
    version = 2;
    rev = "v1.1.0";
    owner  = "gorilla";
    repo   = "websocket";
    sha256 = "0qrvpvjnsi9bash1x8fhnj1fnpgydxjvys2adbkih2vys20a3hch";
  };

  w32 = buildFromGitHub {
    version = 2;
    rev = "bb4de0191aa41b5507caa14b0650cdbddcd9280b";
    owner = "shirou";
    repo = "w32";
    sha256 = "021764v4m4xp2xdsnlzx6871h5l8vraww39qig7sjsvbpw0v1igx";
    date = "2016-09-30";
  };

  wmi = buildFromGitHub {
    version = 2;
    rev = "ea383cf3ba6ec950874b8486cd72356d007c768f";
    owner = "StackExchange";
    repo = "wmi";
    sha256 = "00s17x9649l6j5i89ccbg3lx0md0ly858yyszn1j7xkx5nkhdq01";
    date = "2017-04-10";
    buildInputs = [
      go-ole
    ];
  };

  yaml = buildFromGitHub {
    version = 2;
    rev = "v1.0.0";
    owner = "ghodss";
    repo = "yaml";
    sha256 = "00g8p1grc0m34m55s3572d0d22f4vmws39f4vxp6djs4i2rzrqx3";
    propagatedBuildInputs = [
      yaml_v2
    ];
  };

  yaml_v2 = buildFromGitHub {
    version = 2;
    rev = "cd8b52f8269e0feb286dfeef29f8fe4d5b397e0b";
    date = "2017-04-07";
    owner = "go-yaml";
    repo = "yaml";
    sha256 = "1dvq75d687rmj49hqzbhv6bbjn7arpkgzla911yv3aps766gx33s";
    goPackagePath = "gopkg.in/yaml.v2";
  };

  yaml_v1 = buildFromGitHub {
    version = 1;
    rev = "9f9df34309c04878acc86042b16630b0f696e1de";
    date = "2014-09-24";
    owner = "go-yaml";
    repo = "yaml";
    sha256 = "128xs9pdz042hxl28fi2gdrz5ny0h34xzkxk5rxi9mb5mq46w8ys";
    goPackagePath = "gopkg.in/yaml.v1";
  };

  yamux = buildFromGitHub {
    version = 1;
    date = "2016-07-20";
    rev = "d1caa6c97c9fc1cc9e83bbe34d0603f9ff0ce8bd";
    owner  = "hashicorp";
    repo   = "yamux";
    sha256 = "19frd5lldxrjybdj8a3al3bq2wn0bghrnldxvrydr5ysf782qalw";
  };

  xdr = buildFromGitHub {
    version = 2;
    rev = "08e072f9cb164f943a92eb59f90f3abc64ac6e8f";
    owner  = "calmh";
    repo   = "xdr";
    sha256 = "01dmdnxvrj40s65w729pjdjh6bf18lm3k57b1mx0z3xql00xsc4k";
    date = "2017-01-04";
  };

  xhandler = buildFromGitHub {
    version = 2;
    owner = "rs";
    repo = "xhandler";
    date = "2016-06-18";
    rev = "ed27b6fd65218132ee50cd95f38474a3d8a2cd12";
    sha256 = "14e5d9f09a28bff8a9687e2f1d2250e034852b2dd784eb8c1ee04fac676f9357";
    propagatedBuildInputs = [
      net
    ];
  };

  xorm = buildFromGitHub {
    version = 2;
    rev = "v0.6.2";
    owner  = "go-xorm";
    repo   = "xorm";
    sha256 = "13bmig019sg9jy5n6mvri7iz1hs3msh7grnpl4gma504s40m5ysv";
    propagatedBuildInputs = [
      core
    ];
  };

  xstrings = buildFromGitHub {
    version = 1;
    rev = "3959339b333561bf62a38b424fd41517c2c90f40";
    date = "2015-11-30";
    owner  = "huandu";
    repo   = "xstrings";
    sha256 = "16l1cqpqsgipa4c6q55n8vlnpg9kbylkx1ix8hsszdikj25mcig1";
  };

  xxhash = buildFromGitHub {
    version = 2;
    rev = "09e1e23aaa83fc6b47aa8aedbb62846c521ede77";
    owner  = "cespare";
    repo   = "xxhash";
    sha256 = "10axqp9jvwj7ssqh11qzx3k5n6b7rq5zvk7jlna54bxdvqlfmrwd";
    date = "2017-03-30";
  };

  zap = buildFromGitHub {
    version = 2;
    rev = "v1.3.0";
    owner  = "uber-go";
    repo   = "zap";
    sha256 = "1x8a8j9dhkam4vpm97qr8zk0kb4rjcdlvm7mgqkg7lzaas0lnhnf";
    goPackagePath = "go.uber.org/zap";
    goPackageAliases = [
      "github.com/uber-go/zap"
    ];
    propagatedBuildInputs = [
      atomic
    ];
  };

  zappy = buildFromGitHub {
    version = 1;
    date = "2016-07-23";
    rev = "2533cb5b45cc6c07421468ce262899ddc9d53fb7";
    owner = "cznic";
    repo = "zappy";
    sha256 = "1fn4kqiggz6b5srkqhn37nwsi381x6hx3n83cbg0fxcb7zb3b6xl";
    buildInputs = [
      mathutil
    ];
    extraSrcs = [
      {
        inherit (internal)
          goPackagePath
          src;
      }
    ];
  };
}; in self
