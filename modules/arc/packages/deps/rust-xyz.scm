;;; Copyright © 2025-2026 Arcensyl <dev@arcensyl.me>
;;;
;;; This file is NOT part of GNU Guix.
;;;
;;; This program is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by the Free
;;; Software Foundation; either version 3 of the License, or (at your option)
;;; any later version.
;;;
;;; This program is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
;;; or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
;;; for more details.
;;;
;;; You should have received a copy of the GNU General Public License along
;;; with this program.  If not, see <http://www.gnu.org/licenses/>.

(define-module (arc packages deps rust-xyz)
  #:use-module (guix build-system cargo))

;; NOTE: Most of this file's content was automatically generated.
;; Specifically, it was generated via the 'guix import crate' command (not AI).

(define-public lookup-cargo-inputs (const '()))

(define rust-addr2line-0.21.0
  (crate-source "addr2line" "0.21.0"
                "1jx0k3iwyqr8klqbzk6kjvr496yd94aspis10vwsj5wy7gib4c4a"))

(define rust-adler-1.0.2
  (crate-source "adler" "1.0.2"
                "1zim79cvzd5yrkzl3nyfx0avijwgk9fqv3yrscdy1cc79ih02qpj"))

(define rust-async-io-1.13.0
  (crate-source "async-io" "1.13.0"
                "1byj7lpw0ahk6k63sbc9859v68f28hpaab41dxsjj1ggjdfv9i8g"))

(define rust-async-io-2.2.2
  (crate-source "async-io" "2.2.2"
                "1iycg22ij8c1c87znvrpm8hfvb017icjqx3avhrhwqjs74vskyka"))

(define rust-async-lock-2.8.0
  (crate-source "async-lock" "2.8.0"
                "0asq5xdzgp3d5m82y5rg7a0k9q0g95jy6mgc7ivl334x7qlp4wi8"))

(define rust-async-lock-3.2.0
  (crate-source "async-lock" "3.2.0"
                "031i8kx440v77cvr3lp4a5dcjdz92zpi4616akfvjgfmhwky89bi"))

(define rust-async-pidfd-0.1.4
  (crate-source "async-pidfd" "0.1.4"
                "168pylpf7n898szw32sva7kf9h3x1mnip54mfr8f7f4v55c705qj"))

(define rust-autocfg-1.1.0
  (crate-source "autocfg" "1.1.0"
                "1ylp3cb47ylzabimazvbz9ms6ap784zhb6syaz6c1jqpmcmq0s6l"))

(define rust-backtrace-0.3.69
  (crate-source "backtrace" "0.3.69"
                "0dsq23dhw4pfndkx2nsa1ml2g31idm7ss7ljxp8d57avygivg290"))

(define rust-bitflags-1.3.2
  (crate-source "bitflags" "1.3.2"
                "12ki6w8gn1ldq7yz9y680llwk5gmrhrzszaa17g1sbrw2r2qvwxy"))

(define rust-bitflags-2.4.1
  (crate-source "bitflags" "2.4.1"
                "01ryy3kd671b0ll4bhdvhsz67vwz1lz53fz504injrd7wpv64xrj"))

(define rust-bitvec-1.0.1
  (crate-source "bitvec" "1.0.1"
                "173ydyj2q5vwj88k6xgjnfsshs4x9wbvjjv7sm0h36r34hn87hhv"))

(define rust-bytes-1.5.0
  (crate-source "bytes" "1.5.0"
                "08w2i8ac912l8vlvkv3q51cd4gr09pwlg3sjsjffcizlrb0i5gd2"))

(define rust-cc-1.0.83
  (crate-source "cc" "1.0.83"
                "1l643zidlb5iy1dskc5ggqs4wqa29a02f44piczqc8zcnsq4y5zi"))

(define rust-cfg-if-1.0.0
  (crate-source "cfg-if" "1.0.0"
                "1za0vb97n4brpzpv8lsbnzmq5r8f2b0cpqqr0sy8h5bn751xxwds"))

(define rust-concurrent-queue-2.4.0
  (crate-source "concurrent-queue" "2.4.0"
                "0qvk23ynj311adb4z7v89wk3bs65blps4n24q8rgl23vjk6lhq6i"))

(define rust-crossbeam-utils-0.8.18
  (crate-source "crossbeam-utils" "0.8.18"
                "176kcvw428zj024i60kd5jsqvli0y3khxac4ylk4gn7bf2kk1963"))

(define rust-equivalent-1.0.1
  (crate-source "equivalent" "1.0.1"
                "1malmx5f4lkfvqasz319lq6gb3ddg19yzf9s8cykfsgzdmyq0hsl"))

(define rust-errno-0.3.8
  (crate-source "errno" "0.3.8"
                "0ia28ylfsp36i27g1qih875cyyy4by2grf80ki8vhgh6vinf8n52"))

(define rust-evdev-0.12.1
  (crate-source "evdev" "0.12.1"
                "1ww35bkqf060nl6x2vfg0frd6ql470c90l2ah68b3mngr3y5kv9b"))

(define rust-event-listener-2.5.3
  (crate-source "event-listener" "2.5.3"
                "1q4w3pndc518crld6zsqvvpy9lkzwahp2zgza9kbzmmqh9gif1h2"))

(define rust-event-listener-4.0.1
  (crate-source "event-listener" "4.0.1"
                "04k7qbi5kgs36s905gxijj41kcr78xs2s6cp6vbg50254z7wvwl4"))

(define rust-event-listener-strategy-0.4.0
  (crate-source "event-listener-strategy" "0.4.0"
                "1lwprdjqp2ibbxhgm9khw7s7y7k4xiqj5i5yprqiks6mnrq4v3lm"))

(define rust-fastrand-1.9.0
  (crate-source "fastrand" "1.9.0"
                "1gh12m56265ihdbzh46bhh0jf74i197wm51jg1cw75q7ggi96475"))

(define rust-fastrand-2.0.1
  (crate-source "fastrand" "2.0.1"
                "19flpv5zbzpf0rk4x77z4zf25in0brg8l7m304d3yrf47qvwxjr5"))

(define rust-fork-0.1.23
  (crate-source "fork" "0.1.23"
                "1vd8fv09zzxpn67iizndsl24msvrzd995r06v7lmg2lr4cs4vrv0"))

(define rust-funty-2.0.0
  (crate-source "funty" "2.0.0"
                "177w048bm0046qlzvp33ag3ghqkqw4ncpzcm5lq36gxf2lla7mg6"))

(define rust-futures-core-0.3.30
  (crate-source "futures-core" "0.3.30"
                "07aslayrn3lbggj54kci0ishmd1pr367fp7iks7adia1p05miinz"))

(define rust-futures-io-0.3.30
  (crate-source "futures-io" "0.3.30"
                "1hgh25isvsr4ybibywhr4dpys8mjnscw4wfxxwca70cn1gi26im4"))

(define rust-futures-lite-1.13.0
  (crate-source "futures-lite" "1.13.0"
                "1kkbqhaib68nzmys2dc8j9fl2bwzf2s91jfk13lb2q3nwhfdbaa9"))

(define rust-futures-lite-2.1.0
  (crate-source "futures-lite" "2.1.0"
                "0hw1mp3y1i7xfid032c1ygx5vsadsp965wh06zpypxw331x2dvmf"))

(define rust-gethostname-0.4.3
  (crate-source "gethostname" "0.4.3"
                "063qqhznyckwx9n4z4xrmdv10s0fi6kbr17r6bi1yjifki2y0xh1"))

(define rust-gimli-0.28.1
  (crate-source "gimli" "0.28.1"
                "0lv23wc8rxvmjia3mcxc6hj9vkqnv1bqq0h8nzjcgf71mrxx6wa2"))

(define rust-hashbrown-0.14.3
  (crate-source "hashbrown" "0.14.3"
                "012nywlg0lj9kwanh69my5x67vjlfmzfi9a0rq4qvis2j8fil3r9"))

(define rust-hermit-abi-0.3.3
  (crate-source "hermit-abi" "0.3.3"
                "1dyc8qsjh876n74a3rcz8h43s27nj1sypdhsn2ms61bd3b47wzyp"))

(define rust-indexmap-2.1.0
  (crate-source "indexmap" "2.1.0"
                "07rxrqmryr1xfnmhrjlz8ic6jw28v6h5cig3ws2c9d0wifhy2c6m"))

(define rust-instant-0.1.12
  (crate-source "instant" "0.1.12"
                "0b2bx5qdlwayriidhrag8vhy10kdfimfhmb3jnjmsz2h9j1bwnvs"))

(define rust-io-lifetimes-1.0.11
  (crate-source "io-lifetimes" "1.0.11"
                "1hph5lz4wd3drnn6saakwxr497liznpfnv70via6s0v8x6pbkrza"))

(define rust-itoa-1.0.10
  (crate-source "itoa" "1.0.10"
                "0k7xjfki7mnv6yzjrbnbnjllg86acmbnk4izz2jmm1hx2wd6v95i"))

(define rust-libc-0.2.151
  (crate-source "libc" "0.2.151"
                "1x28f0zgp4zcwr891p8n9ag9w371sbib30vp4y6hi2052frplb9h"))

(define rust-libudev-sys-0.1.4
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "libudev-sys" "0.1.4"
                "09236fdzlx9l0dlrsc6xx21v5x8flpfm3d5rjq9jr5ivlas6k11w"))

(define rust-linux-raw-sys-0.3.8
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "linux-raw-sys" "0.3.8"
                "068mbigb3frrxvbi5g61lx25kksy98f2qgkvc4xg8zxznwp98lzg"))

(define rust-linux-raw-sys-0.4.12
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "linux-raw-sys" "0.4.12"
                "0mhlla3gk1jgn6mrq9s255rvvq8a1w3yk2vpjiwsd6hmmy1imkf4"))

