##  (2023-05-25)

### [4.6.11-5](http://gitlab.cmss.com/eos/indexer/indexer-src/compare/4.6.11-4...4.6.11-5) (2023-05-25)


### :sparkles: Features

* add indexer e2 alternator probe script ([78d2ff2](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/78d2ff2c752678c0e3967cd3cf6ef7d63ebd9dad)), closes [#CLOUDTEST-11733](http://gitlab.cmss.com/eos/indexer/indexer-src/issues/CLOUDTEST-11733)
* add probe script to indexer e2 dockerfile ([e3f9ba2](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/e3f9ba2e54086081b2c4874d150f230c07727368)), closes [#CLOUDTEST-11733](http://gitlab.cmss.com/eos/indexer/indexer-src/issues/CLOUDTEST-11733)


### :zap: Refator

* correct the directory of probe check in indexer e2 container ([302a840](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/302a84083cd0b129c3a3f68834cfde4446d77e49))

### [4.6.11-4](http://gitlab.cmss.com/eos/indexer/indexer-src/compare/4.6.11-3...4.6.11-4) (2023-04-26)


### :bug: Bug Fixes

* locator: token_metadata: get rid of a quadratic .. ([d6e6726](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/d6e672676393b06d61353f6c57959f102a0596e8)), closes [#12724](http://gitlab.cmss.com/eos/indexer/indexer-src/issues/12724) [#10337](http://gitlab.cmss.com/eos/indexer/indexer-src/issues/10337) [#10817](http://gitlab.cmss.com/eos/indexer/indexer-src/issues/10817) [#10836](http://gitlab.cmss.com/eos/indexer/indexer-src/issues/10836) [#10837](http://gitlab.cmss.com/eos/indexer/indexer-src/issues/10837) [#12724](http://gitlab.cmss.com/eos/indexer/indexer-src/issues/12724) [#ESDSSGY-6622](http://gitlab.cmss.com/eos/indexer/indexer-src/issues/ESDSSGY-6622)

### [4.6.11-3](http://gitlab.cmss.com/eos/indexer/indexer-src/compare/4.6.11-1...4.6.11-3) (2023-04-21)


### :sparkles: Features

* metrics on stream latency ([bdfa361](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/bdfa3618fccbf4ce4825f493f71d23019a4244a6)), closes [#ESDSSGY-6622](http://gitlab.cmss.com/eos/indexer/indexer-src/issues/ESDSSGY-6622)
* support set CL for getrecords ([d12db0a](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/d12db0aa2d3ac6610b6f9429482aa72bf5f3e808)), closes [#ESDSSGY-6622](http://gitlab.cmss.com/eos/indexer/indexer-src/issues/ESDSSGY-6622)


### :bug: Bug Fixes

* typos in getrecords cl ([553bc89](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/553bc8909c79f8f8a28d17c6bc52455c3ab38b8c)), closes [#ESDSSGY-6622](http://gitlab.cmss.com/eos/indexer/indexer-src/issues/ESDSSGY-6622)

### [4.6.11-1](http://gitlab.cmss.com/eos/indexer/indexer-src/compare/7ab0ec1fac46f9825bb8d4ad5f0ed5ec3f02770b...4.6.11-1) (2023-04-07)


### :bug: Bug Fixes

* move io_propertes config from seastar_io to scylla-server ([06119b9](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/06119b9c5884755b2aa0f639d7b9e11fd60830ec))
* query gsi created by cql should check virtual col ([cfa4c7e](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/cfa4c7e7ab9367102239f28ce2e828e3add4debe))
* query gsi shouldn't fail when cl is two ([1414c9c](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/1414c9c6ede7327605f319d2736bd4447493882e))
* revert add virtual col ([39d7f4d](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/39d7f4d6059cd80e27a25a4ec71b0222fbe4d8fe)), closes [#IAASOSG-110](http://gitlab.cmss.com/eos/indexer/indexer-src/issues/IAASOSG-110)


### :zap: Refator

* config rf and cl problem ([3a30aaf](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/3a30aaff26510dea5dc8d65ca052061b1a174081))
* execute io setup according to the io properties file ([56d71e6](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/56d71e62b55cbceb2142861589bd82898e05ea5b))
* optimize indexer e2 container raid and setup step ([4c4b839](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/4c4b83906378a42720886997984c099ea9c2df84)), closes [#ESDSSGY-6636](http://gitlab.cmss.com/eos/indexer/indexer-src/issues/ESDSSGY-6636)
* rebase to v4.6.11 ([7507913](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/750791334bd12a8353df0ec10b6ad38429217918)), closes [#ESDSSGY-6622](http://gitlab.cmss.com/eos/indexer/indexer-src/issues/ESDSSGY-6622)
* resolve build error caused by default_timeout() method ([1aa6992](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/1aa69921933fde772bde39518b2318bb3562702c))
* support consistent read for query ([a0cec62](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/a0cec623eb116d789162fcc34c23d378a1a108bf))
* support different timeout with different op ([a463cd9](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/a463cd934acffe827836aebafd72af0dc22c9f79))
* support reply 503 when request timeout ([3b8e0f0](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/3b8e0f040a9c2273602c7f44096f5c63fcebb8a0))
* 增加Jira校验规则，完善提交信息校验 ([3e3ccec](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/3e3ccec8c0a11419c945c6653369386115adb94d))


### :sparkles: Features

* **ci:** ci tag split ([d607274](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/d6072749f7bc858367d4f0b8eee4f5f731634a2e)), closes [#ESDSSGY-6622](http://gitlab.cmss.com/eos/indexer/indexer-src/issues/ESDSSGY-6622)
* **ci:** commitLint check update ([5cf4c9e](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/5cf4c9ee6f7a99c0c3ad2241d37acafc6c3ef367))
* **ci:** commitLint separate ([7702814](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/77028148d697bdc791d4d622f6ad8e29ce1a5997))
* **ci:** use commitlint to check commit-msg ([7ab0ec1](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/7ab0ec1fac46f9825bb8d4ad5f0ed5ec3f02770b)), closes [#ESDSSGY-5669](http://gitlab.cmss.com/eos/indexer/indexer-src/issues/ESDSSGY-5669)
* support latency metrics for query and scan ([e2dc54e](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/e2dc54e38b11e34f8a3b78a334980abe1fceb9f2))


### :package: Build

* **ci:** fix version inconsistency issues ([99851ce](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/99851cef5c4dd8d62bd6a1f01348a98956fa367a)), closes [#ESDSSGY-6622](http://gitlab.cmss.com/eos/indexer/indexer-src/issues/ESDSSGY-6622)
* **ci:** indexer e2 rpm build ci ([d712cca](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/d712cca82c25dfbf6a26515c2831aaee6ea7d438)), closes [#ESDSSGY-6622](http://gitlab.cmss.com/eos/indexer/indexer-src/issues/ESDSSGY-6622)
* cmd image need install version* ([3ae43fe](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/3ae43fe6fd1245e1567a1d7e778379430f1404bf)), closes [#ESDSSGY-6622](http://gitlab.cmss.com/eos/indexer/indexer-src/issues/ESDSSGY-6622)
* git submodule update failed ([0eedaa2](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/0eedaa231236e8fca094b01defe4fefb6d42aa95))
* update indexer-cmd to 4.6.3 ([dfd3d51](http://gitlab.cmss.com/eos/indexer/indexer-src/commit/dfd3d51d7b0c200ff752b24257f449cad4d20a2a))

