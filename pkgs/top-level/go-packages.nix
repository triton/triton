/* This file defines the composition for Go packages. */

{ stdenv
, buildGoPackage
, fetchbzr
, fetchFromBitbucket
, fetchFromGitHub
, fetchgit
, fetchhg
, fetchTritonPatch
, fetchurl
, fetchzip
, git
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

  buildFromGitHub =
    { rev
    , date ? null
    , owner
    , repo
    , sha256
    , version
    , gxSha256 ? null
    , goPackagePath ? "github.com/${owner}/${repo}"
    , name ? baseNameOf goPackagePath
    , ...
    } @ args:
    buildGoPackage (args // (let
        name' = "${name}-${if date != null then date else if builtins.stringLength rev != 40 then rev else stdenv.lib.strings.substring 0 7 rev}";
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
      })
  );

  ## OFFICIAL GO PACKAGES

  appengine = buildFromGitHub {
    version = 1;
    rev = "4f7eeb5305a4ba1966344836ba4af9996b7b4e05";
    date = "2016-08-19";
    owner = "golang";
    repo = "appengine";
    sha256 = "1w9k4s5kd67pi8k4w78ffsl238fw2kjq88z4bnkp1sm1zg0bki0w";
    goPackagePath = "google.golang.org/appengine";
    propagatedBuildInputs = [
      protobuf
      net
    ];
  };

  crypto = buildFromGitHub {
    version = 2;
    rev = "e311231e83195f401421a286060d65643f9c9d40";
    date = "2016-09-12";
    owner    = "golang";
    repo     = "crypto";
    sha256 = "12k79wb3qq0jx722s3275nw25f7i71nydwbj4n83b71gqrix16ba";
    goPackagePath = "golang.org/x/crypto";
    goPackageAliases = [
      "code.google.com/p/go.crypto"
      "github.com/golang/crypto"
    ];
    buildInputs = [
      net_crypto_lib
    ];
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
    rev = "749a502dd1eaf3e5bfd4f8956748c502357c0bbe";
    date = "2016-09-12";
    owner  = "golang";
    repo   = "net";
    sha256 = "0nvcbc9bk03c0wsdmgm53184h5wr84zg679ggv8hpkg14d122rvw";
    goPackagePath = "golang.org/x/net";
    goPackageAliases = [
      "code.google.com/p/go.net"
      "github.com/hashicorp/go.net"
      "github.com/golang/net"
    ];
    propagatedBuildInputs = [ text crypto ];
  };

  net_crypto_lib = buildFromGitHub {
    inherit (net) rev date owner repo sha256 version goPackagePath;
    subPackages = [
      "context"
    ];
  };

  oauth2 = buildFromGitHub {
    version = 2;
    rev = "3c3a985cb79f52a3190fbc056984415ca6763d01";
    date = "2016-08-26";
    owner = "golang";
    repo = "oauth2";
    sha256 = "0519swla7184nvn62bpvrvlpwxxgrmq5vdf37v92ipda31l5hvm9";
    goPackagePath = "golang.org/x/oauth2";
    goPackageAliases = [ "github.com/golang/oauth2" ];
    propagatedBuildInputs = [
      net
      gcloud-golang-compute-metadata
    ];
  };


  protobuf = buildFromGitHub {
    version = 2;
    rev = "1f49d83d9aa00e6ce4fc8258c71cc7786aec968a";
    date = "2016-08-24";
    owner = "golang";
    repo = "protobuf";
    sha256 = "0q04is47nj8bryh548k5j52c62w4h2x2lw8rr34257xqp7i51vmc";
    goPackagePath = "github.com/golang/protobuf";
    goPackageAliases = [
      "code.google.com/p/goprotobuf"
    ];
  };

  snappy = buildFromGitHub {
    version = 1;
    rev = "d9eb7a3d35ec988b8585d4a0068e462c27d28380";
    date = "2016-05-29";
    owner  = "golang";
    repo   = "snappy";
    sha256 = "1z7xwm1w0nh2p6gdp0cg6hvzizs4zjn43c7vrm1fmf3sdvp6pxnw";
    goPackageAliases = [
      "code.google.com/p/snappy-go/snappy"
    ];
  };

  sys = buildFromGitHub {
    version = 2;
    rev = "30de6d19a3bd89a5f38ae4028e23aaa5582648af";
    date = "2016-09-07";
    owner  = "golang";
    repo   = "sys";
    sha256 = "1a1j8cycykcd91h22rp0bk6zjy9nln2qpxiggpjcpd3szl9k99zv";
    goPackagePath = "golang.org/x/sys";
    goPackageAliases = [
      "github.com/golang/sys"
    ];
  };

  text = buildFromGitHub {
    version = 2;
    rev = "1e65e9bf72c307081cea196f47ef37aed17eb316";
    date = "2016-08-30";
    owner = "golang";
    repo = "text";
    sha256 = "00749d88qv12k0jh295shjd5vxbz701p8vzma57vdnm1m4zmv2mq";
    goPackagePath = "golang.org/x/text";
    goPackageAliases = [ "github.com/golang/text" ];
  };

  tools = buildFromGitHub {
    version = 1;
    rev = "8ea9d4606980305f7f46cabde046adbb530e71c8";
    date = "2016-08-01";
    owner = "golang";
    repo = "tools";
    sha256 = "1g1dwvvynvl4zpcihq4h4mga9gv1c7ba7j7p5qw2nj1j18jb2r3y";
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

    buildInputs = [ appengine net ];

    # Do not copy this without a good reason for enabling
    # In this case tools is heavily coupled with go itself and embeds paths.
    allowGoReference = true;

    # Set GOTOOLDIR for derivations adding this to buildInputs
    postInstall = ''
      mkdir -p $bin/nix-support
      echo "export GOTOOLDIR=$bin/bin" >> $bin/nix-support/setup-hook
    '';
  };


  ## THIRD PARTY

  ace = buildFromGitHub {
    version = 1;
    owner = "yosssi";
    repo = "ace";
    rev = "71afeb714739f9d5f7e1849bcd4a0a5938e1a70d";
    date = "2016-01-02";
    sha256 = "1alfpk0wa73bxpl5g2my7xbimxqii7l24znm5b2cn0307qj0pclz";
    buildInputs = [
      gohtml
    ];
  };

  afero = buildFromGitHub {
    version = 1;
    owner = "spf13";
    repo = "afero";
    rev = "1a8ecf8b9da1fb5306e149e83128fc447957d2a8";
    date = "2016-06-06";
    sha256 = "0987ijvvzba5xwkkiwp89czsp1s0sfaiv4nnsd0yvlf2zswp2zbk";
    propagatedBuildInputs = [
      sftp
      text
    ];
  };

  amber = buildFromGitHub {
    version = 1;
    owner = "eknkc";
    repo = "amber";
    rev = "91774f050c1453128146169b626489e60108ec03";
    date = "2016-04-21";
    sha256 = "0mimywnfvvjkvpyda48qr1xqijkz5k5qinf9qcwzydahjmif7j7q";
  };

  amqp = buildFromGitHub {
    version = 1;
    owner = "streadway";
    repo = "amqp";
    rev = "2e25825abdbd7752ff08b270d313b93519a0a232";
    date = "2016-03-11";
    sha256 = "03w1xc4adaiyywsrflrfb8hzsfvlsc1gprm5hycm6rzd6rw3c4jm";
  };

  ansi = buildFromGitHub {
    version = 1;
    owner = "mgutz";
    repo = "ansi";
    rev = "c286dcecd19ff979eeb73ea444e479b903f2cfcb";
    date = "2015-09-14";
    sha256 = "1yifpfc2bil9ljrbp6ia10xl10jd95bp4c3k5jfpjnym77a942vq";
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
    version = 1;
    rev = "v1.1";
    owner  = "go-asn1-ber";
    repo   = "asn1-ber";
    sha256 = "1mi96bl0jn3nrp4v5aqxgqf5zdndif1qdhdjgjayigjkl67770s3";
    goPackageAliases = [
      "github.com/nmcclain/asn1-ber"
      "github.com/vanackere/asn1-ber"
      "gopkg.in/asn1-ber.v1"
    ];
  };

  aws-sdk-go = buildFromGitHub {
    version = 1;
    rev = "v1.4.4";
    owner  = "aws";
    repo   = "aws-sdk-go";
    sha256 = "15mbjxgplad5frkya0ss6qlb6297k47vwwlj9dbl5ivnk7dr94j2";
    excludedPackages = "\\(awstesting\\|example\\)";
    propagatedBuildInputs = [
      ini
      go-jmespath
    ];
    preBuild = ''
      pushd go/src/$goPackagePath
      make generate
      popd
    '';
  };

  azure-sdk-for-go = buildFromGitHub {
    version = 1;
    date = "2016-08-16";
    rev = "b76e48ca78931d864ab3ef5b442c64d0be4fd078";
    owner  = "Azure";
    repo   = "azure-sdk-for-go";
    sha256 = "0sfrj2zbvya4c9yk9r7s7hi272jjxrx2s5i26imjw1bg7sk9h8xk";
    buildInputs = [
      go-autorest
      satori_uuid
    ];
  };

  b = buildFromGitHub {
    version = 1;
    date = "2016-07-16";
    rev = "bcff30a622dbdcb425aba904792de1df606dab7c";
    owner  = "cznic";
    repo   = "b";
    sha256 = "0zjr4spbgavwq4lvxzl3h8hrkbyjk49vq14jncpydrjw4a9qql95";
  };

  bigfft = buildFromGitHub {
    version = 1;
    date = "2013-09-13";
    rev = "a8e77ddfb93284b9d58881f597c820a2875af336";
    owner = "remyoudompheng";
    repo = "bigfft";
    sha256 = "1cj9zyv3shk8n687fb67clwgzlhv47y327180mvga7z741m48hap";
  };

  binding = buildFromGitHub {
    version = 1;
    date = "2016-07-12";
    rev = "9440f336b443056c90d7d448a0a55ad8c7599880";
    owner = "go-macaron";
    repo = "binding";
    sha256 = "1pfciq2flpavqg5v140xa1w2nwrmyfkp0lx331ainbxqbqc49mqh";
    buildInputs = [
      com
      compress
      macaron_v1
    ];
  };

  blackfriday = buildFromGitHub {
    version = 1;
    owner = "russross";
    repo = "blackfriday";
    rev = "1d6b8e9301e720b08a8938b8c25c018285885438";
    sha256 = "1cc7mqmgj55k3sz79iff3b4s7vjgf5afjqrdlm218wyjsszihq8k";
    propagatedBuildInputs = [
      sanitized-anchor-name
    ];
    date = "2016-05-31";
  };

  bolt = buildFromGitHub {
    version = 1;
    rev = "v1.3.0";
    owner  = "boltdb";
    repo   = "bolt";
    sha256 = "1kjbih12cs9x380d5fb0qrx6n63pkfb2j9hnqrr95gz2215pqczp";
  };

  btree = buildFromGitHub {
    version = 1;
    rev = "7d79101e329e5a3adf994758c578dab82b90c017";
    owner  = "google";
    repo   = "btree";
    sha256 = "0ky9a9r1i3awnjisk8bkw4d9v5jkcm9w6sphd889vxdhvizvkskl";
    date = "2016-05-24";
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

  candiedyaml = buildFromGitHub {
    version = 1;
    date = "2016-04-29";
    rev = "99c3df83b51532e3615f851d8c2dbb638f5313bf";
    owner  = "cloudfoundry-incubator";
    repo   = "candiedyaml";
    sha256 = "104giv2wjiispfsm82q3lk5qjvfjgrqhhnxm2yma9i21klmvir0y";
  };

  cascadia = buildFromGitHub {
    version = 1;
    date = "2015-07-30";
    rev = "3ad29d1ad1c4f2023e355603324348cf1f4b2d48";
    owner  = "andybalholm";
    repo   = "cascadia";
    sha256 = "1nqw9sack3iwrp4agx8kqz6pyvw2pg6v3jvmqapsjai4v7inbvyj";
    propagatedBuildInputs = [
      net
    ];
  };

  cast = buildFromGitHub {
    version = 1;
    owner = "spf13";
    repo = "cast";
    rev = "27b586b42e29bec072fe7379259cc719e1289da6";
    date = "2016-03-03";
    sha256 = "1b2wmjq68h6g2g8b9yjnip26xkyqfnqppnmaixlpk43hakhxxggf";
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

  circbuf = buildFromGitHub {
    version = 1;
    date = "2015-08-26";
    rev = "bbbad097214e2918d8543d5201d12bfd7bca254d";
    owner  = "armon";
    repo   = "circbuf";
    sha256 = "0wgpmzh0ga2kh51r214jjhaqhpqr9l2k6p0xhy5a006qypk5fh2m";
  };

  circonus-gometrics = buildFromGitHub {
    version = 1;
    date = "2016-08-22";
    rev = "2f5be48ffb490e33065d1a4369754c989faab05c";
    owner  = "circonus-labs";
    repo   = "circonus-gometrics";
    sha256 = "1bw03rgml4lj0sf71dvii8m6hxv1qgr9yk4mk9yzvmgxa5ggh21l";
    propagatedBuildInputs = [
      circonusllhist
      go-retryablehttp
    ];
  };

  circonusllhist = buildFromGitHub {
    version = 1;
    date = "2016-05-25";
    rev = "d724266ae5270ae8b87a5d2e8081f04e307c3c18";
    owner  = "circonus-labs";
    repo   = "circonusllhist";
    sha256 = "0a8jkz7fjnfb6yjbzhr23q166ffdms9wq7mf6w3ahrk1sa34ndyr";
  };

  mitchellh_cli = buildFromGitHub {
    version = 1;
    date = "2016-08-15";
    rev = "fcf521421aa29bde1d93b6920dfce826d7932208";
    owner = "mitchellh";
    repo = "cli";
    sha256 = "0mwr7f87cbcjvjmr3k14xr3qkjxp9pnza00k4237ihhqp75nzarz";
    propagatedBuildInputs = [ crypto go-radix speakeasy go-isatty ];
  };

  urfave_cli = buildFromGitHub {
    version = 2;
    rev = "v1.18.1";
    owner = "urfave";
    repo = "cli";
    sha256 = "0vcmwlb9cp7jxza78wm3g2xwdw06fd5my7b43a2pgfhy0621jwi3";
    goPackageAliases = [
      "github.com/codegangsta/cli"
    ];
    buildInputs = [
      yaml_v2
    ];
  };

  clog = buildFromGitHub {
    version = 1;
    date = "2016-06-09";
    rev = "ae8f8315ad044b86ced2e0be9e3598e9dd94f38e";
    owner = "couchbase";
    repo = "clog";
    sha256 = "185c10ab80cn4jxdp915h428lm0r9zf1cqrfsjs71im3w3ankvsn";
  };

  cobra = buildFromGitHub {
    version = 1;
    owner = "spf13";
    repo = "cobra";
    rev = "6a8bd97bdb1fc0d08a83459940498ea49d3e8c93";
    date = "2016-06-21";
    sha256 = "13kgjxjm19lv6fxkvbqny4dgzqyqhsx444an9xzr7hm6lzb1g8hc";
    buildInputs = [
      pflag
      viper
    ];
    propagatedBuildInputs = [
      go-md2man
    ];
  };

  color = buildFromGitHub {
    version = 1;
    rev = "v1.0.0";
    owner  = "fatih";
    repo   = "color";
    sha256 = "1n83ychkd77x5mqvvlnmibncgdmfvbf0h10h663r1yi3y1sb2ij5";
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
    version = 1;
    rev = "9b3edd62028f107d7cabb19353292afd29311a4e";
    owner  = "ryanuber";
    repo   = "columnize";
    sha256 = "1j5qis2fc2a3241bmwzkmf7xcmasgh8717g939riizi9nx9n7nls";
    date = "2016-07-12";
  };

  com = buildFromGitHub {
    version = 1;
    rev = "28b053d5a2923b87ce8c5a08f3af779894a72758";
    owner  = "Unknwon";
    repo   = "com";
    sha256 = "0rl00hsj57xbpbj7bz1c9lqwq4lwh8i1yamm3gadzdxir9lysj91";
    date = "2015-10-08";
  };

  compress = buildFromGitHub {
    version = 1;
    rev = "v1.0";
    owner  = "klauspost";
    repo   = "compress";
    sha256 = "0v5pg1qsxnhzcasrgy7y1kkdmz7naca16vq40ln5ynrjqkda29w1";
    propagatedBuildInputs = [
      cpuid
      crc32
    ];
  };

  consul = buildFromGitHub {
    version = 1;
    rev = "v0.6.4";
    owner = "hashicorp";
    repo = "consul";
    sha256 = "0jvhhzbkdxcqj1jwc2h25qd996g3rv3csjaix14v6hds9nniqyww";

    buildInputs = [
      datadog-go circbuf armon_go-metrics go-radix speakeasy bolt
      go-bindata-assetfs go-dockerclient errwrap go-checkpoint
      go-immutable-radix go-memdb ugorji_go go-multierror go-reap go-syslog
      golang-lru hcl logutils memberlist net-rpc-msgpackrpc raft raft-boltdb
      scada-client yamux muxado dns mitchellh_cli mapstructure columnize
      copystructure hil hashicorp-go-uuid crypto sys
    ];

    propagatedBuildInputs = [
      go-cleanhttp
      serf
    ];

    # Keep consul.ui for backward compatability
    passthru.ui = pkgs.consul-ui;
  };

  consul_api = buildFromGitHub {
    version = 1;
    inherit (consul) owner repo;
    rev = "6af6baf02ced3f3163831290dc559583726770e9";
    date = "2016-07-29";
    sha256 = "a6c14a88a4e613df46b50d87571027dc1ecbccfd3c9382faf9f217f4de091ffb";
    propagatedBuildInputs = [
      go-cleanhttp
      serf
    ];
    subPackages = [
      "api"
      "lib"
      "tlsutil"
    ];
    meta.autoUpdate = false;
  };

  consul-template = buildFromGitHub {
    version = 1;
    rev = "v0.15.0";
    owner = "hashicorp";
    repo = "consul-template";
    sha256 = "04fppwf7hr11s15rgzfpnhgqrwzn6akp9phjrn9gymlp7ak3i4jc";

    buildInputs = [
      consul_api
      go-cleanhttp
      go-multierror
      go-reap
      go-syslog
      logutils
      mapstructure
      serf
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
    version = 1;
    date = "2016-08-03";
    rev = "cdac8253d00f2ecf0a0b19fbff173a9a72de4f82";
    owner = "mitchellh";
    repo = "copystructure";
    sha256 = "1ax94in2m43cs0wd321rxjw0hdqqfizypihwv2mipp3x247rp8pq";
    propagatedBuildInputs = [ reflectwalk ];
  };

  core = buildFromGitHub {
    version = 1;
    rev = "v0.5.4";
    owner = "go-xorm";
    repo = "core";
    sha256 = "0g40jrk6d06mh8d4pb7k2i22pvy4ffs5mgn2s7v7fnmji1jggkh4";
  };

  cpuid = buildFromGitHub {
    version = 1;
    rev = "v1.0";
    owner  = "klauspost";
    repo   = "cpuid";
    sha256 = "1bwp3mx8dik8ib8smf5pwbnp6h8p2ai4ihqijncd0f981r31c6ms";
    buildInputs = [
      net
    ];
  };

  crc32 = buildFromGitHub {
    version = 1;
    rev = "v1.0";
    owner  = "klauspost";
    repo   = "crc32";
    sha256 = "1hpy5fnzb4f9822050p4029rf023rrxy09dq0mi2xif18ghnzdli";
  };

  cronexpr = buildFromGitHub {
    version = 1;
    rev = "f0984319b44273e83de132089ae42b1810f4933b";
    owner  = "gorhill";
    repo   = "cronexpr";
    sha256 = "0d2c67spcyhr4bxzmnqsxnzbn6a8sw893wvc4cx7a3js4ydy7raz";
    date = "2016-03-18";
  };

  crypt = buildFromGitHub {
    version = 1;
    owner = "xordataexchange";
    repo = "crypt";
    rev = "749e360c8f236773f28fc6d3ddfce4a470795227";
    date = "2015-05-23";
    sha256 = "0zc00mpvqv7n1pz6fn6570wf9j8dc5d2m49yrqqygs52r2iarpx5";
    propagatedBuildInputs = [
      consul
      crypto
    ];
    patches = [
      (fetchTritonPatch {
       rev = "77ff70bae635d2ac5bae8c647120d336070a579e";
       file = "crypt/crypt-2015-05-remove-etcd-support.patch";
       sha256 = "e942558fc230884e4ddbbafd97f7a3ea56bacdfea90a24f8790d37c399265904";
      })
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
    version = 1;
    rev = "1.0.0";
    owner = "DataDog";
    repo = "datadog-go";
    sha256 = "13kjgqx5bs187fapqiirsaig950n2is0a35y2b7ap07dazxxxh3m";
  };

  dbus = buildFromGitHub {
    version = 1;
    rev = "v4.0.0";
    owner = "godbus";
    repo = "dbus";
    sha256 = "0q2qabf656sq0pd3candndd8nnkwwp4by4hlkxjn4fs85ld44i8s";
  };

  distribution = buildFromGitHub {
    version = 1;
    rev = "v2.5.0";
    owner = "docker";
    repo = "distribution";
    sha256 = "18vajvn1zb55ndjqnhqil6v6zvc48ggv3x5kipk7m2xn1rnzy40f";
  };

  distribution_engine-api = buildFromGitHub {
    inherit (distribution) rev owner repo sha256 version;
    subPackages = [
      "digest"
      "reference"
    ];
  };

  dns = buildFromGitHub {
    version = 1;
    rev = "db96a2b759cdef4f11a34506a42eb8d1290c598e";
    date = "2016-07-25";
    owner  = "miekg";
    repo   = "dns";
    sha256 = "1bkggzlhyd2pvw26rycsl6zkxsyd9g6ml5bpky8yyhlwb39w2snh";
  };

  weppos-dnsimple-go = buildFromGitHub {
    version = 1;
    rev = "65c1ca73cb19baf0f8b2b33219b7f57595a3ccb0";
    date = "2016-02-04";
    owner  = "weppos";
    repo   = "dnsimple-go";
    sha256 = "0v3vnp128ybzmh4fpdwhl6xmvd815f66dgdjzxarjjw8ywzdghk9";
  };

  docker = buildFromGitHub {
    version = 1;
    rev = "v1.12.1";
    owner = "docker";
    repo = "docker";
    sha256 = "011d2ny0qmscikbd69ky1snnj6572fvm83qw95i15xgc8ajrf7fz";
  };

  docker_for_runc = buildFromGitHub {
    inherit (docker) rev owner repo sha256 version;
    subPackages = [
      "pkg/mount"
      "pkg/symlink"
      "pkg/system"
      "pkg/term"
    ];
    propagatedBuildInputs = [
      go-units
    ];
  };

  docker_for_go-dockerclient = buildFromGitHub {
    inherit (docker) rev owner repo sha256 version;
    subPackages = [
      "opts"
      "pkg/archive"
      "pkg/fileutils"
      "pkg/homedir"
      "pkg/idtools"
      "pkg/ioutils"
      "pkg/pools"
      "pkg/promise"
      "pkg/stdcopy"
    ];
    propagatedBuildInputs = [
      engine-api
      go-units
      logrus
      net
      runc
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
    version = 1;
    rev = "v1.0.0";
    owner  = "calmh";
    repo   = "du";
    sha256 = "02gri7xy9wp8szxpabcnjr18qic6078k213dr5k5712s1pg87qmj";
  };

  duo_api_golang = buildFromGitHub {
    version = 1;
    date = "2016-06-24";
    rev = "60cf4266ffce4f3d8b332fb4af4558c8383dc970";
    owner = "duosecurity";
    repo = "duo_api_golang";
    sha256 = "1k865gc1x14fmlx2i0g19iwbj09zfkjxmdws8pzxzdns5dvxwbp4";
  };

  ed25519 = buildFromGitHub {
    version = 1;
    owner = "agl";
    repo = "ed25519";
    rev = "278e1ec8e8a6e017cd07577924d6766039146ced";
    sha256 = "0jsscj4n6wcp3zyphinr461kwkxgrx5365jymbqnhqzki759xm5h";
    date = "2015-08-30";
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
    rev = "v2.0.54";
    sha256 = "bae5ce04d03227fc34d875ffe230dc95891369e581ffeb596b4ed33fb74d103b";
    goPackagePath = "gopkg.in/olivere/elastic.v3";
    propagatedBuildInputs = [
      elastic_v2
    ];
  };

  emoji = buildFromGitHub {
    version = 1;
    owner = "kyokomi";
    repo = "emoji";
    rev = "v1.4";
    sha256 = "1k87kd0h4qk2klbxx3r86g07wk9mgrb0jhdj8kgd2hlgh45j4pd2";
  };

  encoding = buildFromGitHub {
    version = 2;
    owner = "jwilder";
    repo = "encoding";
    date = "2016-05-26";
    rev = "ac74639f65b2180a2e5eb5ff197f0c122441aed0";
    sha256 = "4577efbd2cfa6efe9bfc3d2023334c161a106ede885f7c34098e1da5adf6c539";
  };

  engine-api = buildFromGitHub {
    version = 1;
    rev = "v0.4.0";
    owner = "docker";
    repo = "engine-api";
    sha256 = "1cgqhlngxlvplp6p560jvh4p003nm93pl4wannnlhwhcjrd34vyy";
    propagatedBuildInputs = [
      distribution_engine-api
      go-connections
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
    version = 1;
    owner = "pkg";
    repo = "errors";
    rev = "v0.7.0";
    sha256 = "0nshc2ziy81cmnj8gv0v28875bk2q49kv5cqa04zk87kmh6bvkfj";
  };

  errwrap = buildFromGitHub {
    version = 1;
    date = "2014-10-27";
    rev = "7554cd9344cec97297fa6649b055a8c98c2a1e55";
    owner  = "hashicorp";
    repo   = "errwrap";
    sha256 = "02hsk2zbwg68w62i6shxc0lhjxz20p3svlmiyi5zjz988qm3s530";
  };

  etcd = buildFromGitHub {
    version = 1;
    owner = "coreos";
    repo = "etcd";
    rev = "v3.0.6";
    sha256 = "0hcjwi4hik4pq0bckx4b364480nrmw8ihf5x3dgxh0dl2fnjwhad";
    buildInputs = [
      pkgs.libpcap
      tablewriter
    ];
  };

  etcd-client = buildFromGitHub {
    inherit (etcd) rev owner repo sha256 version;
    subPackages = [
      "client"
      "pkg/fileutil"
      "pkg/pathutil"
      "pkg/tlsutil"
      "pkg/transport"
      "pkg/types"
    ];
    buildInputs = [
      ugorji_go
      go-systemd
      net
    ];
    propagatedBuildInputs = [
      pkg
    ];
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

  fileutil = buildFromGitHub {
    version = 1;
    date = "2015-07-08";
    rev = "1c9c88fbf552b3737c7b97e1f243860359687976";
    owner  = "cznic";
    repo   = "fileutil";
    sha256 = "0naps0miq8lk4k7k6c0l9583nv6wcdbs9zllvsjjv60h4fsz856a";
    buildInputs = [
      mathutil
    ];
  };

  flagfile = buildFromGitHub {
    version = 1;
    date = "2016-06-27";
    rev = "b6d6c459091af71c7ebb587296936c8dfe79d797";
    owner  = "spacemonkeygo";
    repo   = "flagfile";
    sha256 = "0rqhbijrp7i136pay3q6zp54rv29nzjbvw76i4ycalqd2kg22r7s";
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
    version = 1;
    owner = "fsnotify";
    repo = "fsnotify";
    rev = "v1.3.1";
    sha256 = "cffd92500f2452c6df734672d15ada139a551f936b3a0aa7046bc05609238493";
    propagatedBuildInputs = [
      sys
    ];
  };

  fsnotify_v1 = buildFromGitHub {
    version = 1;
    owner = "fsnotify";
    repo = "fsnotify";
    rev = "v1.3.1";
    sha256 = "f2deb2a1258f87d571b0cfc70c264e2a48a293034deb5b5a2efd53f8530853bb";
    goPackagePath = "gopkg.in/fsnotify.v1";
    propagatedBuildInputs = [
      sys
    ];
  };

  fsync = buildFromGitHub {
    version = 1;
    owner = "spf13";
    repo = "fsync";
    rev = "eefee59ad7de621617d4ff085cf768aab4b919b1";
    date = "2016-03-01";
    sha256 = "1qakm902mpdikkz7fngxvy6xczq7mvcmj0dkz6gr20h9l7h95lnh";
    buildInputs = [
      afero
    ];
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

  gcloud-golang = buildFromGitHub {
    version = 2;
    date = "2016-09-12";
    rev = "a269f2d160169f9263253a498878cc0d37710fe9";
    owner = "GoogleCloudPlatform";
    repo = "gcloud-golang";
    sha256 = "0scr3xwk2156pgix2f6iqv6h0mm7vdk5671jixwri7xwzc7h8g7y";
    goPackagePath = "cloud.google.com/go";
    goPackageAliases = [
      "google.golang.org/cloud"
    ];
    propagatedBuildInputs = [
      net
      oauth2
      protobuf
      google-api-go-client
      grpc
    ];
    excludedPackages = "oauth2";
    meta.useUnstable = true;
  };

  gcloud-golang-for-go4 = buildFromGitHub {
    inherit (gcloud-golang) rev date owner repo sha256 version goPackagePath goPackageAliases meta;
    subPackages = [
      "storage"
    ];
    propagatedBuildInputs = [
      google-api-go-client
      grpc
      net
      oauth2
    ];
  };

  gcloud-golang-compute-metadata = buildFromGitHub {
    inherit (gcloud-golang) rev date owner repo sha256 version goPackagePath goPackageAliases meta;
    subPackages = [ "compute/metadata" "internal" ];
    buildInputs = [ net ];
  };

  genproto = buildFromGitHub {
    version = 2;
    date = "2016-08-16";
    rev = "44808ed2d86e258615bb701d395cbbfe6686a3e6";
    owner  = "google";
    repo   = "go-genproto";
    goPackagePath = "google.golang.org/genproto";
    sha256 = "00bbwg0w389s9knb1hbspvik3kf9njl17ndjxbpxfmy6zzgi028c";
    propagatedBuildInputs = [
      grpc
      net
      protobuf
    ];
  };

  geoip2-golang = buildFromGitHub {
    version = 2;
    rev = "496a3cbcb65a3cb54497fe4ae2273319e85160a4";
    owner = "oschwald";
    repo = "geoip2-golang";
    sha256 = "1f99xladna7zckri2rj14nf1jf0gd1zxdd1jyxqi416ycm5mijx7";
    date = "2016-09-10";
    propagatedBuildInputs = [
      maxminddb-golang
    ];
  };

  gettext = buildFromGitHub {
    version = 1;
    rev = "305f360aee30243660f32600b87c3c1eaa947187";
    owner = "gosexy";
    repo = "gettext";
    sha256 = "0s1f99llg462mbcdmg2yp8l6ifq56v6qp8bw33ng5yrws91xflj7";
    date = "2016-06-02";
    buildInputs = [
      go-flags
      go-runewidth
    ];
  };

  ginkgo = buildFromGitHub {
    version = 2;
    rev = "7b6efc7d7b052568b49ac02d3141c9d7a5a494a4";
    owner = "onsi";
    repo = "ginkgo";
    sha256 = "1zrc3lf0cq1j600d5p9gfrn4mg43fn975nix82m55c4namqdgwpd";
    date = "2016-09-02";
  };

  glob = buildFromGitHub {
    version = 1;
    rev = "0.2.0";
    owner = "gobwas";
    repo = "glob";
    sha256 = "1lbijdwchj6v7qpy9mr0xzs3v2y868vrmsxk1y24dm6wpacz50jd";
  };

  siddontang_go = buildFromGitHub {
    version = 1;
    date = "2015-12-27";
    rev = "354e14e6c093c661abb29fd28403b3c19cff5514";
    owner = "siddontang";
    repo = "go";
    sha256 = "07vjjj60iag7afdh6v0xzlzf1kmmsp92l4hlwr71xpwn133p4kyw";
  };

  ugorji_go = buildFromGitHub {
    version = 1;
    date = "2016-08-08";
    rev = "4a1cb5252a6951f715a85d0e4be334c2a2dbf2a2";
    owner = "ugorji";
    repo = "go";
    sha256 = "0b6c3sxbsrpip2bwwd9d1yni27n5nwrjcbg0p78cgad9hjabd55s";
    goPackageAliases = [ "github.com/hashicorp/go-msgpack" ];
  };

  go4 = buildFromGitHub {
    version = 2;
    date = "2016-09-11";
    rev = "e7a2449258501866491620d4f47472e6100ca551";
    owner = "camlistore";
    repo = "go4";
    sha256 = "097ll3m8wbcr5ivcfwa47khw721sj4sd1fqkzyl1iwviyw8ycssd";
    goPackagePath = "go4.org";
    goPackageAliases = [ "github.com/camlistore/go4" ];
    buildInputs = [
      gcloud-golang-for-go4
      oauth2
      net
      sys
    ];
  };

  goamz = buildFromGitHub {
    version = 1;
    rev = "07a22c9653ddbb84a9c7feed933f1e0b945a07dc";
    owner  = "goamz";
    repo   = "goamz";
    sha256 = "0myiamia3lccrcym7q6qzn0086mqs9j59bh6064ikcbbvpx7k1a1";
    date = "2016-08-06";
    goPackageAliases = [
      "github.com/mitchellh/goamz"
    ];
    excludedPackages = "testutil";
    buildInputs = [
      go-ini
      go-simplejson
      sets
    ];
  };

  goautoneg = buildGoPackage rec {
    name = "goautoneg-2012-07-07";
    goPackagePath = "bitbucket.org/ww/goautoneg";
    rev = "75cd24fc2f2c2a2088577d12123ddee5f54e0675";

    src = fetchFromBitbucket {
      version = 1;
      inherit rev;
      owner  = "ww";
      repo   = "goautoneg";
      sha256 = "9acef1c250637060a0b0ac3db033c1f679b894ef82395c15f779ec751ec7700a";
    };

    meta.autoUpdate = false;
  };

  gocapability = buildFromGitHub {
    version = 1;
    rev = "2c00daeb6c3b45114c80ac44119e7b8801fdd852";
    owner = "syndtr";
    repo = "gocapability";
    sha256 = "0kwcqvj2fq6wl453hcc3q4fmyrv3yk9m3igxwksx9rmpnzaclz8r";
    date = "2015-07-16";
  };

  gocql = buildFromGitHub {
    version = 1;
    rev = "3ac1aabebaf2705c6f695d4ef2c25ab6239e88b3";
    owner  = "gocql";
    repo   = "gocql";
    sha256 = "1d90w9x9qjz0a157zil14nix3rhdn3q5j6lg410dh8gjzrs280ws";
    propagatedBuildInputs = [
      inf_v0
      snappy
      hailocab_go-hostpool
      net
    ];
    date = "2016-08-24";
  };

  gojsonpointer = buildFromGitHub {
    version = 1;
    rev = "e0fe6f68307607d540ed8eac07a342c33fa1b54a";
    owner  = "xeipuuv";
    repo   = "gojsonpointer";
    sha256 = "1gm1m5vf1nkg87qhskpqfyg9r8n0fy74nxvp6ajcqb04v3k8sd7v";
    date = "2015-10-27";
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
    version = 1;
    rev = "4f624f6197547606054e042e7903db103585e151";
    owner  = "xeipuuv";
    repo   = "gojsonschema";
    sha256 = "1y2rfvsgh7ndbgg9zcsiz8fswz51wdszxxx5gq9pj89njx2d9kc2";
    date = "2016-08-11";
    propagatedBuildInputs = [ gojsonreference ];
  };

  gollectd = buildFromGitHub {
    version = 2;
    owner = "kimor79";
    repo = "gollectd";
    date = "2016-03-21";
    rev = "b5dddb1667dcc1e6355b9305e2c1608a2db6983c";
    sha256 = "d127cf9c35e4dbc58e92815047b772d8e6d2ac299ca15c723fa331a68e4d5e61";
  };

  gomemcache = buildFromGitHub {
    version = 1;
    rev = "fb1f79c6b65acda83063cbc69f6bba1522558bfc";
    date = "2016-01-17";
    owner = "bradfitz";
    repo = "gomemcache";
    sha256 = "0mi5f8yx2dzsh1gksmhp61vndm999d20j7aby0sgg8cfva7wryc0";
  };

  gomemcached = buildFromGitHub {
    version = 1;
    rev = "6172a8c61c821c420071fe9e20e74d8e24c8cbd5";
    date = "2016-06-22";
    owner = "couchbase";
    repo = "gomemcached";
    sha256 = "0p6n21jcqvn6fnhdbajrvqajf7y1d3kbp26zi8zpqlbwvv8h2wn6";
    propagatedBuildInputs = [
      goutils_logging
    ];
  };

  goredis = buildFromGitHub {
    version = 1;
    rev = "760763f78400635ed7b9b115511b8ed06035e908";
    date = "2015-03-24";
    owner = "siddontang";
    repo = "goredis";
    sha256 = "193n28jaj01q0k8lx2ijvgzmlh926jy6cg2ph3446k90pl5r118c";
  };

  goreq = buildFromGitHub {
    version = 1;
    rev = "fc08df6ca2d4a0d1a5ae24739aa268863943e723";
    date = "2016-05-07";
    owner = "franela";
    repo = "goreq";
    sha256 = "152fmchwwwgyg16i79vl09cyid8ry3ddhj09nzx2xrfg5632sn7s";
  };

  goutils = buildFromGitHub {
    version = 1;
    rev = "5823a0cbaaa9008406021dc5daf80125ea30bba6";
    date = "2016-03-10";
    owner = "couchbase";
    repo = "goutils";
    sha256 = "0053nk5jhn3lcwb8sg2bv39gy841ldgcl3cnvwn5mmx3658il0kn";
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

  govers = buildFromGitHub {
    version = 1;
    rev = "77fd787551fc5e7ae30696e009e334d52d2d3a43";
    date = "2016-06-23";
    owner = "rogpeppe";
    repo = "govers";
    sha256 = "07kf02gg1i1bnyl0k4rl2ylfb3pdj0gkggmcg9ivd6m1r50f8lvp";
    dontRenameImports = true;
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
    version = 1;
    rev = "552e8d4d6d9c3be95722c99da0bb41488d12714d";
    owner  = "dustinkirkland";
    repo   = "golang-petname";
    sha256 = "0bsnlign6zc5wsrmvsgs3vvsm22f5i7r07lqbhb2pxf8j2da1kzd";
    date = "2016-08-09";
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
    rev = "6ae1797c0b42b9323fc27ff7dcf568df88f2f33d";
    date = "2016-08-25";
    owner = "syndtr";
    repo = "goleveldb";
    sha256 = "057ml2rlla20g4qywbdzrh2iw7l7fqj6rsvrhhwagqxwhcmpzcb4";
    propagatedBuildInputs = [ ginkgo gomega snappy ];
  };

  gomega = buildFromGitHub {
    version = 2;
    rev = "d59fa0ac68bb5dd932ee8d24eed631cdd519efc3";
    owner  = "onsi";
    repo   = "gomega";
    sha256 = "16fl82gyicy69y1blzhn0wbp46p2dg5zlgakw66rk8xwfhshfm0j";
    propagatedBuildInputs = [
      protobuf
      yaml_v2
    ];
    date = "2016-09-10";
  };

  google-api-go-client = buildFromGitHub {
    version = 2;
    rev = "a69f0f19d246419bb931b0ac8f4f8d3f3e6d4feb";
    date = "2016-09-08";
    owner = "google";
    repo = "google-api-go-client";
    sha256 = "09kf4zw0fxrls8jr86s78lhrcvv4wqn7abficii5l7y6rchk7g20";
    goPackagePath = "google.golang.org/api";
    goPackageAliases = [
      "github.com/google/google-api-client"
    ];
    buildInputs = [
      genproto
      grpc
      net
      oauth2
    ];
  };

  gopass = buildFromGitHub {
    version = 1;
    date = "2016-08-03";
    rev = "b63a7d07e65df376d14e2d72907a93d4847dffe4";
    owner = "howeyc";
    repo = "gopass";
    sha256 = "0j2g8xy6mc0j408f2hcfq7kvqw17q835a35wnyaqfqhramp5ybnk";
    propagatedBuildInputs = [
      crypto
    ];
  };

  gopsutil = buildFromGitHub {
    version = 1;
    rev = "v2.1";
    owner  = "shirou";
    repo   = "gopsutil";
    sha256 = "1bq3fpw0jpjnkla2krf9i612v8k4kyfm0g1z7maikrnxhfiza4lc";
  };

  goquery = buildFromGitHub {
    version = 1;
    rev = "v1.0.0";
    owner  = "PuerkitoBio";
    repo   = "goquery";
    sha256 = "0qx6daxgs24rf7i7hncg7bd2s0qavlvlwr4m8074mndc78vyd4dy";
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
    version = 1;
    rev = "593d64559f7600f29581a3ee42177f5dbded27a9";
    owner = "asaskevich";
    repo = "govalidator";
    sha256 = "0qfr5ar0d8rywh23grlbg76shb8hrd3xk0ik4c5zf4z005bjpchc";
    date = "2016-07-15";
  };

  go-autorest = buildFromGitHub {
    version = 1;
    rev = "v7.1.0";
    owner  = "Azure";
    repo   = "go-autorest";
    sha256 = "1848yijgpzvzwc5h6xgkij4ngc4l1isbf36xy4z708cdljks11hl";
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
    version = 1;
    rev = "9a6736ed45b44bf3835afeebb3034b57ed329f3e";
    owner   = "elazarl";
    repo    = "go-bindata-assetfs";
    sha256 = "1hm0sbnbqaw7f847i6ynwz6b92xv6v46lpwpbql9nv8w1kp1q9y5";
    date = "2016-08-22";
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

  go-checkpoint = buildFromGitHub {
    version = 1;
    date = "2016-08-16";
    rev = "f8cfd20c53506d1eb3a55c2c43b84d009fab39bd";
    owner  = "hashicorp";
    repo   = "go-checkpoint";
    sha256 = "066rs0gbflz5jbfpvklc3vg5zs7l1fdfjrfy21y4c4j5vkm49gz5";
    buildInputs = [ go-cleanhttp ];
  };

  go-cleanhttp = buildFromGitHub {
    version = 1;
    date = "2016-04-07";
    rev = "ad28ea4487f05916463e2423a55166280e8254b5";
    owner = "hashicorp";
    repo = "go-cleanhttp";
    sha256 = "1knpnv6wg2fnnsk2h2bj4m003f7xsvwm58vnn9gc753mbr78vx00";
  };

  go-collectd = buildFromGitHub {
    version = 2;
    owner = "collectd";
    repo = "go-collectd";
    date = "2016-09-05";
    rev = "88dae2b879b6ab15e3b3874485dee775625bc6b3";
    sha256 = "bb28de1cf4fafeb1417e53f5bb79fca11233f5553e0b8b6a31a095e8d22621ce";
    goPackagePath = "collectd.org";
    buildInputs = [
      grpc
      net
      pkgs.collectd
      protobuf
    ];
    preBuild = ''
      export COLLECTD_SRC="$(pwd)/collectd-src"
      mkdir -pv "$COLLECTD_SRC"
      tar -vxjf '${pkgs.collectd.src}' -C "$COLLECTD_SRC"
      # Run configure to generate config.h
      pushd "$COLLECTD_SRC/${pkgs.collectd.name}"
        ./configure
      popd
      export CGO_CPPFLAGS="-I$COLLECTD_SRC/${pkgs.collectd.name}/src/daemon -I$COLLECTD_SRC/${pkgs.collectd.name}/src"
    '';
  };

  go-colorable = buildFromGitHub {
    version = 1;
    rev = "v0.0.6";
    owner  = "mattn";
    repo   = "go-colorable";
    sha256 = "08iwf0p0jyqcwk82vb9shqlhphhz94pdb395gpacz9r76fk5iqhq";
  };

  go-connections = buildFromGitHub {
    version = 1;
    rev = "v0.2.1";
    owner  = "docker";
    repo   = "go-connections";
    sha256 = "07rcj6rhps7jg9yywy5328zcqnxakqhbiv5vscsfjz3c021rzcgf";
    propagatedBuildInputs = [
      logrus
      net
      runc
    ];
  };

  go-couchbase = buildFromGitHub {
    version = 1;
    rev = "6575cf14363c4a840f4fafc01532b42c473472f8";
    owner  = "couchbase";
    repo   = "go-couchbase";
    sha256 = "129jdlsmsxplpnia6j7kr10algfj3p1jlakspxsjr3wgyqa4q7qi";
    date = "2016-08-08";
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
    version = 1;
    rev = "ba409f9a785a2517b7d10d9afc85cea9f665a2b3";
    owner  = "keybase";
    repo   = "go-crypto";
    sha256 = "128iv9mvv16bsmw3ybcvw29a8w2fzgkxh4sihb07fn0qs607z538";
    date = "2016-08-22";
    propagatedBuildInputs = [
      ed25519
    ];
  };

  go-difflib = buildFromGitHub {
    version = 1;
    rev = "v1.0.0";
    owner  = "pmezard";
    repo   = "go-difflib";
    sha256 = "0zb1bmnd9kn0qbyn2b62r9apbkpj3752isgbpia9i3n9ix451cdb";
  };

  go-dockerclient = buildFromGitHub {
    version = 1;
    date = "2016-08-18";
    rev = "0436d420da98515cfe6370c9c5cdde868415637b";
    owner = "fsouza";
    repo = "go-dockerclient";
    sha256 = "1qvj72grvwsnjhygi6f95nynycm555pp9n7xhvkbxakvhhwgvljf";
    propagatedBuildInputs = [
      docker_for_go-dockerclient
      go-cleanhttp
      mux
    ];
  };

  go-flags = buildFromGitHub {
    version = 1;
    date = "2016-06-26";
    rev = "f2785f5820ec967043de79c8be97edfc464ca745";
    owner  = "jessevdk";
    repo   = "go-flags";
    sha256 = "0hv9z1xny18f1pn0424gafzpn1hjkgphsvd91jnjghnx904ghrpg";
  };

  go-getter = buildFromGitHub {
    version = 1;
    rev = "a186869fff81d32bcb4e98c88c7c7d82880271ba";
    date = "2016-08-24";
    owner = "hashicorp";
    repo = "go-getter";
    sha256 = "1hl45p04nbd12g594gl3q2zjwrraimc34wy21kg6dpl0kal2n696";
    propagatedBuildInputs = [
      aws-sdk-go
    ];
  };

  go-git-ignore = buildFromGitHub {
    version = 1;
    rev = "228fcfa2a06e870a3ef238d54c45ea847f492a37";
    date = "2016-01-15";
    owner = "sabhiram";
    repo = "go-git-ignore";
    sha256 = "1a78b1as3xd2v3lawrb0y43bm3rmb452mysvzqk1309gw51lk4gx";
  };

  go-github = buildFromGitHub {
    version = 1;
    date = "2016-08-24";
    rev = "a59a35745f99ad92d70d69a9f180767063aa4bf3";
    owner = "google";
    repo = "go-github";
    sha256 = "109wiq279r2p5fdmkfsi5a29kp9pzn0yc3zgjh2k7s6fqyfy0izv";
    buildInputs = [ oauth2 ];
    propagatedBuildInputs = [ go-querystring ];
  };

  go-homedir = buildFromGitHub {
    version = 1;
    date = "2016-06-21";
    rev = "756f7b183b7ab78acdbbee5c7f392838ed459dda";
    owner  = "mitchellh";
    repo   = "go-homedir";
    sha256 = "0lacs15dkbs9ag6mdq5xg4w72g7m8p4042f7z4lrnk3r36c53zjq";
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
    version = 1;
    owner = "yosssi";
    repo = "gohtml";
    rev = "ccf383eafddde21dfe37c6191343813822b30e6b";
    date = "2015-09-23";
    sha256 = "1ccniz4r354r2y4m2dz7ic9nywzi6jffnh44dy6icyqi64v9ydw7";
    propagatedBuildInputs = [
      net
    ];
  };

  go-humanize = buildFromGitHub {
    version = 1;
    rev = "2fcb5204cdc65b4bec9fd0a87606bb0d0e3c54e8";
    owner = "dustin";
    repo = "go-humanize";
    sha256 = "1hb6b9nsyy7nclkri1f9fql2kvjqlkxhdpxcnklxb9nxxyqb1rm2";
    date = "2016-07-20";
  };

  go-immutable-radix = buildFromGitHub {
    version = 1;
    date = "2016-06-08";
    rev = "afc5a0dbb18abdf82c277a7bc01533e81fa1d6b8";
    owner = "hashicorp";
    repo = "go-immutable-radix";
    sha256 = "1yyhag8vnr7vi4ak2rkd651k9h8221dpdsqpva95zvf9nycgzlsd";
    propagatedBuildInputs = [ golang-lru ];
  };

  go-ini = buildFromGitHub {
    version = 1;
    rev = "a98ad7ee00ec53921f08832bc06ecf7fd600e6a1";
    owner = "vaughan0";
    repo = "go-ini";
    sha256 = "07i40hj47z5m6wa5bzy7sc2na3hbwh84ridl40yfybgdlyrzdkf4";
    date = "2013-09-23";
  };

  go-ipfs-api = buildFromGitHub {
    version = 1;
    rev = "v1.0.0";
    owner  = "ipfs";
    repo   = "go-ipfs-api";
    sha256 = "0c54r9g10rcnrm9rzj815gjkcgmr5z3pjgh3b4b19vbsgm2rx7hf";
    excludedPackages = "tests";
    propagatedBuildInputs = [ go-multiaddr-net go-multipart-files tar-utils ];
  };

  go-isatty = buildFromGitHub {
    version = 1;
    rev = "66b8e73f3f5cda9f96b69efd03dd3d7fc4a5cdb8";
    owner  = "mattn";
    repo   = "go-isatty";
    sha256 = "0m60qis720b5jdfklxn2qg98ndrvdbs5ykcn7qdhbycfadv1syyf";
    date = "2016-08-06";
  };

  go-jmespath = buildFromGitHub {
    version = 1;
    rev = "bd40a432e4c76585ef6b72d3fd96fb9b6dc7b68d";
    owner = "jmespath";
    repo = "go-jmespath";
    sha256 = "1jiz511xlndrai7xkpvr045x7fsda030240gcwjc4yg4y36ck8cg";
    date = "2016-08-03";
  };

  go-jose = buildFromGitHub {
    version = 1;
    rev = "v1.0.3";
    owner = "square";
    repo = "go-jose";
    sha256 = "1nldx233ir1mv9lznncxh9jybvra6wlgc4ahzl92w12h64pcii1d";
    goPackagePath = "gopkg.in/square/go-jose.v1";
    goPackageAliases = [
      "github.com/square/go-jose"
    ];
    buildInputs = [
      urfave_cli
      kingpin_v2
    ];
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
    version = 1;
    rev = "f8a6938e600c634232eeef79dc04a1226f73a88b";
    owner  = "lxc";
    repo   = "go-lxc";
    sha256 = "0cgjrafdqlbysdw4pg384qy95czn4j08brz57nqlgdv68cc5pgvk";
    goPackagePath = "gopkg.in/lxc/go-lxc.v2";
    buildInputs = [
      pkgs.lxc
    ];
    date = "2016-08-03";
  };

  go-lz4 = buildFromGitHub {
    version = 1;
    rev = "v1.0.0";
    owner  = "bkaradzic";
    repo   = "go-lz4";
    sha256 = "1bdh2wqp2hh81x00wmsb4px9fzj13jcrdl6w52pabqkr2wyyqwkf";
  };

  go-md2man = buildFromGitHub {
    version = 1;
    owner = "cpuguy83";
    repo = "go-md2man";
    rev = "v1.0.5";
    sha256 = "06kr1j092afkz609mrzbdcgl9lzw4z0ry32jfv8q2c8f4lmjk8lx";
    propagatedBuildInputs = [
      blackfriday
    ];
  };

  go-memdb = buildFromGitHub {
    version = 1;
    date = "2016-03-01";
    rev = "98f52f52d7a476958fa9da671354d270c50661a7";
    owner = "hashicorp";
    repo = "go-memdb";
    sha256 = "07938b1ln4x7caflhgsvaw8kikh5xcddwrc6zj0hcmzmbpfpyxai";
    propagatedBuildInputs = [
      go-immutable-radix
    ];
  };

  rcrowley_go-metrics = buildFromGitHub {
    version = 2;
    rev = "6c7d680e7d0a538b91f0d5ad79167446c1977f1a";
    date = "2016-09-12";
    owner = "rcrowley";
    repo = "go-metrics";
    sha256 = "1j0vn0fls06g81w2as2xy8agimhjpnaq906cg7vbjk2yp97yj2ck";
    propagatedBuildInputs = [ stathat ];
  };

  armon_go-metrics = buildFromGitHub {
    version = 1;
    date = "2016-07-16";
    rev = "3df31a1ada83e310c2e24b267c8e8b68836547b4";
    owner = "armon";
    repo = "go-metrics";
    sha256 = "01m7bb52h1x87nwnh37chq1ndf27mwmk5bpm8h4md99rfvgz82bq";
    propagatedBuildInputs = [
      circonus-gometrics
      datadog-go
      prometheus_client_golang
    ];
  };

  go-mssqldb = buildFromGitHub {
    version = 1;
    rev = "fbf0a491e5ec011522c8870da9b0553135e2f9da";
    owner = "denisenkom";
    repo = "go-mssqldb";
    sha256 = "0p0s7zggwgh5ryyc1f4r5p4g6k8iiskpmspvsr9r6r43x930jf57";
    date = "2016-08-14";
    buildInputs = [ crypto ];
  };

  go-multiaddr = buildFromGitHub {
    version = 1;
    rev = "1dd0034f7fe862dd8dc86a02602ff6f9e546f5fe";
    date = "2016-08-15";
    owner  = "jbenet";
    repo   = "go-multiaddr";
    sha256 = "0a4pppx02hsh6i2gdfl3cy4bvm0jizg2p5wpmsl9zl27qv7naipm";
    propagatedBuildInputs = [
      go-multihash
    ];
  };

  go-multiaddr-net = buildFromGitHub {
    version = 1;
    rev = "ff394cdaae087d110150f15418ea4585c23541c6";
    owner  = "jbenet";
    repo   = "go-multiaddr-net";
    sha256 = "0wygvqscyydlm4cjlpk4apy1hx3wdnayfmbny8fy8q97g8n7cnlc";
    date = "2016-06-10";
    propagatedBuildInputs = [
      go-multiaddr
      utp
    ];
  };

  go-multierror = buildFromGitHub {
    version = 1;
    date = "2016-08-10";
    rev = "8c5f0ad9360406a3807ce7de6bc73269a91a6e51";
    owner  = "hashicorp";
    repo   = "go-multierror";
    sha256 = "0sd4wxhh32nnsd6lvjbbr2qrmgp3rh3kk5ka9blhs9fvx3wa5yjc";
    propagatedBuildInputs = [ errwrap ];
  };

  go-multihash = buildFromGitHub {
    version = 1;
    rev = "5bb8e87657d874eea0af6366dc6336c4d819e7c1";
    owner  = "jbenet";
    repo   = "go-multihash";
    sha256 = "10rrb4ahb3a33p1cxq2mdx84aa1p8d3ajh9h0rlffkhbgx21md0w";
    propagatedBuildInputs = [ go-base58 crypto ];
    date = "2016-08-04";
  };

  go-multipart-files = buildFromGitHub {
    version = 1;
    rev = "3be93d9f6b618f2b8564bfb1d22f1e744eabbae2";
    owner  = "whyrusleeping";
    repo   = "go-multipart-files";
    sha256 = "0fdzi6v6rshh172hzxf8v9qq3d36nw3gc7g7d79wj88pinnqf5by";
    date = "2015-09-03";
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

  go-ole = buildFromGitHub {
    version = 1;
    rev = "v1.2.0";
    owner  = "go-ole";
    repo   = "go-ole";
    sha256 = "1bkvi5l2sshjrg1g9x1a4i337adrv1vhk8p1xrkx5z05nfwazvx0";
  };

  go-os-rename = buildFromGitHub {
    version = 1;
    rev = "3ac97f61ef67a6b87b95c1282f6c317ed0e693c2";
    owner  = "jbenet";
    repo   = "go-os-rename";
    sha256 = "0y8rq0y654lcyl7ysijni75j8fpq4hhqnh9qiy2z4hvmnzvb85id";
    date = "2015-04-28";
  };

  go-plugin = buildFromGitHub {
    version = 1;
    rev = "8cf118f7a2f0c7ef1c82f66d4f6ac77c7e27dc12";
    date = "2016-06-07";
    owner  = "hashicorp";
    repo   = "go-plugin";
    sha256 = "1mgj52aml4l2zh101ksjxllaibd5r8h1gcgcilmb8p0c3xwf7lvq";
    buildInputs = [ yamux ];
  };

  go-ps = buildFromGitHub {
    version = 1;
    rev = "e2d21980687ce16e58469d98dcee92d27fbbd7fb";
    date = "2016-08-22";
    owner  = "mitchellh";
    repo   = "go-ps";
    sha256 = "0b7rlp5ic60d4a9ibchxxb6i2lc4ish9nwwxr0p57wmlbjbq3lbf";
  };

  go-python = buildFromGitHub {
    version = 2;
    owner = "sbinet";
    repo = "go-python";
    date = "2016-08-09";
    rev = "ac4579f132fff506b2f6b3eda4c9282b4be59a08";
    sha256 = "034c9b58c1ef250eff9a46c9ac743014df110f11fa8f580033767907bfbe2750";
    nativeBuildInputs = [
      pkgs.pkgconfig
    ];
    buildInputs = [
      pkgs.python2Packages.python
    ];
  };

  go-querystring = buildFromGitHub {
    version = 1;
    date = "2016-03-10";
    rev = "9235644dd9e52eeae6fa48efd539fdc351a0af53";
    owner  = "google";
    repo   = "go-querystring";
    sha256 = "0c0rmm98vz7sk7z6a1r07dp6jyb513cyr2y753sjpnyrc28xhdwg";
  };

  go-radix = buildFromGitHub {
    version = 1;
    rev = "4239b77079c7b5d1243b7b4736304ce8ddb6f0f2";
    owner  = "armon";
    repo   = "go-radix";
    sha256 = "0b5vksrw462w1j5ipsw7fmswhpnwsnaqgp6klw714dc6ppz57aqv";
    date = "2016-01-15";
  };

  go-reap = buildFromGitHub {
    version = 1;
    rev = "2d85522212dcf5a84c6b357094f5c44710441912";
    owner  = "hashicorp";
    repo   = "go-reap";
    sha256 = "0q90nf4mgvxb26vd7avs1mw1m9cb6x9mx6jnz4xsia71ghi3lj50";
    date = "2016-01-13";
    propagatedBuildInputs = [ sys ];
  };

  go-retryablehttp = buildFromGitHub {
    version = 1;
    rev = "f4ed9b0fa01a2ac614afe7c897ed2e3d8208f3e8";
    owner = "hashicorp";
    repo = "go-retryablehttp";
    sha256 = "1sf83bmy1x43wmgbzcbg4ddskyja4azgymwqcizi5lvsrhb55c17";
    date = "2016-08-10";
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
  };

  go-runewidth = buildFromGitHub {
    version = 1;
    rev = "v0.0.1";
    owner = "mattn";
    repo = "go-runewidth";
    sha256 = "1sf0a2fbp2fp0lgizh2bjd3cgni35czvshx5clb2m6b604k7by9a";
  };

  go-simplejson = buildFromGitHub {
    version = 1;
    rev = "v0.5.0";
    owner  = "bitly";
    repo   = "go-simplejson";
    sha256 = "09svnkziaffkbax5jjnjfd0qqk9cpai2gphx4ja78vhxdn4jpiw0";
  };

  go-snappy = buildFromGitHub {
    version = 1;
    rev = "d8f7bb82a96d89c1254e5a6c967134e1433c9ee2";
    owner  = "siddontang";
    repo   = "go-snappy";
    sha256 = "18ikmwl43nqdphvni8z15jzhvqksqfbk8rspwd11zy24lmklci7b";
    date = "2014-07-04";
  };

  go-spew = buildFromGitHub {
    version = 1;
    rev = "v1.0.0";
    owner  = "davecgh";
    repo   = "go-spew";
    sha256 = "0xsyd00l10gsvj3yiks8f2dv21svi7nj9viich2l1wlqgq30vizi";
  };

  go-sqlite3 = buildFromGitHub {
    version = 1;
    rev = "b5c99a720374818b629fd1fbf6d2cbb4fb9a5644";
    date = "2016-08-21";
    owner  = "mattn";
    repo   = "go-sqlite3";
    sha256 = "1wd5ifv5k032w4gd7kzd36snl7p7di742rkm73v50l5i689w7vly";
    excludedPackages = "test";
    buildInputs = [
      goquery
    ];
  };

  go-syslog = buildFromGitHub {
    version = 1;
    date = "2016-08-13";
    rev = "315de0c1920b18b942603ffdc2229e2af4803c17";
    owner  = "hashicorp";
    repo   = "go-syslog";
    sha256 = "148lnmjaawk0g7006294x5jjp00q1c9cyqi7nmlsk8hmn8gcrnpa";
  };

  go-systemd = buildFromGitHub {
    version = 1;
    rev = "422fafb691792ca9fdf7097a5ebd49f10839676c";
    owner = "coreos";
    repo = "go-systemd";
    sha256 = "15fk2r48avk4f5yd56qn8kky9d2bjr0mf2db1cbk5gr8rzz8ar0j";
    propagatedBuildInputs = [
      dbus
      pkg
      pkgs.systemd_lib
    ];
    date = "2016-08-24";
  };

  go-systemd_journal = buildFromGitHub {
    inherit (go-systemd) rev owner repo sha256 version date;
    subPackages = [
      "journal"
    ];
  };

  go-units = buildFromGitHub {
    version = 1;
    rev = "v0.3.1";
    owner = "docker";
    repo = "go-units";
    sha256 = "16qsnzrhdnr8p650558p7ml4v0lkxhfign2jkz6nsdx6s4q2gpnc";
  };

  hashicorp-go-uuid = buildFromGitHub {
    version = 1;
    rev = "64130c7a86d732268a38cb04cfbaf0cc987fda98";
    date = "2016-07-16";
    owner  = "hashicorp";
    repo   = "go-uuid";
    sha256 = "072c84wn90di09qxrg0ml8vjfb5k10zk2n4k0rgxk1n45wyghkjx";
  };

  go-version = buildFromGitHub {
    version = 1;
    rev = "deeb027c13a95d56c7585df3fe29207208c6706e";
    owner  = "hashicorp";
    repo   = "go-version";
    sha256 = "0n2b94bj0n6rir7ymwf2lk1q6cswlaa8mrrdv7bjr1647h5vlpx8";
    date = "2016-07-25";
  };

  go-zookeeper = buildFromGitHub {
    version = 1;
    rev = "e64db453f3512cade908163702045e0f31137843";
    date = "2016-06-15";
    owner  = "samuel";
    repo   = "go-zookeeper";
    sha256 = "13rqz6v8q5gncdn5ca25n262slvs46h9grzym43z1wpwdpal4wwv";
  };

  grafana = buildFromGitHub {
    version = 1;
    owner = "grafana";
    repo = "grafana";
    rev = "v3.1.1";
    sha256 = "0lnd5226d57iir2ffff8d13fyp4h3hczl1and57fd02q3xaqdybj";
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

  groupcache = buildFromGitHub {
    version = 1;
    date = "2016-08-03";
    rev = "a6b377e3400b08991b80d6805d627f347f983866";
    owner  = "golang";
    repo   = "groupcache";
    sha256 = "08i7y7glb6j8bd7f1y940qaagry2mwfyqm9y6w2ki7awadl87zrs";
    buildInputs = [ protobuf ];
  };

  grpc = buildFromGitHub {
    version = 2;
    rev = "3e1c91c1e0a72a34f68542bc029792b031835cbf";
    owner = "grpc";
    repo = "grpc-go";
    sha256 = "0zm4jf04gqdf4m97y0h3gz1fn0smmabfn6b3nhkhifazyfpwgzcf";
    goPackagePath = "google.golang.org/grpc";
    goPackageAliases = [ "github.com/grpc/grpc-go" ];
    propagatedBuildInputs = [ http2 net protobuf oauth2 glog ];
    excludedPackages = "\\(test\\|benchmark\\)";
    meta.useUnstable = true;
    date = "2016-09-12";
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
    version = 1;
    rev = "v0.9.0";
    owner = "whyrusleeping";
    repo = "gx";
    sha256 = "1zk1lkx01vhy2cl0l46hfjzc4rp3f2fn3vf8s926a73q6jma44fh";
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
    rev = "v1.3.0";
    owner = "whyrusleeping";
    repo = "gx-go";
    sha256 = "117l1nlkv6il587bxjh774jzjqrzwfw6mjlj8w3bvp5gx0zxb8c3";
    buildInputs = [
      urfave_cli
      fs
      gx
      stump
    ];
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
    version = 1;
    date = "2016-08-01";
    rev = "44afc598a09bef47978b905b2caab42ac0edb304";
    owner = "NYTimes";
    repo = "gziphandler";
    sha256 = "0141xh0s9yqwx4ypgxzgz643vwwq4xyxs31h3dnq9g3ncqi6hwdm";
  };

  hashstructure = buildFromGitHub {
    version = 1;
    date = "2016-06-09";
    rev = "b098c52ef6beab8cd82bc4a32422cf54b890e8fa";
    owner  = "mitchellh";
    repo   = "hashstructure";
    sha256 = "0zg0q20hzg92xxsfsf2vn1kq044j8l7dh82fm7w7iyv03nwq0cxc";
  };

  hcl = buildFromGitHub {
    version = 1;
    date = "2016-08-22";
    rev = "baeb59c710717b06aac1dbe2270e8192ec593244";
    owner  = "hashicorp";
    repo   = "hcl";
    sha256 = "1p39d3qzmmiq1d52srz5ivb11lxw43friaswafx3vs4babck20ds";
  };

  hil = buildFromGitHub {
    version = 1;
    date = "2016-04-08";
    rev = "6215360e5247e7c4bdc317a5f95e3fa5f084a33";
    owner  = "hashicorp";
    repo   = "hil";
    sha256 = "6b3ab530f6980279edb5a1994226adefc377b70aa3e993b5d29c7d498d5cdbd4";
    propagatedBuildInputs = [
      mapstructure
      reflectwalk
    ];
    meta.autoUpdate = false;
  };

  hllpp = buildFromGitHub {
    version = 2;
    owner = "retailnext";
    repo = "hllpp";
    date = "2015-03-19";
    rev = "38a7bb71b483e855d35010808143beaf05b67f9d";
    sha256 = "3a98569b08ed14b834fb91c7da0827c74ddec9d1c057356c9d9999440bd45157";
  };

  http2 = buildFromGitHub {
    version = 1;
    rev = "aa7658c0e9902e929a9ed0996ef949e59fc0f3ab";
    owner = "bradfitz";
    repo = "http2";
    sha256 = "10x76xl5b6z2w0mbq7lnx7sl3cbdsp6gc1n3bis9lc0ilclzml65";
    buildInputs = [
      crypto
    ];
    date = "2016-01-16";
  };

  httprouter = buildFromGitHub {
    version = 1;
    rev = "d8ff598a019f2c7bad0980917a588193cf26666e";
    owner  = "julienschmidt";
    repo   = "httprouter";
    sha256 = "0yg94qbiiynpny7l7xpy8zpk65bjzpqfa253yzsqps59cxp1jg4m";
    date = "2016-08-10";
  };

  hugo = buildFromGitHub {
    version = 1;
    owner = "spf13";
    repo = "hugo";
    rev = "v0.16";
    sha256 = "1jf8mwpzggridb3dip0dd1hzbzn0kkajfi5jy9vh3naakxzk11w7";
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
      inflect
      jwalterweatherman
      mapstructure
      mmark
      nitro
      osext
      pflag
      purell
      text
      toml
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
    version = 1;
    owner = "influxdata";
    repo = "influxdb";
    rev = "v0.13.0";
    sha256 = "0jws9s6p5mwira09sn1di37yc3kxfhfyck785ji46v04ysw01s8w";
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
    version = 1;
    rev = "v1.21.0";
    owner  = "go-ini";
    repo   = "ini";
    sha256 = "0nv0gf1y9zf34lx2zn0pl8nqhn6snby84f4g5xd72mnyrm5p4ajk";
  };

  ini_v1 = buildFromGitHub {
    version = 1;
    rev = "v1.21.0";
    owner  = "go-ini";
    repo   = "ini";
    goPackagePath = "gopkg.in/ini.v1";
    sha256 = "1pwzhfwwkdpxy17jkhzljcbk70w8j0l28agi1xz8ps4isph3nrfr";
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
    date = "2016-09-04";
    rev = "0f0cf44800efcd4ae449922ba4e3c45d1c5db121";
    owner = "ipfs";
    repo = "go-ipfs";
    sha256 = "26b7f9a98bd6b916f6dba1dccbf0e8984c80309d9a7187e490ab8889a59efa68";
    gxSha256 = "160v2jl15skbvvhd2cva59j7v2aj1l16gd94f0h46wbh9pr710wg";

    subPackages = [
      "cmd/ipfs"
      "cmd/ipfswatch"
    ];
  };

  json-filter = buildFromGitHub {
    version = 1;
    owner = "whyrusleeping";
    repo = "json-filter";
    rev = "ff25329a9528f01c5175414f16cc0a6a162a5b8b";
    date = "2016-06-15";
    sha256 = "0y1d6yi09ac0xlf63qrzxsi7dqf10wha3na633qzqjnpjcga97ck";
  };

  jwalterweatherman = buildFromGitHub {
    version = 1;
    owner = "spf13";
    repo = "jWalterWeatherman";
    rev = "33c24e77fb80341fe7130ee7c594256ff08ccc46";
    date = "2016-03-01";
    sha256 = "0w6risn5iwx9b0sn0f6z2yfs3p1gqa22asy3hkix1p81a1xmsidc";
    goPackageAliases = [
      "github.com/spf13/jwalterweatherman"
    ];
  };

  jwt-go = buildFromGitHub {
    version = 1;
    owner = "dgrijalva";
    repo = "jwt-go";
    rev = "v3.0.0";
    sha256 = "0gmxycray168ppybd3g9ic9dvkvlnl1y7rn00gcycsv23phszprz";
  };

  kingpin_v2 = buildFromGitHub {
    version = 1;
    rev = "v2.2.2";
    owner = "alecthomas";
    repo = "kingpin";
    sha256 = "1pbj4mrpq0kmizpq6jjjyjnqnp1xmvfg1yxh9mfbdfx6np6lbwh3";
    goPackagePath = "gopkg.in/alecthomas/kingpin.v2";
    propagatedBuildInputs = [
      template
      units
    ];
  };

  ldap = buildFromGitHub {
    version = 1;
    rev = "v2.4.1";
    owner  = "go-ldap";
    repo   = "ldap";
    sha256 = "1vgjhz2rhyfyvpmp7mgya3znivdi8z5s156nj99329yif1q6dg7j";
    goPackageAliases = [
      "github.com/nmcclain/ldap"
      "github.com/vanackere/ldap"
    ];
    propagatedBuildInputs = [ asn1-ber ];
  };

  ledisdb = buildFromGitHub {
    version = 1;
    rev = "2f7cbc730a2e48ba2bc30ec69da86503fc40acc7";
    owner  = "siddontang";
    repo   = "ledisdb";
    sha256 = "0lp895xlbldw8g2bx8rr3sx7mmd8h35mikm0xpm1r8nz8w6qhz9d";
    date = "2016-07-25";
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
    version = 1;
    rev = "v0.3.1";
    owner = "xenolf";
    repo = "lego";
    sha256 = "12bry70rgdi0i9dybhaq1vfa83ac5cdka86652xry1j7a8gq0z76";

    buildInputs = [
      aws-sdk-go
      urfave_cli
      crypto
      dns
      weppos-dnsimple-go
      go-ini
      go-jose
      goamz
      google-api-go-client
      oauth2
      net
      vultr
    ];

    subPackages = [
      "."
    ];
  };

  liner = buildFromGitHub {
    version = 1;
    rev = "8975875355a81d612fafb9f5a6037bdcc2d9b073";
    owner = "peterh";
    repo = "liner";
    sha256 = "0j64wqzv0srlz0l0w6axhdsafna3yp1vqym5k7k2sai510l9wqx9";
    date = "2016-06-15";
  };

  lldb = buildFromGitHub {
    version = 2;
    rev = "v1.0.5";
    owner  = "cznic";
    repo   = "lldb";
    sha256 = "167s53xghxy7xlxbpf4r48h7rz6yygaq4fqk1h5m5hhivh6vazsq";
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
  };

  log15 = buildFromGitHub {
    version = 1;
    rev = "f1f14b426c23e20a73468078b52d0713a16a132a";
    owner  = "inconshreveable";
    repo   = "log15";
    sha256 = "042icbwjrvnm7rn8i4hjkplgaxbwv9kj488b1zynl7s26fd3b57g";
    propagatedBuildInputs = [
      go-colorable
      stack
    ];
    date = "2016-08-10";
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

  log = buildFromGitHub {
    version = 1;
    rev = "db601cfd560df77dc022766a622be6cdc28da3bf";
    owner = "lunny";
    repo = "log";
    sha256 = "1yvilvdijy9pzld0gyw8rzw5ys5i27hf1av00dpgssll3j6l4498";
    date = "2015-11-24";
  };

  logrus = buildFromGitHub {
    version = 1;
    rev = "v0.10.0";
    owner = "Sirupsen";
    repo = "logrus";
    sha256 = "1rf70m0r0x3rws8334rmhj8wik05qzxqch97c31qpfgcl96ibnfb";
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
    version = 1;
    date = "2016-04-16";
    rev = "7d364cab682d1b7b9063a3293c9e8c3087194940";
    owner  = "mgutz";
    repo   = "logxi";
    sha256 = "0vpwd2xhbgv7cs7myw39wlb85bm5csasq3890l5ba3ryhlkjcs4m";
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
    version = 1;
    rev = "lxd-2.0.4";
    owner  = "lxc";
    repo   = "lxd";
    sha256 = "13gds9klk6rmvc9858kcblkp78v4dmnm3w0q0860p6skisq90mpg";
    excludedPackages = "test"; # Don't build the binary called test which causes conflicts
    buildInputs = [
      crypto
      gettext
      gocapability
      golang-petname
      go-lxc_v2
      go-sqlite3
      go-systemd
      log15_v2
      pkgs.lxc
      mux
      pborman_uuid
      pongo2-v3
      protobuf
      tablewriter
      tomb_v2
    _yaml_v2
      websocket
    ];
  };

  macaron_v1 = buildFromGitHub {
    version = 1;
    rev = "v1.1.7";
    owner  = "go-macaron";
    repo   = "macaron";
    sha256 = "1wrlmhzx5lqqf9i547phfyhlspav552zzwrpglq0i05pjppmjjd3";
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

  mapstructure = buildFromGitHub {
    version = 1;
    date = "2016-08-08";
    rev = "ca63d7c062ee3c9f34db231e352b60012b4fd0c1";
    owner  = "mitchellh";
    repo   = "mapstructure";
    sha256 = "1f97xd835qnyy1wb2aj2zw66c2l1kaq44n3511avm8alhaicqky9";
  };

  mathutil = buildFromGitHub {
    version = 1;
    date = "2016-06-13";
    rev = "78ad7f262603437f0ecfebc835d80094f89c8f54";
    owner = "cznic";
    repo = "mathutil";
    sha256 = "1m3nfvymw912bii4cim0vwcgs1k0fmbmcms6h38aqxh0gkxgd8mq";
    buildInputs = [ bigfft ];
  };

  maxminddb-golang = buildFromGitHub {
    version = 2;
    date = "2016-09-10";
    rev = "e528c2f39cc9d9065d7806e82ccadb7e2cd10395";
    owner  = "oschwald";
    repo   = "maxminddb-golang";
    sha256 = "13v8r6p81z52csgaih99x4zvyqrb0qbfzp0n5apavyccns8armj9";
    propagatedBuildInputs = [
      sys
    ];
  };

  mdns = buildFromGitHub {
    version = 1;
    date = "2015-12-05";
    rev = "9d85cf22f9f8d53cb5c81c1b2749f438b2ee333f";
    owner = "hashicorp";
    repo = "mdns";
    sha256 = "0hsbhh0v0jpm4cg3hg2ffi2phis4vq95vyja81rk7kzvml17pvag";
    propagatedBuildInputs = [ net dns ];
  };

  memberlist = buildFromGitHub {
    version = 1;
    date = "2016-08-12";
    rev = "0c5ba075f8520c65572f001331a1a43b756e01d7";
    owner = "hashicorp";
    repo = "memberlist";
    sha256 = "0v03pwcx5sjs238zyfbgf6way0wj3nvniq2hvbc36aybxmby4qqa";
    propagatedBuildInputs = [
      dns
      ugorji_go
      armon_go-metrics
      go-multierror
    ];
  };

  mgo_v2 = buildFromGitHub {
    version = 1;
    rev = "r2016.08.01";
    owner = "go-mgo";
    repo = "mgo";
    sha256 = "0hq8wfypghfcz83035wdb844b39pd1qly43zrv95i99p35fwmx22";
    goPackagePath = "gopkg.in/mgo.v2";
    excludedPackages = "dbtest";
    buildInputs = [
      pkgs.cyrus-sasl
    ];
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
    version = 1;
    owner = "edsrzf";
    repo = "mmap-go";
    rev = "935e0e8a636ca4ba70b713f3e38a19e1b77739e8";
    sha256 = "1a9s99gwziamlw2yn7i86wh675ag2bqbp5aa13vf8kl2rfc2p6ma";
    date = "2016-05-12";
  };

  mmark = buildFromGitHub {
    version = 1;
    owner = "miekg";
    repo = "mmark";
    rev = "v1.3.4";
    sha256 = "0mpnn6894j6cwvxq29vh3k06jg46swy58ff60i9vjqn942cklkvv";
    buildInputs = [
      toml
    ];
  };

  mongo-tools = buildFromGitHub {
    version = 1;
    rev = "r3.3.11";
    owner  = "mongodb";
    repo   = "mongo-tools";
    sha256 = "05zpfrgxrc5szc92qm2ql0xs24hah70i3axz4rbhg2xczgr3b2wb";
    buildInputs = [
      crypto
      go-flags
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

  mow-cli = buildFromGitHub {
    version = 1;
    rev = "0de8a769b5ad3ab01a480561cfbd4b220240311f";
    owner  = "jawher";
    repo   = "mow.cli";
    sha256 = "00db6mpm1jdsnqg05dv4w5a8va5w11ms9z2wlkjnmsnr44zhlykq";
    date = "2016-07-20";
  };

  mux = buildFromGitHub {
    version = 1;
    rev = "v1.1";
    owner = "gorilla";
    repo = "mux";
    sha256 = "1iicj9v3ippji2i1jf2g0jmrvql1k2yydybim3hsb0jashnq7794";
    propagatedBuildInputs = [
      context
    ];
  };

  muxado = buildFromGitHub {
    version = 1;
    date = "2014-03-12";
    rev = "f693c7e88ba316d1a0ae3e205e22a01aa3ec2848";
    owner  = "inconshreveable";
    repo   = "muxado";
    sha256 = "db9a65b811003bcb48d1acefe049bb12c8de232537cf07e1a4a949a901d807a2";
    meta.autoUpdate = false;
  };

  mysql = buildFromGitHub {
    version = 1;
    rev = "0b58b37b664c21f3010e836f1b931e1d0b0b0685";
    owner  = "go-sql-driver";
    repo   = "mysql";
    sha256 = "0nw4y8smwvvjgrnnj3sw9yl4bf7ll1hqw7xw5c0kzq6pkfzfdqsd";
    date = "2016-08-02";
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
    version = 1;
    rev = "d710fbade461cd8e75f8d263df73cc2c9dfbe168";
    owner  = "vishvananda";
    repo   = "netlink";
    sha256 = "1fs77lnvzxflh9652c5lbkfkm3kwzmgmi8na3h7hx55zqz9fwmrg";
    date = "2016-08-23";
    propagatedBuildInputs = [
      netns
    ];
  };

  netns = buildFromGitHub {
    version = 1;
    rev = "8ba1072b58e0c2a240eb5f6120165c7776c3e7b8";
    owner  = "vishvananda";
    repo   = "netns";
    sha256 = "05r4qri45ngm40kp9qdbyqrs15gx7swjj27bmc7i04wg9yd65j95";
    date = "2016-04-30";
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
      log
      go-snappy
      toml
    ];
  };

  nomad = buildFromGitHub {
    version = 1;
    rev = "v0.4.1";
    owner = "hashicorp";
    repo = "nomad";
    sha256 = "1s74493y1qxvnxmg46dxbl4lx09g6zsjr96nk040kyj1n0czgxrb";

    buildInputs = [
      gziphandler
      circbuf
      armon_go-metrics
      go-spew
      go-humanize
      go-dockerclient
      cronexpr
      consul_api
      go-checkpoint
      go-cleanhttp
      go-getter
      go-memdb
      ugorji_go
      go-multierror
      go-syslog
      go-version
      hcl
      logutils
      memberlist
      net-rpc-msgpackrpc
      raft
      raft-boltdb
      scada-client
      serf
      yamux
      osext
      mitchellh_cli
      colorstring
      copystructure
      go-ps
      hashstructure
      mapstructure
      runc
      columnize
      gopsutil
      sys
      go-plugin
      tail
    ];

    subPackages = [
      "."
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

  openssl = buildFromGitHub {
    version = 1;
    date = "2016-07-27";
    rev = "688903e99b30b3f3a54c03f069085a246bf300b1";
    owner = "10gen";
    repo = "openssl";
    sha256 = "0nxc8nrvrzlc367b5g2n43ndxjrncr40dllpsdwsinb655cis4iw";
    goPackageAliases = [ "github.com/spacemonkeygo/openssl" ];
    nativeBuildInputs = [ pkgs.pkgconfig ];
    buildInputs = [ pkgs.openssl ];
    propagatedBuildInputs = [ spacelog ];

    preBuild = ''
      find go/src/$goPackagePath -name \*.go | xargs sed -i 's,spacemonkeygo/openssl,10gen/openssl,g'
    '';
  };

  osext = buildFromGitHub {
    version = 1;
    date = "2016-08-10";
    rev = "c2c54e542fb797ad986b31721e1baedf214ca413";
    owner = "kardianos";
    repo = "osext";
    sha256 = "0y2fl7f2n7bwfs6vykb8p9qpx8xyp3rl7bb9ax9fhrzgkl112530";
    goPackageAliases = [
      "github.com/bugsnag/osext"
      "bitbucket.org/kardianos/osext"
    ];
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
    date = "2016-09-05";
    rev = "ad4efe000aa550bb54918c06ebbadc0ff17687b9";
    sha256 = "9c47c25cd544f48064e148ea428f95930505fd2f74e3a2e606aff1adfe92db42";
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
    version = 1;
    owner = "sethgrid";
    repo = "pester";
    rev = "8053687f99650573b28fb75cddf3f295082704d7";
    date = "2016-04-29";
    sha256 = "1ln7g9hnwr34h3qpxxlxilq7kwghhi92fvrcg5cgvw6s92hai91n";
  };

  pflag = buildFromGitHub {
    version = 1;
    owner = "spf13";
    repo = "pflag";
    rev = "367864438f1b1a3c7db4da06a2f55b144e6784e0";
    date = "2016-06-10";
    sha256 = "18g0sv7wzl6j1p1j055hlaacz54lp57063d4gy8pbi70phys1qfy";
  };

  pkcs7 = buildFromGitHub {
    version = 1;
    owner = "fullsailor";
    repo = "pkcs7";
    rev = "3befe47e6c80b97ab6863a5fe1b6a611003a5ab0";
    date = "2016-07-24";
    sha256 = "1x8ldsn1kgrca5d5pjipa3nxv40dyxc70qbr8y0x4s7axm4nc0kb";
  };

  pkg = buildFromGitHub {
    version = 1;
    date = "2016-07-27";
    owner  = "coreos";
    repo   = "pkg";
    rev = "3ac0863d7acf3bc44daf49afef8919af12f704ef";
    sha256 = "0j3wd6an5dcrih5qrma502nfk4xa5bm0db04zkqbxchgx5d2wl0w";
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

  pool_v2 = buildFromGitHub {
    version = 2;
    owner = "fatih";
    repo = "pool";
    date = "2016-07-21";
    rev = "20a0a429c5f93de45c90f5f09ea297c25e0929b3";
    sha256 = "2dad7d86c3724e9f90e373ead150d0f1f6b02bbfb98a2347e801db5ea1c67d07";
    goPackagePath = "gopkg.in/fatih/pool.v2";
  };

  pq = buildFromGitHub {
    version = 2;
    rev = "50761b0867bd1d9d069276790bcd4a3bccf2324a";
    owner  = "lib";
    repo   = "pq";
    sha256 = "143sd61qzzmnb16n33z89zgva1z2cznavlhzx38w1prckhf9j644";
    date = "2016-08-31";
  };

  prometheus = buildFromGitHub {
    version = 1;
    rev = "v1.0.1";
    owner  = "prometheus";
    repo   = "prometheus";
    sha256 = "1z4lmxahqjnv88i82kwn8rbylhwn5va6j33jfai0ahflqm9gyvlb";
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
      influxdb_client
      logrus
      net
      prometheus_common
      yaml_v2
    ];
  };

  prometheus_client_golang = buildFromGitHub {
    version = 1;
    rev = "v0.8.0";
    owner = "prometheus";
    repo = "client_golang";
    sha256 = "1n92bwbhymz88n3zm4cnv6xhj80g5r8dp720bwpb0ckwaxnzsbag";
    propagatedBuildInputs = [
      goautoneg
      net
      protobuf
      prometheus_client_model
      prometheus_common_for_client
      prometheus_procfs
      beorn7_perks
    ];
  };

  prometheus_client_model = buildFromGitHub {
    version = 1;
    rev = "fa8ad6fec33561be4280a8f0514318c79d7f6cb6";
    date = "2015-02-12";
    owner  = "prometheus";
    repo   = "client_model";
    sha256 = "150fqwv7lnnx2wr8v9zmgaf4hyx1lzd4i1677ypf6x5g2fy5hh6r";
    buildInputs = [
      protobuf
    ];
  };

  prometheus_common = buildFromGitHub {
    version = 1;
    date = "2016-08-01";
    rev = "ebdfc6da46522d58825777cf1f90490a5b1ef1d8";
    owner = "prometheus";
    repo = "common";
    sha256 = "0bjz1myx9j58w5985zkd4qwzhr1jp24lpsx9kjxbqhrb4bm18vki";
    buildInputs = [
      logrus
      net
      prometheus_client_model
      protobuf
    ];
    propagatedBuildInputs = [
      golang_protobuf_extensions
      httprouter
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

  prometheus_procfs = buildFromGitHub {
    version = 1;
    rev = "abf152e5f3e97f2fafac028d2cc06c1feb87ffa5";
    date = "2016-04-11";
    owner  = "prometheus";
    repo   = "procfs";
    sha256 = "08536i8yaip8lv4zas4xa59igs4ybvnb2wrmil8rzk3a2hl9zck8";
  };

  properties = buildFromGitHub {
    version = 1;
    owner = "magiconair";
    repo = "properties";
    rev = "v1.7.0";
    sha256 = "00s9b7fmzhg3j55hs48s3pvzslfj54k1h9vicj782gg79pgid785";
  };

  protobuf_gogo = buildFromGitHub {
    version = 1;
    owner = "gogo";
    repo = "protobuf";
    rev = "v0.3";
    sha256 = "1qxlyjw7hi06byzxp3xa5sdvg5dmbq9cc6558xm8acr9xjizf78y";
    excludedPackages = "test";
  };

  purell = buildFromGitHub {
    version = 1;
    owner = "PuerkitoBio";
    repo = "purell";
    rev = "1d5d1cfad45d42ec5f81fa8ef23de09cebc6dcc3";
    date = "2016-06-07";
    sha256 = "0f6x59470ck9rzjf0lfcnbzadk8awv8dpdindryplm2my7z6d74w";
    propagatedBuildInputs = [
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
    version = 1;
    rev = "v1.0.6";
    owner  = "cznic";
    repo   = "ql";
    sha256 = "1cw4ilgjkx74pshrf6fzngyy1jj98y3051b6mkq4s7ksmr8s9xpy";
    propagatedBuildInputs = [
      go4
      b
      exp
      lldb
      strutil
    ];
  };

  rabbit-hole = buildFromGitHub {
    version = 1;
    rev = "88550829bcdcf614361c73459c903578eb44074e";
    owner  = "michaelklishin";
    repo   = "rabbit-hole";
    sha256 = "1g6yz793g97mqnm07dsfvbkzl3va81hv5fhlx550rpsdciprc2zb";
    date = "2016-07-06";
  };

  raft = buildFromGitHub {
    version = 1;
    date = "2016-08-23";
    rev = "5f09c4ffdbcd2a53768e78c47717415de12b6728";
    owner  = "hashicorp";
    repo   = "raft";
    sha256 = "156fwcm9j7h9kxvbfxpzxbhbcygczg0w58avm1khb6vfgz6awgzd";
    propagatedBuildInputs = [ armon_go-metrics ugorji_go ];
  };

  raft-boltdb = buildFromGitHub {
    version = 1;
    date = "2015-02-01";
    rev = "d1e82c1ec3f15ee991f7cc7ffd5b67ff6f5bbaee";
    owner  = "hashicorp";
    repo   = "raft-boltdb";
    sha256 = "07g818sprpnl0z15wl16wj9dvyl9igqaqa0w4y7mbfblnpydvgis";
    propagatedBuildInputs = [ bolt ugorji_go raft ];
  };

  ratelimit = buildFromGitHub {
    version = 1;
    rev = "77ed1c8a01217656d2080ad51981f6e99adaa177";
    date = "2015-11-25";
    owner  = "juju";
    repo   = "ratelimit";
    sha256 = "0m7bvg8kg9ffl624lbcq47207n6r54z9by1wy0axslishgp1lh98";
  };

  raw = buildFromGitHub {
    version = 1;
    rev = "724aedf6e1a5d8971aafec384b6bde3d5608fba4";
    owner  = "feyeleanor";
    repo   = "raw";
    sha256 = "0pkvvvln5cyyy0y2i82jv39gjnfgzpb5ih94iav404lfsachh8m1";
    date = "2013-03-27";
  };

  cupcake_rdb = buildFromGitHub {
    version = 1;
    date = "2016-02-09";
    rev = "90399abcaaff31d7844fbae7f9acb27109946f7f";
    owner = "cupcake";
    repo = "rdb";
    sha256 = "06828vbgyihcwcj0sqm5dlk3j84xwfj76kh379mhai5qxn88nk0c";
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

  reflectwalk = buildFromGitHub {
    version = 1;
    date = "2015-05-27";
    rev = "eecf4c70c626c7cfbb95c90195bc34d386c74ac6";
    owner  = "mitchellh";
    repo   = "reflectwalk";
    sha256 = "0zpapfp4vx9zr3zlw2405clgix7jzhhdphmsyhar4yhhs04fb3qz";
  };

  roaring = buildFromGitHub {
    version = 2;
    rev = "v0.2.7";
    owner  = "RoaringBitmap";
    repo   = "roaring";
    sha256 = "03h1r15yswfzpr1f43wjlmj6q8lvjl42kfhyyd4i80hwvbrgnay0";
  };

  runc = buildFromGitHub {
    version = 1;
    rev = "v1.0.0-rc1";
    owner = "opencontainers";
    repo = "runc";
    sha256 = "75b869ab4d184c870de0c203d5466d846c279652ba412f35af7ddeca6835ff5c";
    propagatedBuildInputs = [
      go-units
      logrus
      docker_for_runc
      go-systemd
      protobuf
      gocapability
      netlink
      urfave_cli
      runtime-spec
    ];
    meta.autoUpdate = false;
  };

  runtime-spec = buildFromGitHub {
    version = 1;
    rev = "v1.0.0-rc1";
    owner = "opencontainers";
    repo = "runtime-spec";
    sha256 = "1c112fe3b731835f244a6d7030de25e371ba4f783cdff0ae53e471908a117162";
    buildInputs = [
      gojsonschema
    ];
    meta.autoUpdate = false;
  };

  sanitized-anchor-name = buildFromGitHub {
    version = 1;
    owner = "shurcooL";
    repo = "sanitized_anchor_name";
    rev = "10ef21a441db47d8b13ebcc5fd2310f636973c77";
    date = "2015-10-27";
    sha256 = "0pmkdx914ir0a1inrjaa68r1c27cga1dr8gwx333c8vffiy08kkw";
  };

  scada-client = buildFromGitHub {
    version = 1;
    date = "2016-06-01";
    rev = "6e896784f66f82cdc6f17e00052db91699dc277d";
    owner  = "hashicorp";
    repo   = "scada-client";
    sha256 = "1by4kyd2hrrrghwj7snh9p8fdlqka24q9yr6nyja2acs2zpjgh7a";
    buildInputs = [ armon_go-metrics net-rpc-msgpackrpc yamux ];
  };

  semver = buildFromGitHub {
    version = 1;
    rev = "v3.3.0";
    owner = "blang";
    repo = "semver";
    sha256 = "0vz3bzkclpgy7n55z6vx3yxzl0mgxbcwfa262kyi2bnvfgz1r10r";
  };

  serf = buildFromGitHub {
    version = 1;
    rev = "9432bc08aa8d486e497e27f84878ebbe8c1eab66";
    owner  = "hashicorp";
    repo   = "serf";
    sha256 = "1s5kmwzp84cj1sqd6v5h5xc2b21zv7bplvgi3c3kyasjbf3l0031";

    buildInputs = [
      net circbuf armon_go-metrics ugorji_go go-syslog logutils mdns memberlist
      dns mitchellh_cli mapstructure columnize
    ];
    date = "2016-08-16";
  };

  session = buildFromGitHub {
    version = 1;
    rev = "66031fcb37a0fff002a1f028eb0b3a815c78306b";
    owner  = "go-macaron";
    repo   = "session";
    sha256 = "1402h3a6wgjx71h8bi87k5p9inypybyp2wjcz2b9ldiczmajxfwy";
    date = "2015-10-13";
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
    version = 1;
    owner = "pkg";
    repo = "sftp";
    rev = "57fcf4a640a942eb05181f929601f8f4409eda3e";
    date = "2016-06-22";
    sha256 = "19xf7xk5y2r21g5rddrvwlrlrn5bdsm6hd5cnwpqnlwk9faklh2a";
    propagatedBuildInputs = [
      crypto
      errors
      fs
    ];
  };

  slices = buildFromGitHub {
    version = 1;
    rev = "bb44bb2e4817fe71ba7082d351fd582e7d40e3ea";
    owner  = "feyeleanor";
    repo   = "slices";
    sha256 = "05i934pmfwjiany6r9jgp27nc7bvm6nmhflpsspf10d4q0y9x8zc";
    date = "2013-02-25";
    propagatedBuildInputs = [
      raw
    ];
  };

  slug = buildFromGitHub {
    version = 1;
    rev = "v1.0.2";
    owner  = "gosimple";
    repo   = "slug";
    sha256 = "078zkcw98dp51mcrcl8gz341j1pgrmhkl10p3yqd8wxh6s492sfb";
    propagatedBuildInputs = [
      com
      macaron_v1
      unidecode
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
    version = 1;
    date = "2016-06-06";
    rev = "f936fb050dc6b5fe4a96b485a6f069e8bdc59aeb";
    owner = "spacemonkeygo";
    repo = "spacelog";
    sha256 = "008npp1bdza55wqyv157xd1512xbpar6hmqhhs3bi5xh7xlwpswj";
    buildInputs = [ flagfile ];
  };

  speakeasy = buildFromGitHub {
    version = 1;
    date = "2016-08-13";
    rev = "a1ccbf2c40dfc8ce514b5c5c6e6d1429ea6880da";
    owner = "bgentry";
    repo = "speakeasy";
    sha256 = "0z1z581rzgiddam3kvinjw34flzpwpcz3axakyq5iv9mqjxaddny";
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

  structs = buildFromGitHub {
    version = 1;
    date = "2016-08-07";
    rev = "dc3312cb1a4513a366c4c9e622ad55c32df12ed3";
    owner  = "fatih";
    repo   = "structs";
    sha256 = "0qlxfpa0nqwvik6h965hrbhpvar3zd84jhfxrpa6b9r2wbaxcz6s";
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
    version = 1;
    date = "2015-04-30";
    rev = "1eb03e3cc9d345307a45ec82bd3016cde4bd4464";
    owner = "cznic";
    repo = "strutil";
    sha256 = "0ipn9zaihxpzs965v3s8c9gm4rc4ckkihhjppchr3hqn2vxwgfj1";
  };

  suture = buildFromGitHub {
    version = 1;
    rev = "v2.0.0";
    owner  = "thejerf";
    repo   = "suture";
    sha256 = "0w7v4dp9pjndrrbqkpsl8xlnjs5gv8398gyyvhlb8x5h39v217vp";
  };

  swift = buildFromGitHub {
    version = 1;
    rev = "b964f2ca856aac39885e258ad25aec08d5f64ee6";
    owner  = "ncw";
    repo   = "swift";
    sha256 = "1dxhb26pa8j0rzn3w5jdfs56dzf2qv6k28jf5kn4d403y2rvfv99";
    date = "2016-06-17";
  };

  sync = buildFromGitHub {
    version = 1;
    rev = "812602587b72df6a2a4f6e30536adc75394a374b";
    owner  = "anacrolix";
    repo   = "sync";
    sha256 = "10rk5fkchbmfzihyyxxcl7bsg6z0kybbjnn1f2jk40w18vgqk50r";
    date = "2015-10-30";
    buildInputs = [
      missinggo
    ];
  };

  syncthing = buildFromGitHub rec {
    version = 2;
    rev = "v0.14.6";
    owner = "syncthing";
    repo = "syncthing";
    sha256 = "0nba0ddkc7zdqaw5gyhy1s0bdvd3ghsfvxc732v1m144w074z8yq";
    buildFlags = [ "-tags noupgrade" ];
    buildInputs = [
      go-lz4 du luhn xdr snappy ratelimit osext
      goleveldb suture qart crypto net text rcrowley_go-metrics
      go-nat-pmp glob gateway ql groupcache pq protobuf_gogo
      geoip2-golang
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
    version = 1;
    rev = "daf2955e742cf123959884fdff4685aa79b63135";
    date = "2016-06-21";
    owner  = "olekukonko";
    repo   = "tablewriter";
    sha256 = "096014asbb9d27wyyrg81n922icf7p0r0wr2cipg6ymqrfa2d32f";
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
      missinggo_lib
      xstrings
    ];
    meta.autoUpdate = false;
  };

  tail = buildFromGitHub {
    version = 1;
    rev = "v1.0.0";
    owner  = "hpcloud";
    repo   = "tail";
    sha256 = "1a1k0hzyn4519b659hkxfjlzm4mf5ffhzzhifhkcc231zlxy4l5r";
    propagatedBuildInputs = [
      fsnotify_v1
      tomb_v1
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

  template = buildFromGitHub {
    version = 1;
    rev = "a0175ee3bccc567396460bf5acd36800cb10c49c";
    owner = "alecthomas";
    repo = "template";
    sha256 = "10albmv2bdrrgzzqh1rlr88zr2vvrabvzv59m15wazwx39mqzd7p";
    date = "2016-04-05";
  };

  termbox-go = buildFromGitHub {
    version = 1;
    rev = "e8f6d27f72a2f2bb598eb3579afd5ea364ef67f7";
    date = "2016-08-07";
    owner = "nsf";
    repo = "termbox-go";
    sha256 = "07i20iqk64iaxa60zp5ksmrglcz5dz8i49yg429kmil69njnagd4";
    propagatedBuildInputs = [
      go-runewidth
    ];
  };

  testify = buildFromGitHub {
    version = 1;
    rev = "v1.1.3";
    owner = "stretchr";
    repo = "testify";
    sha256 = "12r2v07zq22bk322hn8dn6nv1fg04wb5pz7j7bhgpq8ji2sassdp";
    propagatedBuildInputs = [
      go-difflib
      go-spew
      objx
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
    version = 1;
    date = "2014-06-26";
    rev = "14b3d72120e8d10ea6e6b7f87f7175734b1faab8";
    owner = "go-tomb";
    repo = "tomb";
    sha256 = "1ixpcahm1j5s9rv52al1k8047hsv7axxqvxcpdpa0lr70b33n45f";
    goPackagePath = "gopkg.in/tomb.v2";
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
    version = 1;
    owner = "BurntSushi";
    repo = "toml";
    rev = "v0.2.0";
    sha256 = "1sqhi5rx27scpcygdzipbhx4l6x4mjjxkbh5hg00wzqhfwhy4mxw";
  };

  unidecode = buildFromGitHub {
    version = 1;
    rev = "cb7f23ec59bec0d61b19c56cd88cee3d0cc1870c";
    owner = "rainycape";
    repo = "unidecode";
    sha256 = "1lf6r5clkmq72hx9yjc8s7z7g1vdn8a9333aq1c0n5lwhcavh6h3";
    date = "2015-09-07";
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
    version = 1;
    owner = "PuerkitoBio";
    repo = "urlesc";
    rev = "5fa9ff0392746aeae1c4b37fcc42c65afa7a9587";
    sate = "2015-02-08";
    sha256 = "00cil3qsy9agswkaagihvmmg67zklgk899h09p49wp7bxgj45rnk";
    date = "2015-02-08";
  };

  utp = buildFromGitHub {
    version = 1;
    rev = "59dfcf2995f0a175d717fe0b5b7c526771a0ad83";
    owner  = "anacrolix";
    repo   = "utp";
    sha256 = "0d5dygl3qkcjk3l99pr9l1syj5sfh1x8r3hb866myzmrqyd99w1n";
    date = "2016-07-22";
    propagatedBuildInputs = [
      envpprof
      missinggo
      sync
    ];
  };

  pborman_uuid = buildFromGitHub {
    version = 1;
    rev = "v1.0";
    owner = "pborman";
    repo = "uuid";
    sha256 = "1yk7vxrhsyk5izazdqywzfwb7iq6b5lwwdp0yc4rl4spqx30s0f9";
  };

  satori_uuid = buildFromGitHub {
    version = 1;
    rev = "v1.1.0";
    owner = "satori";
    repo = "uuid";
    sha256 = "19xzrdm1x07s7siavy8ssilhzyn89kqqpprmql1vsbplzljl4zgl";
  };

  vault = buildFromGitHub {
    version = 1;
    rev = "v0.6.1";
    owner = "hashicorp";
    repo = "vault";
    sha256 = "0w9rary7m3nqwgp8xp3iadwprpgwgzdngsya8fv3k3iqyakvchvz";

    buildInputs = [
      azure-sdk-for-go
      armon_go-metrics
      go-radix
      govalidator
      aws-sdk-go
      speakeasy
      candiedyaml
      etcd-client
      go-mssqldb
      duo_api_golang
      structs
      pkcs7
      yaml
      ini_v1
      ldap
      mysql
      gocql
      protobuf
      snappy
      go-github
      go-querystring
      hailocab_go-hostpool
      consul_api
      errwrap
      go-cleanhttp
      ugorji_go
      go-multierror
      go-rootcerts
      go-syslog
      hashicorp-go-uuid
      golang-lru
      hcl
      logutils
      net-rpc-msgpackrpc
      scada-client
      serf
      yamux
      go-jmespath
      pq
      go-isatty
      rabbit-hole
      mitchellh_cli
      copystructure
      go-homedir
      mapstructure
      reflectwalk
      swift
      columnize
      go-zookeeper
      #ugorji_go
      crypto
      net
      oauth2
      sys
      appengine
      asn1-ber
      mgo_v2
      grpc
      pester
      logxi
      go-colorable
      go-crypto
    ];
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
      structs
      go-cleanhttp
      go-multierror
      go-rootcerts
      mapstructure
      pester
    ];
  };

  viper = buildFromGitHub {
    version = 1;
    owner = "spf13";
    repo = "viper";
    rev = "c1ccc378a054ea8d4e38d8c67f6938d4760b53dd";
    date = "2016-06-06";
    sha256 = "1zhvyh8zq7c9j65l2jc2gaxmyvygfvxfjqn0hi5a938x7csydx90";
    buildInputs = [
      crypt
      pflag
    ];
    propagatedBuildInputs = [
      cast
      fsnotify
      hcl
      jwalterweatherman
      mapstructure
      properties
      toml
      yaml_v2
    ];
    patches = [
      (fetchTritonPatch {
        file = "viper/viper-2016-06-remove-etcd-support.patch";
        rev = "89c1dace6882bef6b3f05e5e6da3e9166665ef57";
        sha256 = "3cd7132e57b325168adf3f547f5123f744864ba8630ca653b8ee1e928e0e1ac9";
      })
    ];
  };

  vultr = buildFromGitHub {
    version = 1;
    rev = "v1.9";
    owner  = "JamesClonk";
    repo   = "vultr";
    sha256 = "1nrvs4vh42l47hn0rwj56wsjby25072g46r7sra8ci16jnpcsqrq";
    propagatedBuildInputs = [
      mow-cli
      tokenbucket
      ratelimit
    ];
  };

  websocket = buildFromGitHub {
    version = 1;
    rev = "v1.0.0";
    owner  = "gorilla";
    repo   = "websocket";
    sha256 = "11sggyd6plhcd4bdi8as0bx70bipda8li1rdf0y2n5iwnar3qflq";
  };

  wmi = buildFromGitHub {
    version = 1;
    rev = "f3e2bae1e0cb5aef83e319133eabfee30013a4a5";
    owner = "StackExchange";
    repo = "wmi";
    sha256 = "1paiis0l4adsq68v5p4mw7g7vv39j06fawbaph1d3cglzhkvsk7q";
    date = "2015-05-20";
  };

  yaml = buildFromGitHub {
    version = 1;
    rev = "aa0c862057666179de291b67d9f093d12b5a8473";
    date = "2016-06-03";
    owner = "ghodss";
    repo = "yaml";
    sha256 = "0vayx9m09flqlkwx8jy4cih01d8637cvnm1x3yxfvzamlb5kdm9p";
    propagatedBuildInputs = [ candiedyaml ];
  };

  yaml_v2 = buildFromGitHub {
    version = 2;
    rev = "31c299268d302dd0aa9a0dcf765a3d58971ac83f";
    date = "2016-09-12";
    owner = "go-yaml";
    repo = "yaml";
    sha256 = "0k2jasi5fqz114iqy0z5dwg77gf4zch14vh59njjynh1gn6gyrzz";
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
    version = 1;
    rev = "v2.0.0";
    owner  = "calmh";
    repo   = "xdr";
    sha256 = "017k3y66fy2azbv9iymxsixpyda9czz8v3mhpn17750vlg842dsp";
  };

  xorm = buildFromGitHub {
    version = 1;
    rev = "v0.5.4";
    owner  = "go-xorm";
    repo   = "xorm";
    sha256 = "1czlbikgkfp55sh772hldxckaxzywmkymgmbrrslmwa8jf3xmwxl";
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