(define rust-lock-api-0.4.11
  (crate-source "lock_api" "0.4.11"
                "0iggx0h4jx63xm35861106af3jkxq06fpqhpkhgw0axi2n38y5iw"))

(define rust-log-0.4.20
  (crate-source "log" "0.4.20"
                "13rf7wphnwd61vazpxr7fiycin6cb1g8fmvgqg18i464p0y1drmm"))

(define rust-memchr-2.6.4
  (crate-source "memchr" "2.6.4"
                "0rq1ka8790ns41j147npvxcqcl2anxyngsdimy85ag2api0fwrgn"))

(define rust-memoffset-0.6.5
  (crate-source "memoffset" "0.6.5"
                "1kkrzll58a3ayn5zdyy9i1f1v3mx0xgl29x0chq614zazba638ss"))

(define rust-miniz-oxide-0.7.1
  (crate-source "miniz_oxide" "0.7.1"
                "1ivl3rbbdm53bzscrd01g60l46lz5krl270487d8lhjvwl5hx0g7"))

(define rust-mio-0.8.10
  (crate-source "mio" "0.8.10"
                "02gyaxvaia9zzi4drrw59k9s0j6pa5d1y2kv7iplwjipdqlhngcg"))

(define rust-nix-0.23.2
  (crate-source "nix" "0.23.2"
                "0p5kxhm5d8lry0szqbsllpcb5i3z7lg1dkglw0ni2l011b090dwg"))

