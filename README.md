
# Building the Library

Follow these steps to build and install the library:

### 1. Clone the Repository
Clone the repository to your local machine:
```bash
git clone https://github.com/ismaxil/tkDNN-shared-lib.git
```

### 2. Create a Build Directory
Navigate to the cloned directory and generate the Makefile:
```bash
cd tkDNN-shared-lib
mkdir build && cd build
cmake ..
```

### 3. Compile the Code
Build the library using `make`:
```bash
make -j12
```
*Note: Adjust the `-j12` flag based on the number of CPU cores available on your machine for faster compilation.*

### 4. Install the Library
Install the compiled library on your system:
```bash
sudo make install
```

---

### Acknowledgment
This library is based on [tkDNN by ceccocats](https://github.com/ceccocats/tkDNN).
