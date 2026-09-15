"""
Optimized Pyflate BitStream Decoder
This module simulates the core bottleneck of the Pyflate benchmark (bzip2/gzip decoding).
The original Pyflate reads data bit-by-bit from a stream, which in pure Python involves
many method calls and arithmetic operations per bit.
Our optimization caches bytes in a 64-bit integer buffer and uses bitwise operations 
to extract bits rapidly, minimizing the per-bit overhead.
"""

class OptimizedBitStream:
    def __init__(self, data):
        # We assume data is bytes or bytearray
        self.data = data
        self.pos = 0
        self.bit_buffer = 0
        self.bits_in_buffer = 0
        self.length = len(data)

    def read_bits(self, n):
        """
        Reads n bits from the stream.
        Optimized by shifting from a local integer buffer rather than
        array indexing for every single bit.
        """
        while self.bits_in_buffer < n:
            if self.pos >= self.length:
                raise EOFError("Unexpected end of stream")
            # Load next byte into the buffer
            self.bit_buffer |= (self.data[self.pos] << self.bits_in_buffer)
            self.pos += 1
            self.bits_in_buffer += 8

        # Extract n bits
        mask = (1 << n) - 1
        result = self.bit_buffer & mask
        
        # Shift the buffer
        self.bit_buffer >>= n
        self.bits_in_buffer -= n
        
        return result

def decompress_simulation(data):
    """
    Simulates a decompression workload.
    """
    stream = OptimizedBitStream(data)
    decoded_values = []
    
    try:
        # Simulate decoding 1 million 5-bit symbols
        for _ in range(1000000):
            val = stream.read_bits(5)
            decoded_values.append(val)
    except EOFError:
        pass
        
    return len(decoded_values)

def main():
    # Generate dummy compressed data (random bytes)
    # Using a deterministic pattern for benchmark repeatability
    data = bytearray((i % 256) for i in range(1024 * 1024))
    
    # Run the decompression
    decompress_simulation(data)

if __name__ == '__main__':
    main()
