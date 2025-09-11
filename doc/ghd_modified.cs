using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GunstarCompression {
    class Decompressor {
		private byte[] decompressionBuffer;
		private int decompressionBufferCursor;

		private List<byte> outputData;

		private byte[] inputData;
		private int inputCursor;

		private ushort bitsToProcess;
		private int numValidBits;

		private ushort d4;
		private ushort d5;
        private ushort d6;

		private int iterationCount;

		public Decompressor() {
			decompressionBuffer = new byte[256];
			outputData = new List<byte>();
		}

        public byte[] GetOutput() {
            return outputData.ToArray();
        }

        public void Decompress(byte[] inputData) {
            this.inputData = inputData;

            inputCursor = 0;
            decompressionBufferCursor = 0;

            d4 = 0;
            d5 = 0;

            outputData.Clear();

            // Initial prep
            int numDecompressSteps = inputData[0];

            bitsToProcess = (ushort)(((ushort)inputData[1]) << 8);
            numValidBits = 8;
            inputCursor += 2;

            for (int i = 0; i < numDecompressSteps; i++) {
                decompressionBufferCursor = 0;
                do {
                    DecompressStep();
                } while (decompressionBufferCursor < 128);

                PrintDecompressionBuffer(i);
                CompactToOutput();
            }
        }

		private void DecompressStep() {
			// ---- Top Prep ----
			// Read the next data chunk of 5 bits
			ushort dataChunk = ReadBits(5);

            bool isLsbSet = (dataChunk & 0x1) > 0;
            dataChunk = (ushort)((dataChunk >> 1) & 0xF);
			if (isLsbSet) {
                // Write nibble then do inner loop
                byte output = (byte)dataChunk;
                WriteAndIncrement(output);

                d4 = output;
                d5 = (ushort)(output | 0x8000);
                d6 = 0; // write offset
                // Inner Loop
                while (true) {
                    // Process next two bits from the stream
					ushort bitPair = ReadBits(2);
                    // After inner branch
                    if (bitPair == 0) {
                        // inner continues
                        ushort tst = ReadBits(1);
                        if (tst == 0) break;

                        tst = ReadBits(1);
                        if (tst == 1) {
                            // write ahead method 3
                            d6 += 20;
                            WriteWordAtOffset(d5, d6 - 1);
                        } else {
                            // write ahead method 2
                          	d6 += 12;
                            WriteWordAtOffset(d5, d6-2);
                        }
                    } else {
                        // write ahead method 1
                        ushort inc = (ushort)((bitPair + 6) * 2);
                        d6 += inc;
                        // D5 probably has hi bit set at this point
                        WriteWordAtOffset(d5, d6-2);
                    }
                }
			} else {
				// lower bit clear
				// Direct byte write
				byte output = (byte)dataChunk;
				WriteAndIncrement(output);

				d4 = output;
				d5 = (ushort)(output | 0x8000);
			}
			// ---- Shunt Loop ----
			int runLength = 0;
			int runMultiplier = 1;

			while (true) {
				runLength++;
				runMultiplier *= 2;

				ushort data = ReadBits(1);
				if (data == 0)
				{
					// Found end of run
					break;
				}
			}
			// ---- Prep For Write (After Shunt Loop) ----
			ushort workingBits = ReadBits(runLength);

            int loopAmount = (runMultiplier + workingBits) - 3;
            loopAmount += 1;
			// ---- Write Loop ----
            if (loopAmount > 0)
			{
                // todo: do we need to add one to the runMultiplier because of how the asm handles it's loop counter check at the end of the loop?
                for (int i = 0; i < loopAmount; i++) {
					ushort d7 = (ushort)((decompressionBuffer[decompressionBufferCursor] << 8)
										| decompressionBuffer[decompressionBufferCursor+1]);
					if ((d7 & 0x8000) > 0) {
						d5 = d7;
						d4 = (ushort)(d5 & 0xF); // just take data nibble, clear bit 15
					}
					WriteAndIncrement((byte)d4);
				}
			}

			iterationCount++;
		}

		private ushort ReadBits(int numRequiredBits) {
			ushort mask = CreateBitMask(numRequiredBits);

			ushort output;
			if (numValidBits > numRequiredBits) {
				output = (ushort)((bitsToProcess >> (16-numRequiredBits)) & mask);
				bitsToProcess = (ushort)(bitsToProcess << numRequiredBits);
				numValidBits -= numRequiredBits;
			} else if (numValidBits == numRequiredBits) {
				// Extract required bits
				output = (ushort)((bitsToProcess >> (16 - numRequiredBits)) & mask);

				// Read in next word to process
				bitsToProcess = (ushort)((inputData[inputCursor] << 8) | inputData[inputCursor + 1]);
				inputCursor += 2;
				numValidBits = 16;
			} else { // less that X bits to proccess
                // TODO: Do we need to create upper and lower masks?
                // upper is something like 00000011111100
                // lower is something like 00000000000011
                // otherwise we might get wrong data mixed in with our output because it's not masked properly
                ushort upperMask = CreateBitMask(numValidBits);
				
				// First gather remaining bits
				output = (ushort)((bitsToProcess >> (16 - numRequiredBits)) & mask);
				int numOustandingBits = numRequiredBits - numValidBits;
				// Read in next word to process
				bitsToProcess = (ushort)((inputData[inputCursor] << 8) | inputData[inputCursor + 1]);
				inputCursor += 2;
				numValidBits = 16;
				// And extract the outstanding bits
				output |= (ushort)((bitsToProcess >> (16 - numOustandingBits)) & mask);
                bitsToProcess = (ushort)(bitsToProcess << numOustandingBits);
				numValidBits -= numOustandingBits;
			}
			return output;
		}

		private static ushort CreateBitMask(int numBits) {
			ushort mask = 0;
			for (int i = 0; i < numBits; i++)
				mask |= (ushort)(1 << i);
			return mask;
		}

		private void WriteAndIncrement(ushort value) {
			this.decompressionBuffer[decompressionBufferCursor++] = (byte)((value >> 8) & 0xFF);
			this.decompressionBuffer[decompressionBufferCursor++] = (byte)((value & 0xFF));
		}

        private void WriteWordAtOffset(ushort value, int offset) {
            byte lo = (byte)(value & 0xFF);
            byte hi = (byte)((value >> 8) & 0xFF);

            this.decompressionBuffer[decompressionBufferCursor + offset]     = hi;
            this.decompressionBuffer[decompressionBufferCursor + offset + 1] = lo;
        }

		private void CompactToOutput() {
			int cursorPos = 0;

			for (int i = 0; i < 32; i++) {
				byte hi = (byte)((ReadDecompressedWord(ref cursorPos) & 0xF) << 4);
				byte lo = (byte)((ReadDecompressedWord(ref cursorPos) & 0xF) << 0);

				byte value = (byte)(hi | lo);
				outputData.Add(value); 
			}
		}

		private ushort ReadDecompressedWord(ref int cursorPos) {
			byte hi = decompressionBuffer[cursorPos];
			byte lo = decompressionBuffer[cursorPos + 1];

			cursorPos += 2;

			return (ushort)((hi << 8) | lo);
		}

		private void PrintDecompressionBuffer(int stepNum) {
			Console.Out.WriteLine(string.Format("Decompression buffer: (step {0})", stepNum));
			int pos = 0;
			for (int y = 0; y < 8; y++) {
                string rawBytes = string.Format("  {0}{1} {2}{3} {4}{5} {6}{7} {8}{9} {10}{11} {12}{13} {14}{15}",
					decompressionBuffer[pos]    .ToString("X2"),
					decompressionBuffer[pos + 1].ToString("X2"),
					decompressionBuffer[pos + 2].ToString("X2"),
					decompressionBuffer[pos + 3].ToString("X2"),
					decompressionBuffer[pos + 4].ToString("X2"),
					decompressionBuffer[pos + 5].ToString("X2"),
					decompressionBuffer[pos + 6].ToString("X2"),
                    decompressionBuffer[pos + 7].ToString("X2"),
                    decompressionBuffer[pos + 8].ToString("X2"),
                    decompressionBuffer[pos + 9].ToString("X2"),
                    decompressionBuffer[pos +10].ToString("X2"),
                    decompressionBuffer[pos +11].ToString("X2"),
                    decompressionBuffer[pos +12].ToString("X2"),
                    decompressionBuffer[pos +13].ToString("X2"),
                    decompressionBuffer[pos +14].ToString("X2"),
                    decompressionBuffer[pos +15].ToString("X2"));

                string nibbles = string.Format("{0} {1} {2} {3} {4} {5} {6} {7}",
                    PrettyFormatNibble(decompressionBuffer[pos + 1]),
                    PrettyFormatNibble(decompressionBuffer[pos + 3]),
                    PrettyFormatNibble(decompressionBuffer[pos + 5]),
                    PrettyFormatNibble(decompressionBuffer[pos + 7]),
                    PrettyFormatNibble(decompressionBuffer[pos + 9]),
                    PrettyFormatNibble(decompressionBuffer[pos +11]),
                    PrettyFormatNibble(decompressionBuffer[pos +13]),
                    PrettyFormatNibble(decompressionBuffer[pos +15]) );
                Console.Out.WriteLine(rawBytes + " " + nibbles);

				pos += 16;
			}
		}

        private static string PrettyFormatNibble(byte value) {
            if (value == 0) return ".";
            return value.ToString("X1");
        }
	}
}