(define rust-num-cpus-1.16.0
  (crate-source "num_cpus" "1.16.0"
                "0hra6ihpnh06dvfvz9ipscys0xfqa9ca9hzp384d5m02ssvgqqa1"))

(define rust-object-0.32.1
  (crate-source "object" "0.32.1"
                "1c02x4kvqpnl3wn7gz9idm4jrbirbycyqjgiw6lm1g9k77fzkxcw"))

(define rust-parking-2.2.0
  (crate-source "parking" "2.2.0"
                "1blwbkq6im1hfxp5wlbr475mw98rsyc0bbr2d5n16m38z253p0dv"))

(define rust-parking-lot-0.12.1
  (crate-source "parking_lot" "0.12.1"
                "13r2xk7mnxfc5g0g6dkdxqdqad99j7s7z8zhzz4npw5r0g0v4hip"))

(define rust-parking-lot-core-0.9.9
  (crate-source "parking_lot_core" "0.9.9"
                "13h0imw1aq86wj28gxkblhkzx6z1gk8q18n0v76qmmj6cliajhjc"))

(define rust-paste-1.0.14
  (crate-source "paste" "1.0.14"
                "0k7d54zz8zrz0623l3xhvws61z5q2wd3hkwim6gylk8212placfy"))

(define rust-pin-project-lite-0.2.13
  (crate-source "pin-project-lite" "0.2.13"
                "0n0bwr5qxlf0mhn2xkl36sy55118s9qmvx2yl5f3ixkb007lbywa"))

