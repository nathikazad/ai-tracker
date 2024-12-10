from ctypes import *
import os
import numpy as np
from PIL import Image

# Define the structures needed to match the C++ code
class SlicPaletteEntry(Structure):
    _fields_ = [
        ("r", c_uint8),
        ("g", c_uint8),
        ("b", c_uint8)
    ]

class SlicHeader(Structure):
    _fields_ = [
        ("magic", c_uint32),
        ("width", c_uint16),
        ("height", c_uint16),
        ("bpp", c_uint8),
        ("colorspace", c_uint8)
    ]

class SlicFile(Structure):
    _fields_ = [
        ("iPos", c_int32),
        ("iSize", c_int32),
        ("pData", POINTER(c_uint8)),
        ("fHandle", c_void_p)
    ]

class SlicState(Structure):
    _fields_ = [
        ("run", c_int32),
        ("bad_run", c_int32),
        ("width", c_uint16),
        ("height", c_uint16),
        ("iOffset", c_int32),
        ("bpp", c_uint8),
        ("colorspace", c_uint8),
        ("extra_pixel", c_uint8),
        ("prev_op", c_uint8),
        ("pOutBuffer", POINTER(c_uint8)),
        ("pOutPtr", POINTER(c_uint8)),
        ("pInPtr", POINTER(c_uint8)),
        ("pInEnd", POINTER(c_uint8)),
        ("curr_pixel", c_uint32),
        ("prev_pixel", c_uint32),
        ("iPixelCount", c_int32),
        ("iOutSize", c_int32),
        ("pfnRead", c_void_p),
        ("pfnWrite", c_void_p),
        ("index", c_uint32 * 64),
        ("file", SlicFile),
        ("ucFileBuf", c_uint8 * 1024)  # FILE_BUF_SIZE is 1024 for non-AVR
    ]

class SlicDecoder:
    def __init__(self, lib_path="./libslic.so"):
        self.lib = CDLL(lib_path)
        
        # Set up function signatures
        self.lib.slic_init_decode.argtypes = [c_char_p, POINTER(SlicState), POINTER(c_uint8), 
                                            c_int, POINTER(c_uint8), c_void_p, c_void_p]
        self.lib.slic_init_decode.restype = c_int
        
        self.lib.slic_decode.argtypes = [POINTER(SlicState), POINTER(c_uint8), c_int]
        self.lib.slic_decode.restype = c_int

    def decode_file(self, input_file):
        # Read the compressed file
        with open(input_file, 'rb') as f:
            data = f.read()
        
        # Convert to ctypes array
        data_arr = (c_uint8 * len(data))(*data)
        
        # Initialize state
        state = SlicState()
        palette = (c_uint8 * 256)()  # For grayscale, we don't really need this
        
        # Initialize decoder
        result = self.lib.slic_init_decode(None, byref(state), data_arr, len(data), 
                                         palette, None, None)
        
        if result != 0:
            raise RuntimeError(f"Failed to initialize decoder: {result}")
        
        # Calculate output buffer size
        output_size = state.width * state.height * (state.bpp // 8)
        output_buffer = (c_uint8 * output_size)()
        
        # Decode the image
        result = self.lib.slic_decode(byref(state), output_buffer, output_size)
        
        if result != 0 and result != 1:  
            raise RuntimeError(f"Failed to decode image: {result}")
        
        # Convert to numpy array and reshape
        img_array = np.frombuffer(output_buffer, dtype=np.uint8)
        img_array = img_array.reshape((state.height, state.width))
        
        return img_array

def main():
    # Compile the shared library first
    os.system("g++ -shared -fPIC slic.cpp -o libslic.so")
    
    # Create decoder instance
    decoder = SlicDecoder()
    
    # Decode the image
    img = decoder.decode_file("compressed.slic")
    
    # Save the image using PIL
    Image.fromarray(img).save('decompressed.png')
    print(f"Image decoded successfully: {img.shape}")

if __name__ == "__main__":
    main()