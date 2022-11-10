#!/usr/bin/make -f

#====== SETTING UP BUILD FLAGS ======
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
COMMIT := $(shell git log -1 --format='%H')

# don't override user values
ifeq (,$(VERSION))
	VERSION := $(shell git describe --tags)
	# if VERSION is empty, then populate it with branch's name and raw commit hash
	ifeq (,$(VERSION))
	VERSION := $(BRANCH)-$(COMMIT)
	endif
endif

LEDGER_ENABLED ?= true
TM_VERSION := $(shell go list -m github.com/tendermint/tendermint | sed 's:.* ::')

# process build tags

build_tags = netgo
ifeq ($(LEDGER_ENABLED),true)
	ifeq ($(OS),Windows_NT)
	GCCEXE = $(shell where gcc.exe 2> NUL)
	ifeq ($(GCCEXE),)
	$(error gcc.exe not installed for ledger support, please install or set LEDGER_ENABLED=false)
	else
	build_tags += ledger
	endif
	else
	UNAME_S = $(shell uname -s)
	ifeq ($(UNAME_S),OpenBSD)
	$(warning OpenBSD detected, disabling ledger support (https://github.com/cosmos/cosmos-sdk/issues/1988))
	else
	GCC = $(shell command -v gcc 2> /dev/null)
	ifeq ($(GCC),)
	$(error gcc not installed for ledger support, please install or set LEDGER_ENABLED=false)
	else
	build_tags += ledger
	endif
	endif
	endif
endif

ifeq (cleveldb,$(findstring cleveldb,$(dongtramcam_BUILD_OPTIONS)))
	build_tags += gcc cleveldb
endif
build_tags += $(BUILD_TAGS)
build_tags := $(strip $(build_tags))

whitespace :=
whitespace += $(whitespace)
comma := ,
build_tags_comma_sep := $(subst $(whitespace),$(comma),$(build_tags))

# process linker flags

ldflags = -X github.com/cosmos/cosmos-sdk/version.Name=dongtramcam \
		  -X github.com/cosmos/cosmos-sdk/version.AppName=dongtramcamd \
		  -X github.com/cosmos/cosmos-sdk/version.Version=$(VERSION) \
		  -X github.com/cosmos/cosmos-sdk/version.Commit=$(COMMIT) \
		  -X "github.com/cosmos/cosmos-sdk/version.BuildTags=$(build_tags_comma_sep)" \
			-X github.com/tendermint/tendermint/version.TMCoreSemVer=$(TM_VERSION)

ifeq (cleveldb,$(findstring cleveldb,$(dongtramcam_BUILD_OPTIONS)))
	ldflags += -X github.com/cosmos/cosmos-sdk/types.DBBackend=cleveldb
endif
ifeq (,$(findstring nostrip,$(dongtramcam_BUILD_OPTIONS)))
	ldflags += -w -s
endif
ldflags += $(LDFLAGS)
ldflags := $(strip $(ldflags))

BUILD_FLAGS := -tags "$(build_tags)" -ldflags '$(ldflags)'
# check for nostrip option
ifeq (,$(findstring nostrip,$(dongtramcam_BUILD_OPTIONS)))
	BUILD_FLAGS += -trimpath
endif

#====== BUILDING COMMANDS ======
all: install

install: go.sum
	go install -mod=readonly $(BUILD_FLAGS) ./...

build:
	go build $(BUILD_FLAGS) -o bin/dongtramcamd ./cmd/dongtramcamd

.PHONY: all install build

###############################################################################
###                                  Proto                                  ###
###############################################################################

protoVer=v0.7
protoImageName=tendermintdev/sdk-proto-gen:$(protoVer)
containerProtoGen=dongtramcam-proto-gen-$(protoVer)

proto-gen:
	@echo "Generating Protobuf files"
	@if docker ps -a --format '{{.Names}}' | grep -Eq "^${containerProtoGen}$$"; then docker start -a $(containerProtoGen); else docker run --name $(containerProtoGen) -v $(CURDIR):/workspace --workdir /workspace $(protoImageName) \
		sh ./scripts/protocgen.sh; fi
	
###############################################################################
###                           Tests & Simulation                            ###
###############################################################################

test:
	@go test -v ./x/...

###############################################################################
###                                Localnet                                 ###
###############################################################################

# Build image for a local testnet
localnet-build:
	docker build -f Dockerfile -t dongtramcam-node .

# Start a 4-node testnet locally
localnet-start:   
    docker run --rm -v /build:/dongtramcam:Z dongtramcam-node -c "dongtramcamd testnet --v 4 -o dongtramcam --chain-id dongtramcam-1 --keyring-backend=test --starting-ip-address 192.167.10.2"
	docker-compose up -d
	bash scripts/add-keys.sh

# Stop testnet
localnet-stop:
	docker-compose down

# Clean testnet
localnet-clean:
	docker-compose down
	sudo rm -rf build

# Reset testnet
localnet-unsafe-reset:
	docker-compose down
ifeq ($(OS),Windows_NT)
	@docker run --rm -v $(CURDIR)\build\node0\dongtramcamd:/dongtramcam\Z dongtramcam/node "./dongtramcamd tendermint unsafe-reset-all --home=/dongtramcam"
	@docker run --rm -v $(CURDIR)\build\node1\dongtramcamd:/dongtramcam\Z dongtramcam/node "./dongtramcamd tendermint unsafe-reset-all --home=/dongtramcam"
	@docker run --rm -v $(CURDIR)\build\node2\dongtramcamd:/dongtramcam\Z dongtramcam/node "./dongtramcamd tendermint unsafe-reset-all --home=/dongtramcam"
	@docker run --rm -v $(CURDIR)\build\node3\dongtramcamd:/dongtramcam\Z dongtramcam/node "./dongtramcamd tendermint unsafe-reset-all --home=/dongtramcam"
else
	@docker run --rm -v $(CURDIR)/build/node0/dongtramcamd:/dongtramcam:Z dongtramcam/node "./dongtramcamd tendermint unsafe-reset-all --home=/dongtramcam"
	@docker run --rm -v $(CURDIR)/build/node1/dongtramcamd:/dongtramcam:Z dongtramcam/node "./dongtramcamd tendermint unsafe-reset-all --home=/dongtramcam"
	@docker run --rm -v $(CURDIR)/build/node2/dongtramcamd:/dongtramcam:Z dongtramcam/node "./dongtramcamd tendermint unsafe-reset-all --home=/dongtramcam"
	@docker run --rm -v $(CURDIR)/build/node3/dongtramcamd:/dongtramcam:Z dongtramcam/node "./dongtramcamd tendermint unsafe-reset-all --home=/dongtramcam"
endif

# Clean testnet
localnet-show-logstream:
	docker-compose logs --tail=1000 -f

.PHONY: localnet-build localnet-start localnet-stop