(define rust-pkg-config-0.3.27
  (crate-source "pkg-config" "0.3.27"
                "0r39ryh1magcq4cz5g9x88jllsnxnhcqr753islvyk4jp9h2h1r6"))

(define rust-polling-2.8.0
  (crate-source "polling" "2.8.0"
                "1kixxfq1af1k7gkmmk9yv4j2krpp4fji2r8j4cz6p6d7ihz34bab"))

(define rust-polling-3.3.1
  (crate-source "polling" "3.3.1"
                "17hwk4g8qbdsyr0kqjddhw0l2v64pxhakkdlaqbc24xk99iglqyg"))

(define rust-proc-macro2-1.0.82
  (crate-source "proc-macro2" "1.0.82"
                "06qk88hbf6wg4v1i961zibhjz512873jwkz3myx1z82ip6dd9lwa"))

(define rust-quote-1.0.36
  (crate-source "quote" "1.0.36"
                "19xcmh445bg6simirnnd4fvkmp6v2qiwxh5f6rw4a70h76pnm9qg"))

(define rust-radium-0.7.0
  (crate-source "radium" "0.7.0"
                "02cxfi3ky3c4yhyqx9axqwhyaca804ws46nn4gc1imbk94nzycyw"))

(define rust-redox-syscall-0.4.1
  (crate-source "redox_syscall" "0.4.1"
                "1aiifyz5dnybfvkk4cdab9p2kmphag1yad6iknc7aszlxxldf8j7"))

(define rust-rustc-demangle-0.1.23
  (crate-source "rustc-demangle" "0.1.23"
                "0xnbk2bmyzshacjm2g1kd4zzv2y2az14bw3sjccq5qkpmsfvn9nn"))

(define rust-rustix-0.37.27
  (crate-source "rustix" "0.37.27"
                "1lidfswa8wbg358yrrkhfvsw0hzlvl540g4lwqszw09sg8vcma7y"))

(define rust-rustix-0.38.28
  (crate-source "rustix" "0.38.28"
                "05m3vacvbqbg6r6ksmx9k5afpi0lppjdv712crrpsrfax2jp5rbj"))

(define rust-ryu-1.0.16
  (crate-source "ryu" "1.0.16"
                "0k7b90xr48ag5bzmfjp82rljasw2fx28xr3bg1lrpx7b5sljm3gr"))

(define rust-scopeguard-1.2.0
  (crate-source "scopeguard" "1.2.0"
                "0jcz9sd47zlsgcnm1hdw0664krxwb5gczlif4qngj2aif8vky54l"))

(define rust-serde-1.0.201
  (crate-source "serde" "1.0.201"
                "0g1nrz2s6l36na6gdbph8k07xf9h5p3s6f0s79sy8a8nxpmiq3vq"))

(define rust-serde-derive-1.0.201
  (crate-source "serde_derive" "1.0.201"
                "0r98v8h47s7zhml7gz0sl6wv82vyzh1hv27f1g0g35lp1f9hbr65"))

(define rust-serde-json-1.0.117
  (crate-source "serde_json" "1.0.117"
                "1hxziifjlc0kn1cci9d4crmjc7qwnfi20lxwyj9lzca2c7m84la5"))

(define rust-serde-spanned-0.6.4
  (crate-source "serde_spanned" "0.6.4"
                "102ym47sr1y48ml42wjv6aq8y77bij1qckx1j0gb3rbka21jn0hj"))

(define rust-signal-hook-registry-1.4.1
  (crate-source "signal-hook-registry" "1.4.1"
                "18crkkw5k82bvcx088xlf5g4n3772m24qhzgfan80nda7d3rn8nq"))

