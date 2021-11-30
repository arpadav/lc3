# arpadav/lc3

Little Computer 3 (LC3) Assembly Projects. Folders labeled `Program[X]` are for ECE109, rest are for fun.

## Instructions
1.  1. Download PennSim from https://www.cis.upenn.edu/~milom/cse240-Fall06/pennsim/pennsim-dist.html
        - Guide: https://www.cis.upenn.edu/~milom/cse240-Fall06/pennsim/pennsim-guide.html
    2. Download the LC3 OS from https://www.cis.upenn.edu/~milom/cse240-Fall06/pennsim/code/lc3os.asm
    3. Save as `lc3os.asm` (or any name, `*.asm`)
    4. Copy `PennSim.jar` within working directory and open. All commands are typed into the command line of PennSim


2.  1. See command list below
    2. Assemble the LC3 OS assembly and load it into PennSim
    3. Assemble all other `.asm` files in directory (if edits have been made, or no `.obj` or `.sym` exist in directory)
    4. Load all `.obj` files
    5. Program should be ready to run, either click Continue or type `continue`

3. Individual program descriptions are in comments of `.asm` files

\
**Loading Commands**
- `as` - assemble LC3 assembly (`.asm`) files
    - Produces object and symbol (`.obj`, `.sym`) files. Object file is binaries. Symbol file is LC3 assembly symbol reference table to be displayed in PennSim. When created, the filename stays consistent to the `.asm` file with only the extension changing. Can be renamed, BUT the `.obj` and `.sym` file MUST have the same filename to denote correspondence
    - *Example:* `as file.asm` &xrarr; `file.obj`, `file.sym` in current directory
- `load` - loads `.obj` binaries into PennSim, using its `.sym` component as a reference
    - *Example:* `load file.obj`

**Other Commands**
- `list` - moves to specified location in memory. Purely visual for debugging purposes (i.e. no change in register or peripheral values)
    - *Example:* `list x3000`
- `reset` - clears PennSim, have to reload object binaries
- `set` - sets a value of specified register
    - LC3 OS begins PC at memory x0200, so a common way to restart program without resetting is `set PC x200`
- `step`, `next`, `continue`, `stop` - does as described. Or can press buttons above command line. Full descriptions in PennSim guide
