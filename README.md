# EI332

Collection of labs for EI332 of SJTU

## Presentation

A presentation was given to the class of 2019 about my learning experience of this course. Here is the [link](https://github.com/xushangning/ei332/blob/master/slides.pdf) to the slides.

## How to Use This Repository

If you just want to have a look at the final result, program your board with an SOF file from one of the releases.

This [file](https://github.com/xushangning/ei332/blob/dc8f4a5dfbe5ced70f64fbeab9b5d5910889afb5/five_stage_pipelined_computer/instmem.mif) is also a good place to get started. It contains instructions that test your handling of data and control hazards.

Things get complicated if you really want to compile the sources. Supply your own version of appropriately named RAM and ROM. If you don't bother to use the PLL, remove it from the schematic. Otherwise, add a PLL from the IP Catalog. Finally, add the bdf file to the project's list of files and compile.

The project files (files with extension `.qpf`) are created with Quartus Prime Lite 18.1.

## Files to Include

- Logic design files (`.v`, `.vdh`, `.bdf`, `.edf`, `.vqm`)
- Timing constraint files (`.sdc`)
- Quartus project settings and constraints (`.qdf`, `.qpf`, `.qsf`)
- IP files (`.ip`, `.v`, `.sv`, `.vhd`, `.qip`, `.sip`, `.qsys`)
- Platform Designer (Standard)-generated files (`.qsys`, `.ip`, `.sip`)
- EDA tool files (`.vo`, `.vho`)

Copied from [Intel Quartus Prime Standard Edition User Guide: Getting Started](https://www.intel.com/content/www/us/en/programmable/documentation/yoq1529444104707.html#mwh1409958325703)

## Notes

Some of the files may *NOT* be distributable under the GPL license due to restrictions of the Intel University Program. The author has tried its best to remove such files but omission is unavoidable. **USE AT YOUR OWN DISCRETION!**

Notably, *none* of the files from the IP catalog is included.

## References

- [yyong119/EI332-SourceCode](https://github.com/yyong119/EI332-SourceCode)
- [Elsevier · Patterson, Hennessy: Computer Organization and Design, 5th Edition · MIPS Reference Data (Green Card)](https://booksite.elsevier.com/9780124077263/mips_reference_data.php)
- [Intel Quartus Prime Software User Guides](https://www.intel.com/content/www/us/en/programmable/products/design-software/fpga-design/quartus-prime/user-guides.html)
- [MIPS Converter](https://www.eg.bucknell.edu/~csci320/mips_web/)
