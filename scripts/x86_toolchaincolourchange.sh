#!/bin/bash
# Edited by Selim Tahir November 2023
# Many issues encountered, but hopefully I am able to troubleshoot. Kali vscode crashed, but I already altered the scripts and saved them on notes, so I was able to add it to my desktop 
# Due to the crash I only have 1 commit and not many branches
# Define ANSI color code variables for color-coding the output.

RED='\033[0;31m'     # Red color for errors.
GREEN='\033[0;32m'   # Green color for success messages.
YELLOW='\033[0;33m'  # Yellow color for warnings or information.
NC='\033[0m'         # No Color. Resets the text to default terminal color.

# Function to print errors in red. Accepts an argument and prints it in red.
print_error() {
  echo -e "${RED}$1${NC}"  # The -e flag allows the interpretation of backslash escapes.
}

# Function to print success messages in green. Accepts an argument and prints it in green.
print_success() {
  echo -e "${GREEN}$1${NC}"
}

# Function to print info messages in yellow. Accepts an argument and prints it in yellow.
print_info() {
  echo -e "${YELLOW}$1${NC}"
}


# Check if the number of command-line arguments is less than 1 and print the usage in red if so.
if [ $# -lt 1 ]; then
  print_error "Usage:"
  print_error "x86_toolchain.sh [ options ] <assembly filename> [-o | --output <output filename>]"
  print_error ""
  print_error "Options:"
  print_error "-v | --verbose                Show some information about steps performed."
  print_error "-g | --gdb                    Run gdb command on executable."
  print_error "-b | --break <break point>    Add breakpoint after running gdb. Default is _start."
  print_error "-r | --run                    Run program in gdb automatically."
  print_error "-q | --qemu                   Run executable in QEMU emulator."
  print_error "-64| --x86-64                 Compile for 64bit (x86-64) system."
  print_error "-o | --output <filename>      Output filename."
  print_error ""
  exit 1  # Exit the script after printing the usage message.
fi

# Initialize variables to hold command-line arguments and flags.
POSITIONAL_ARGS=()
GDB=False
OUTPUT_FILE=""
VERBOSE=False
BITS=False
QEMU=False
BREAK="_start"
RUN=False

# Loop over all command-line arguments.
# This loop processes flags and sets the appropriate variables based on the user's input.
while [[ $# -gt 0 ]]; do
  case $1 in
    -g|--gdb)
      GDB=True
      shift # Remove the current argument from the processing list.
      ;;
    -o|--output)
      OUTPUT_FILE="$2"
      shift # Remove '-o' or '--output'
      shift # Remove the actual output file name from the list.
      ;;
    -v|--verbose)
      VERBOSE=True
      shift # Remove '-v' or '--verbose'
      ;;
    -64|--x86-64)
      BITS=True
      shift # Remove '-64' or '--x86-64'
      ;;
    -q|--qemu)
      QEMU=True
      shift # Remove '-q' or '--qemu'
      ;;
    -r|--run)
      RUN=True
      shift # Remove '-r' or '--run'
      ;;
    -b|--break)
      BREAK="$2"
      shift # Remove '-b' or '--break'
      shift # Remove the breakpoint name from the list.
      ;;
    -*|--*)
      print_error "Unknown option $1"  # Print unknown flag errors in red.
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # Save positional argument.
      shift # Remove the argument from the list.
      ;;
  esac
done

# Restore positional parameters.
set -- "${POSITIONAL_ARGS[@]}"

# Check if the input file exists, and print an error in red if it does not.
if [[ ! -f $1 ]]; then
  print_error "Specified file does not exist"
  exit 1
fi

# If no output file was specified, derive it from the input filename by removing the extension.
if [ -z "$OUTPUT_FILE" ]; then
  OUTPUT_FILE=${1%.*}
fi

# If verbose mode is enabled, print the current configuration using the info color.
if [ "$VERBOSE" == "True" ]; then
  print_info "Arguments being set:"
  print_info "  GDB = ${GDB}"
  print_info "  RUN = ${RUN}"
  print_info "  BREAK = ${BREAK}"
  print_info "  QEMU = ${QEMU}"
  print_info "  Input File = $1"
  print_info "  Output File = $OUTPUT_FILE"
  print_info "  Verbose = $VERBOSE"
  print_info "  64
