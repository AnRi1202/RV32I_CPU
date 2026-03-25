### Simulation
use cocotb
```
cd tb
make
```

In the Makefile, choose your testfiles.
`$readmemh` expects hex text files, not assembly source.
Fisrt, run `make all` in the top folder, which converts `hoge.s` into `hoge.txt`.

For example, if you want to load `hoge.txt` into the imem and leave dmem empty, write like this:
```
IMEM_FILE = hoge.txt
```
You can also configure `DMEM_FILE = hoge.txt` if you want.

