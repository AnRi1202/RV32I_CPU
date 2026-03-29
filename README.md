### Simulation
use cocotb
```
make
```
To use Makefile at the top directory, it compiles the `hoge.s` in `tb/hex/` into `hoge.txt`.
```
cd sim
make IMEM_FILE=`../tb/hex/hoge.s`
```
`IMEM_FILE` instanciate the instruction memory state.
You can also configure `DMEM_FILE = hoge.txt` if you want.


### branch
- alu_only: only R_TYPE instructions
- load_store: `alu_only` + load + store
- main: all instructions

