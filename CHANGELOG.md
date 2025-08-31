# Changelog

## [0.2.5](https://github.com/marshallford/terraform-ansible-k3s/compare/v0.2.4...v0.2.5) (2025-08-31)


### Features

* refactor playbook to streamline new machine configuration and ensure cluster-init server is configured first ([#31](https://github.com/marshallford/terraform-ansible-k3s/issues/31)) ([2fddbd0](https://github.com/marshallford/terraform-ansible-k3s/commit/2fddbd08c0deef725681b85c1eda240596eefcd7))
* support for separate internal and external node networks, support for static route in butane submodule ([#29](https://github.com/marshallford/terraform-ansible-k3s/issues/29)) ([376b0c1](https://github.com/marshallford/terraform-ansible-k3s/commit/376b0c151924e9d0ff74897c69f648e09815a632))


### Bug Fixes

* address new ansible-lint issues, upgrade k3s, upgrade python deps ([#32](https://github.com/marshallford/terraform-ansible-k3s/issues/32)) ([1e8356a](https://github.com/marshallford/terraform-ansible-k3s/commit/1e8356a9ce94d8445531556a3119874183ec39a9))

## [0.2.4](https://github.com/marshallford/terraform-ansible-k3s/compare/v0.2.3...v0.2.4) (2025-08-12)


### Bug Fixes

* adds cilium and graceful shutdown examples, ansible yaml conversion tweak ([#26](https://github.com/marshallford/terraform-ansible-k3s/issues/26)) ([25b0af1](https://github.com/marshallford/terraform-ansible-k3s/commit/25b0af14b3bcc066e4e2fddd63a645b2a4238fb2))
* adds new examples to release please extra-files config ([#28](https://github.com/marshallford/terraform-ansible-k3s/issues/28)) ([a96f59f](https://github.com/marshallford/terraform-ansible-k3s/commit/a96f59ff3a922ff74a1612bbc90e73253e6c8d6a))

## [0.2.3](https://github.com/marshallford/terraform-ansible-k3s/compare/v0.2.2...v0.2.3) (2025-08-11)


### Features

* adds kubelet configuration support ([#23](https://github.com/marshallford/terraform-ansible-k3s/issues/23)) ([30f1d4f](https://github.com/marshallford/terraform-ansible-k3s/commit/30f1d4fd7b634009efb8cca48e51de93ce7c4ce2))


### Bug Fixes

* improves module and submodule docs ([#25](https://github.com/marshallford/terraform-ansible-k3s/issues/25)) ([114869c](https://github.com/marshallford/terraform-ansible-k3s/commit/114869c382846ecd523f384d150f7c1638793cef))

## [0.2.2](https://github.com/marshallford/terraform-ansible-k3s/compare/v0.2.1...v0.2.2) (2025-08-06)


### Features

* adds cis hardening submodule ([#20](https://github.com/marshallford/terraform-ansible-k3s/issues/20)) ([a9194bc](https://github.com/marshallford/terraform-ansible-k3s/commit/a9194bcc471c130da7a3f8bd09712ab14967dbd0))


### Bug Fixes

* adds submodule readmes ([#22](https://github.com/marshallford/terraform-ansible-k3s/issues/22)) ([c04455c](https://github.com/marshallford/terraform-ansible-k3s/commit/c04455ce525ad26651e576b03ec60eeb72ef8e91))

## [0.2.1](https://github.com/marshallford/terraform-ansible-k3s/compare/v0.2.0...v0.2.1) (2025-08-01)


### Bug Fixes

* refactor kubeconfig submodule ([#18](https://github.com/marshallford/terraform-ansible-k3s/issues/18)) ([413b836](https://github.com/marshallford/terraform-ansible-k3s/commit/413b836f586fd4ef0805a56af2ad3313f6a67e0e))

## [0.2.0](https://github.com/marshallford/terraform-ansible-k3s/compare/v0.1.2...v0.2.0) (2025-07-31)


### ⚠ BREAKING CHANGES

* fixes api server vip port conflict with traefik, simplifies keepalived interface config, misc cleanup ([#17](https://github.com/marshallford/terraform-ansible-k3s/issues/17))

### Features

* fixes api server vip port conflict with traefik, simplifies keepalived interface config, misc cleanup ([#17](https://github.com/marshallford/terraform-ansible-k3s/issues/17)) ([a3737fe](https://github.com/marshallford/terraform-ansible-k3s/commit/a3737fe79028f4320d7da6deb91bd530e10558cd))
* refactor kubeconfig submodule, cleanup readme and example ([#15](https://github.com/marshallford/terraform-ansible-k3s/issues/15)) ([6959473](https://github.com/marshallford/terraform-ansible-k3s/commit/6959473738f0e7f2e88fa031c21a35d14896c01f))


### Bug Fixes

* adds new server_nodes_config configuration options ([#13](https://github.com/marshallford/terraform-ansible-k3s/issues/13)) ([8a230d2](https://github.com/marshallford/terraform-ansible-k3s/commit/8a230d26bb92aca1cd7a25ade78584f6630a0532))
* swap wait-for-dns service for quadlet retry ([#16](https://github.com/marshallford/terraform-ansible-k3s/issues/16)) ([a7dfe2d](https://github.com/marshallford/terraform-ansible-k3s/commit/a7dfe2d01655e8e64e204f38c77ba43f842968b8))

## [0.1.2](https://github.com/marshallford/terraform-ansible-k3s/compare/v0.1.1...v0.1.2) (2025-07-17)


### Features

* improve butane rpm-ostree snippets, add execution_environment_enabled variable, fix ssh_private_keys var ([#12](https://github.com/marshallford/terraform-ansible-k3s/issues/12)) ([70001fe](https://github.com/marshallford/terraform-ansible-k3s/commit/70001fee494b9079694793f6e0d44665a6e44527))


### Bug Fixes

* add conventional commit check, switch release please to use github app ([#10](https://github.com/marshallford/terraform-ansible-k3s/issues/10)) ([0c70944](https://github.com/marshallford/terraform-ansible-k3s/commit/0c7094497b1ad4a75d6455d4ede577d6d4dd3798))
* add link to github release badge ([#7](https://github.com/marshallford/terraform-ansible-k3s/issues/7)) ([fbb84f0](https://github.com/marshallford/terraform-ansible-k3s/commit/fbb84f0e4bea466433b63896332ee1d140f27c8e))
* switch to uv for python mgmt, cleanup makefile ([#9](https://github.com/marshallford/terraform-ansible-k3s/issues/9)) ([eaf192c](https://github.com/marshallford/terraform-ansible-k3s/commit/eaf192c72b2a7c4342353cd12d71d9f47dfa6a85))

## [0.1.1](https://github.com/marshallford/terraform-ansible-k3s/compare/v0.1.0...v0.1.1) (2025-04-26)


### Bug Fixes

* adds output descriptions ([#2](https://github.com/marshallford/terraform-ansible-k3s/issues/2)) ([bc2cfda](https://github.com/marshallford/terraform-ansible-k3s/commit/bc2cfda1a7a3654178d8cf1299e6b22a6af9ef56))
* giving up on release-please readme templating ([#6](https://github.com/marshallford/terraform-ansible-k3s/issues/6)) ([40a5912](https://github.com/marshallford/terraform-ansible-k3s/commit/40a5912ccdce914da6ea70e8e728b6f8b0676a94))
* tweak release-please templating ([#4](https://github.com/marshallford/terraform-ansible-k3s/issues/4)) ([e05cec6](https://github.com/marshallford/terraform-ansible-k3s/commit/e05cec6c07f16de9a46eead3e3f29ef44c87d494))
* tweak release-please templating again ([#5](https://github.com/marshallford/terraform-ansible-k3s/issues/5)) ([24b2ec2](https://github.com/marshallford/terraform-ansible-k3s/commit/24b2ec26b69fbb02dbf13d2b9de4127a67c10c16))

## 0.1.0 (2025-04-26)


### Features

* initial release ([e204a31](https://github.com/marshallford/terraform-ansible-k3s/commit/e204a317bfe03801877ad5c50789eac0eb533676))

## [0.1.1](https://github.com/marshallford/terraform-ansible-k3s/compare/v0.1.0...v0.1.1) (2025-04-17)


### Bug Fixes

* publish in release workflow ([#5](https://github.com/marshallford/terraform-ansible-k3s/issues/5)) ([e05844a](https://github.com/marshallford/terraform-ansible-k3s/commit/e05844a4ce4ff123a21190292424a4bdbbcd630c))

## 0.1.0 (2025-04-17)


### Features

* first pr ([#1](https://github.com/marshallford/terraform-ansible-k3s/issues/1)) ([065b252](https://github.com/marshallford/terraform-ansible-k3s/commit/065b252b65d98286364d19eedab3d633c440feb0))


### Bug Fixes

* adds manifest ([02120b8](https://github.com/marshallford/terraform-ansible-k3s/commit/02120b875df9d2f035ccd06bfb465e254083f44a))
* one artifact ([bdb6acd](https://github.com/marshallford/terraform-ansible-k3s/commit/bdb6acd5ed82bc7cbe14209a21cb88878f9ff50a))
* testing ([a3ab2ea](https://github.com/marshallford/terraform-ansible-k3s/commit/a3ab2eac4821d1f227c17339269cc59d482c9c08))
* workflow ([55ad202](https://github.com/marshallford/terraform-ansible-k3s/commit/55ad20275c26fdf3a40f6ced3071fea3efb1c15d))
