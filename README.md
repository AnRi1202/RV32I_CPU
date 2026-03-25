### Simulation
use cocotb
```
cd tb
make
```

In the Makefile, choose your testfiles.
`$readmemh` expects hex text files, not assembly source.
For example, if you want to load `hoge.txt` into the imem and leave dmem empty, write like this:
```
IMEM_FILE = hoge.txt
DMEM_FILE =
```