(define rust-slab-0.4.9
  (crate-source "slab" "0.4.9"
                "0rxvsgir0qw5lkycrqgb1cxsvxzjv9bmx73bk5y42svnzfba94lg"))

(define rust-smallvec-1.11.2
  (crate-source "smallvec" "1.11.2"
                "0w79x38f7c0np7hqfmzrif9zmn0avjvvm31b166zdk9d1aad1k2d"))

(define rust-socket2-0.4.10
  (crate-source "socket2" "0.4.10"
                "03ack54dxhgfifzsj14k7qa3r5c9wqy3v6mqhlim99cc03y1cycz"))

(define rust-socket2-0.5.5
  (crate-source "socket2" "0.5.5"
                "1sgq315f1njky114ip7wcy83qlphv9qclprfjwvxcpfblmcsqpvv"))

(define rust-swayipc-async-2.0.2
  (crate-source "swayipc-async" "2.0.2"
                "1yyv7jwsr2z5azjal5hj8hgxb06dqrnxsaxrnjfjnp1pmwvjch48"))

(define rust-swayipc-types-1.3.1
  (crate-source "swayipc-types" "1.3.1"
                "1fwzdifnaj9ayz6fq96vcxpzr4dqhq1zgbqk3xbgsdlg89b2ddmi"))

(define rust-syn-2.0.61
  (crate-source "syn" "2.0.61"
                "1j8zhf5mmd2l5niwhiniw5wcp9v6fbd4a61v6rbfhsm5rf6fv4y9"))

(define rust-tap-1.0.1
  (crate-source "tap" "1.0.1"
                "0sc3gl4nldqpvyhqi3bbd0l9k7fngrcl4zs47n314nqqk4bpx4sm"))

(define rust-thiserror-1.0.51
  (crate-source "thiserror" "1.0.51"
                "1drvyim21w5sga3izvnvivrdp06l2c24xwbhp0vg1mhn2iz2277i"))

(define rust-thiserror-impl-1.0.51
  (crate-source "thiserror-impl" "1.0.51"
                "1ps9ylhlk2vn19fv3cxp40j3wcg1xmb117g2z2fbf4vmg2bj4x01"))

(define rust-tokio-1.35.0
  (crate-source "tokio" "1.35.0"
                "076cj1lwr712ki2mq0f5dilpvrca1f162kjqw6j92qm172r4a7c4"))

(define rust-tokio-macros-2.2.0
  (crate-source "tokio-macros" "2.2.0"
                "0fwjy4vdx1h9pi4g2nml72wi0fr27b5m954p13ji9anyy8l1x2jv"))

(define rust-tokio-stream-0.1.14
  (crate-source "tokio-stream" "0.1.14"
                "0hi8hcwavh5sdi1ivc9qc4yvyr32f153c212dpd7sb366y6rhz1r"))

(define rust-tokio-udev-0.9.1
  (crate-source "tokio-udev" "0.9.1"
                "0hniisppbji4052xfjrzkga5zkrqq4drb1g9r8yyyx0p4vd1hm7j"))

(define rust-toml-0.7.8
  (crate-source "toml" "0.7.8"
                "0mr2dpmzw4ndvzpnnli2dprcx61pdk62fq4mzw0b6zb27ffycyfx"))

(define rust-toml-datetime-0.6.5
  (crate-source "toml_datetime" "0.6.5"
                "1wds4pm2cn6agd38f0ivm65xnc7c7bmk9m0fllcaq82nd3lz8l1m"))

(define rust-toml-edit-0.19.15
  (crate-source "toml_edit" "0.19.15"
                "08bl7rp5g6jwmfpad9s8jpw8wjrciadpnbaswgywpr9hv9qbfnqv"))

(define rust-tracing-0.1.40
  (crate-source "tracing" "0.1.40"
                "1vv48dac9zgj9650pg2b4d0j3w6f3x9gbggf43scq5hrlysklln3"))

(define rust-tracing-core-0.1.32
  (crate-source "tracing-core" "0.1.32"
                "0m5aglin3cdwxpvbg6kz0r9r0k31j48n0kcfwsp6l49z26k3svf0"))

(define rust-udev-0.7.0
  (crate-source "udev" "0.7.0"
                "06hr927z0fdn7ay0p817b9x19i5fagmpmvz95yhl4d1pf3bbpgaf"))

