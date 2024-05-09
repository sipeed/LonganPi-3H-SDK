# This is a hybrid Makefile - it is meant run on the host to kick-off the docker container build
# but it's also used inside the container to perform the actual build steps.
# The make targets that are meatn to be run inside the container have the suffix "incontainer"

TAG := longanpi3h-build:latest
OUTPUT_DIR := /LonganPi-3H-SDK/out
#OUTPUT_DIR := out

OUTPUT_TARGETS		:= debian-cli debian-gui ubuntu-cli
OUTPUT_TARGETS_IMG	:= $(addsuffix -img,${OUTPUT_TARGETS})

# Targets that are meant to be run on the host
build:
	mkdir -p out/
	mkdir -p certs
	cp /usr/local/share/ca-certificates/* certs/
	docker build --progress=plain -t ${TAG} .

${OUTPUT_TARGETS}: build
	docker run --rm -v $(shell pwd)/out:${OUTPUT_DIR} --privileged ${TAG} $@.files

${OUTPUT_TARGETS_IMG}: build
	docker run --rm -v $(shell pwd)/out:${OUTPUT_DIR} --privileged ${TAG} $(patsubst %-img,%.img,$@)

# Targets that are meant to be run inside the container
base-internal:
	update-binfmts --enable
	./mkatf.sh
	./mkuboot.sh
	./mklinux.sh

%.base: base-internal
	./mkrootfs-$(basename $@).sh

%.files: %.base
	cp build/rootfs* ${OUTPUT_DIR}
	cp build/u-boot* ${OUTPUT_DIR}
	mkdir -p ${OUTPUT_DIR}/boot
	cp -r overlay/boot/* ${OUTPUT_DIR}/boot

.ONESHELL:
%.img: %.base
	$(eval OUTFILE := build/LPI3H_$(patsubst %.img,%,$@)_$(shell date +%Y%m%d).img)
	@echo Creating image file
	@dd if=/dev/zero of=${OUTFILE} bs=1M count=3072
	@echo Creating image file partitions
	@printf '%s\n' ',+64M,c;' ',,;' | sfdisk --wipe always --label dos ${OUTFILE}
	@PARTS=$$(sfdisk -J ${OUTFILE})
	@P1START=$$(echo $$PARTS | jq '.partitiontable.partitions[0].start*512')
	@P1LIMIT=$$(echo $$PARTS | jq '.partitiontable.partitions[0].size*512')
	@P2START=$$(echo $$PARTS | jq '.partitiontable.partitions[1].start*512')
	@P2LIMIT=$$(echo $$PARTS | jq '.partitiontable.partitions[1].size*512')
	@echo Mounting image file as loop device
	@LO_IMG=$$(losetup --show -f ${OUTFILE})
	@LO_P1=$$(losetup --show -o $$P1START --sizelimit $$P1LIMIT -f ${OUTFILE})
	@LO_P2=$$(losetup --show -o $$P2START --sizelimit $$P2LIMIT -f ${OUTFILE})
	@echo Creating boot FS
	@mkfs -t vfat $$LO_P1
	@echo Creating root FS
	@mkfs -t ext4 $$LO_P2
	@echo Flashing u-boot
	@dd if=build/u-boot-sunxi-with-spl.bin of=$$LO_IMG bs=1k seek=8 conv=fsync
	@echo Mounting boot partition
	@mkdir -p build/tmp/kernel
	@mount $$LO_P1 build/tmp/kernel
	@echo Copying kernel files to boot partition
	@cp -r overlay/boot/* build/tmp/kernel
	@echo Unmounting boot parition
	@umount $$LO_P1
	@echo Mounting root partition
	@mkdir -p build/tmp/rootfs
	@mount $$LO_P2 build/tmp/rootfs
	@echo Copying root-fs files to root partition
	@tar -xf build/rootfs-$(patsubst %.img,%,$@).tar -C build/tmp/rootfs/
	@echo Unmounting root partition
	@umount $$LO_P2
	@losetup -d $$LO_P1
	@losetup -d $$LO_P2
	@losetup -d $$LO_IMG
	@echo Copying image file to ${OUTPUT_DIR}
	@cp ${OUTFILE} ${OUTPUT_DIR}

clean:
	rm -rf out/