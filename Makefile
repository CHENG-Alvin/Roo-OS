ASM=nasm 
SRC_DIR=./src
BUILD_DIR=./build
LINKER=x86_64-elf-ld
CC=x86_64-elf-gcc
CPPC=x86_64-elf-g++

all-roo:
	@make clean
	@make bootloader
	@make kernel
	@make link
	@make merge

bootloader:
	@echo "Building bootloader..."
	@${ASM} -f bin ${SRC_DIR}/bootloader/boot.asm  -o ${BUILD_DIR}/boot.bin -i ${SRC_DIR}/bootloader
	@echo "Bootloader built."

run:
	@echo "Running..."
	@qemu-system-x86_64 -fda ${BUILD_DIR}/image.bin -vga std

kernel:
	@echo "Building kernel..."
	@${CC} -ffreestanding -c ${SRC_DIR}/kernel/kernel.c -o ${BUILD_DIR}/kernel_main.o 
	@${CC} -ffreestanding -c ${SRC_DIR}/kernel/drivers/port.c -o ${BUILD_DIR}/kernel_port.o 
	@${CC} -ffreestanding -c ${SRC_DIR}/kernel/drivers/printutils.c -o ${BUILD_DIR}/kernel_printutils.o 
	@${CC} -ffreestanding -c ${SRC_DIR}/kernel/drivers/types.c -o ${BUILD_DIR}/kernel_types.o
	@${ASM} ${SRC_DIR}/kernel/kernel_entry.asm -f elf64 -o ${BUILD_DIR}/kernel_entry.o 
	@echo "Kernel built."

clean:
	@echo "Cleaning..."
	@rm -rf ${BUILD_DIR}/
	@mkdir ${BUILD_DIR}/
	@echo "Cleaned."

link:	
	@echo "Linking..."
	@${LINKER} -o ${BUILD_DIR}/kernel.bin -Ttext 0x1000 ${BUILD_DIR}/kernel_main.o ${BUILD_DIR}/kernel_printutils.o ${BUILD_DIR}/kernel_port.o ${BUILD_DIR}/kernel_entry.o --oformat binary
	@echo "Linked."

merge:
	@echo "Merging binaries..."
	@cat ${BUILD_DIR}/boot.bin ${BUILD_DIR}/kernel.bin > ${BUILD_DIR}/image.bin
	@echo "Binaries merged."

dump_kernel:
	@echo "Dumping kernel..."
	@ndisasm -b 32 ${BUILD_DIR}/kernel.bin
	@echo "Kernel dumped."

dump_bootsector:
	@echo "Dumping bootsector..."
	@ndisasm -b 32 ${BUILD_DIR}/boot.bin
	@echo "bootsector dumped."

dump_all:
	@echo "Dumping All..."
	@ndisasm -b 32 ${BUILD_DIR}/image.bin
	@echo "All dumped."