(define rust-unicode-ident-1.0.12
  (crate-source "unicode-ident" "1.0.12"
                "0jzf1znfpb2gx8nr8mvmyqs1crnv79l57nxnbiszc7xf7ynbjm1k"))

(define rust-waker-fn-1.1.1
  (crate-source "waker-fn" "1.1.1"
                "142n74wlmpwcazfb5v7vhnzj3lb3r97qy8mzpjdpg345aizm3i7k"))

(define rust-wasi-0.11.0+wasi-snapshot-preview1
  (crate-source "wasi" "0.11.0+wasi-snapshot-preview1"
                "08z4hxwkpdpalxjps1ai9y7ihin26y9f476i53dv98v45gkqg3cw"))

(define rust-winapi-0.3.9
  (crate-source "winapi" "0.3.9"
                "06gl025x418lchw1wxj64ycr7gha83m44cjr5sarhynd9xkrm0sw"))

(define rust-winapi-i686-pc-windows-gnu-0.4.0
  (crate-source "winapi-i686-pc-windows-gnu" "0.4.0"
                "1dmpa6mvcvzz16zg6d5vrfy4bxgg541wxrcip7cnshi06v38ffxc"))

(define rust-winapi-x86-64-pc-windows-gnu-0.4.0
  (crate-source "winapi-x86_64-pc-windows-gnu" "0.4.0"
                "0gqq64czqb64kskjryj8isp62m2sgvx25yyj3kpc2myh85w24bki"))

(define rust-windows-aarch64-gnullvm-0.48.5
  (crate-source "windows_aarch64_gnullvm" "0.48.5"
                "1n05v7qblg1ci3i567inc7xrkmywczxrs1z3lj3rkkxw18py6f1b"))

(define rust-windows-aarch64-gnullvm-0.52.0
  (crate-source "windows_aarch64_gnullvm" "0.52.0"
                "1shmn1kbdc0bpphcxz0vlph96bxz0h1jlmh93s9agf2dbpin8xyb"))

(define rust-windows-aarch64-msvc-0.48.5
  (crate-source "windows_aarch64_msvc" "0.48.5"
                "1g5l4ry968p73g6bg6jgyvy9lb8fyhcs54067yzxpcpkf44k2dfw"))

(define rust-windows-aarch64-msvc-0.52.0
  (crate-source "windows_aarch64_msvc" "0.52.0"
                "1vvmy1ypvzdvxn9yf0b8ygfl85gl2gpcyvsvqppsmlpisil07amv"))

(define rust-windows-i686-gnu-0.48.5
  (crate-source "windows_i686_gnu" "0.48.5"
                "0gklnglwd9ilqx7ac3cn8hbhkraqisd0n83jxzf9837nvvkiand7"))

(define rust-windows-i686-gnu-0.52.0
  (crate-source "windows_i686_gnu" "0.52.0"
                "04zkglz4p3pjsns5gbz85v4s5aw102raz4spj4b0lmm33z5kg1m2"))

(define rust-windows-i686-msvc-0.48.5
  (crate-source "windows_i686_msvc" "0.48.5"
                "01m4rik437dl9rdf0ndnm2syh10hizvq0dajdkv2fjqcywrw4mcg"))

(define rust-windows-i686-msvc-0.52.0
  (crate-source "windows_i686_msvc" "0.52.0"
                "16kvmbvx0vr0zbgnaz6nsks9ycvfh5xp05bjrhq65kj623iyirgz"))

(define rust-windows-sys-0.48.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "windows-sys" "0.48.0"
                "1aan23v5gs7gya1lc46hqn9mdh8yph3fhxmhxlw36pn6pqc28zb7"))

(define rust-windows-sys-0.52.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "windows-sys" "0.52.0"
                "0gd3v4ji88490zgb6b5mq5zgbvwv7zx1ibn8v3x83rwcdbryaar8"))

(define rust-windows-targets-0.48.5
  (crate-source "windows-targets" "0.48.5"
                "034ljxqshifs1lan89xwpcy1hp0lhdh4b5n0d2z4fwjx2piacbws"))

(define rust-windows-targets-0.52.0
  (crate-source "windows-targets" "0.52.0"
                "1kg7a27ynzw8zz3krdgy6w5gbqcji27j1sz4p7xk2j5j8082064a"))

(define rust-windows-x86-64-gnu-0.48.5
  (crate-source "windows_x86_64_gnu" "0.48.5"
                "13kiqqcvz2vnyxzydjh73hwgigsdr2z1xpzx313kxll34nyhmm2k"))

(define rust-windows-x86-64-gnu-0.52.0
  (crate-source "windows_x86_64_gnu" "0.52.0"
                "1zdy4qn178sil5sdm63lm7f0kkcjg6gvdwmcprd2yjmwn8ns6vrx"))

(define rust-windows-x86-64-gnullvm-0.48.5
  (crate-source "windows_x86_64_gnullvm" "0.48.5"
                "1k24810wfbgz8k48c2yknqjmiigmql6kk3knmddkv8k8g1v54yqb"))

(define rust-windows-x86-64-gnullvm-0.52.0
  (crate-source "windows_x86_64_gnullvm" "0.52.0"
                "17lllq4l2k1lqgcnw1cccphxp9vs7inq99kjlm2lfl9zklg7wr8s"))

(define rust-windows-x86-64-msvc-0.48.5
  (crate-source "windows_x86_64_msvc" "0.48.5"
                "0f4mdp895kkjh9zv8dxvn4pc10xr7839lf5pa9l0193i2pkgr57d"))

(define rust-windows-x86-64-msvc-0.52.0
  (crate-source "windows_x86_64_msvc" "0.52.0"
                "012wfq37f18c09ij5m6rniw7xxn5fcvrxbqd0wd8vgnl3hfn9yfz"))

(define rust-winnow-0.5.28
  (crate-source "winnow" "0.5.28"
                "1qhzp7mg9m22qy7hjvdm178c9lyv16kjf3hsgb92y33jyy30g0vc"))

(define rust-wyz-0.5.1
  (crate-source "wyz" "0.5.1"
                "1vdrfy7i2bznnzjdl9vvrzljvs4s3qm8bnlgqwln6a941gy61wq5"))

(define rust-x11rb-0.13.0
  (crate-source "x11rb" "0.13.0"
                "06lzpmb67sfw37m0i9zz786hx6fklmykd9j3689blk3yijnmxwpq"))

(define rust-x11rb-protocol-0.13.0
  (crate-source "x11rb-protocol" "0.13.0"
                "0d3cc2dr5fcx8asgrm31d7lrxpnbqi6kl5v3r71gx7xxp3272gp6"))

(define-cargo-inputs lookup-cargo-inputs
                     (makima-remapper =>
                             (list rust-addr2line-0.21.0
                                   rust-adler-1.0.2
                                   rust-async-io-1.13.0
                                   rust-async-io-2.2.2
                                   rust-async-lock-2.8.0
                                   rust-async-lock-3.2.0
                                   rust-async-pidfd-0.1.4
                                   rust-autocfg-1.1.0
                                   rust-backtrace-0.3.69
                                   rust-bitflags-1.3.2
                                   rust-bitflags-2.4.1
                                   rust-bitvec-1.0.1
                                   rust-bytes-1.5.0
                                   rust-cc-1.0.83
                                   rust-cfg-if-1.0.0
                                   rust-concurrent-queue-2.4.0
                                   rust-crossbeam-utils-0.8.18
                                   rust-equivalent-1.0.1
                                   rust-errno-0.3.8
                                   rust-evdev-0.12.1
                                   rust-event-listener-2.5.3
                                   rust-event-listener-4.0.1
                                   rust-event-listener-strategy-0.4.0
                                   rust-fastrand-1.9.0
                                   rust-fastrand-2.0.1
                                   rust-fork-0.1.23
                                   rust-funty-2.0.0
                                   rust-futures-core-0.3.30
                                   rust-futures-io-0.3.30
                                   rust-futures-lite-1.13.0
                                   rust-futures-lite-2.1.0
                                   rust-gethostname-0.4.3
                                   rust-gimli-0.28.1
                                   rust-hashbrown-0.14.3
                                   rust-hermit-abi-0.3.3
                                   rust-indexmap-2.1.0
                                   rust-instant-0.1.12
                                   rust-io-lifetimes-1.0.11
                                   rust-itoa-1.0.10
                                   rust-libc-0.2.151
                                   rust-libudev-sys-0.1.4
                                   rust-linux-raw-sys-0.3.8
                                   rust-linux-raw-sys-0.4.12
                                   rust-lock-api-0.4.11
                                   rust-log-0.4.20
                                   rust-memchr-2.6.4
                                   rust-memoffset-0.6.5
                                   rust-miniz-oxide-0.7.1
                                   rust-mio-0.8.10
                                   rust-nix-0.23.2
                                   rust-num-cpus-1.16.0
                                   rust-object-0.32.1
                                   rust-parking-2.2.0
                                   rust-parking-lot-0.12.1
                                   rust-parking-lot-core-0.9.9
                                   rust-paste-1.0.14
                                   rust-pin-project-lite-0.2.13
                                   rust-pkg-config-0.3.27
                                   rust-polling-2.8.0
                                   rust-polling-3.3.1
                                   rust-proc-macro2-1.0.82
                                   rust-quote-1.0.36
                                   rust-radium-0.7.0
                                   rust-redox-syscall-0.4.1
                                   rust-rustc-demangle-0.1.23
                                   rust-rustix-0.37.27
                                   rust-rustix-0.38.28
                                   rust-ryu-1.0.16
                                   rust-scopeguard-1.2.0
                                   rust-serde-1.0.201
                                   rust-serde-derive-1.0.201
                                   rust-serde-json-1.0.117
                                   rust-serde-spanned-0.6.4
                                   rust-signal-hook-registry-1.4.1
                                   rust-slab-0.4.9
                                   rust-smallvec-1.11.2
                                   rust-socket2-0.4.10
                                   rust-socket2-0.5.5
                                   rust-swayipc-async-2.0.2
                                   rust-swayipc-types-1.3.1
                                   rust-syn-2.0.61
                                   rust-tap-1.0.1
                                   rust-thiserror-1.0.51
                                   rust-thiserror-impl-1.0.51
                                   rust-tokio-1.35.0
                                   rust-tokio-macros-2.2.0
                                   rust-tokio-stream-0.1.14
                                   rust-tokio-udev-0.9.1
                                   rust-toml-0.7.8
                                   rust-toml-datetime-0.6.5
                                   rust-toml-edit-0.19.15
                                   rust-tracing-0.1.40
                                   rust-tracing-core-0.1.32
                                   rust-udev-0.7.0
                                   rust-unicode-ident-1.0.12
                                   rust-waker-fn-1.1.1
                                   rust-wasi-0.11.0+wasi-snapshot-preview1
                                   rust-winapi-0.3.9
                                   rust-winapi-i686-pc-windows-gnu-0.4.0
                                   rust-winapi-x86-64-pc-windows-gnu-0.4.0
                                   rust-windows-sys-0.48.0
                                   rust-windows-sys-0.52.0
                                   rust-windows-targets-0.48.5
                                   rust-windows-targets-0.52.0
                                   rust-windows-aarch64-gnullvm-0.48.5
                                   rust-windows-aarch64-gnullvm-0.52.0
                                   rust-windows-aarch64-msvc-0.48.5
                                   rust-windows-aarch64-msvc-0.52.0
                                   rust-windows-i686-gnu-0.48.5
                                   rust-windows-i686-gnu-0.52.0
                                   rust-windows-i686-msvc-0.48.5
                                   rust-windows-i686-msvc-0.52.0
                                   rust-windows-x86-64-gnu-0.48.5
                                   rust-windows-x86-64-gnu-0.52.0
                                   rust-windows-x86-64-gnullvm-0.48.5
                                   rust-windows-x86-64-gnullvm-0.52.0
                                   rust-windows-x86-64-msvc-0.48.5
                                   rust-windows-x86-64-msvc-0.52.0
                                   rust-winnow-0.5.28
                                   rust-wyz-0.5.1
                                   rust-x11rb-0.13.0
                                   rust-x11rb-protocol-0.13.0)))
