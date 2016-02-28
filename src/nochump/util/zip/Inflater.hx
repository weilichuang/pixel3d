﻿ /*
nochump.util.zip.Inflater
Copyright(C) 2007 David Chang(dchang@nochump.com)

This file is part of nochump.util.zip.

nochump.util.zip is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

nochump.util.zip is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
*/
package nochump.util.zip;
import flash.Vector;
import flash.Lib;
import flash.Error;
import flash.events.EventDispatcher;
import flash.events.ProgressEvent;
import flash.events.TimerEvent;
import flash.utils.ByteArray;
import flash.utils.Endian;
import flash.utils.Timer;
//[Event(name="entryParseError",	type="nochump.util.zip.ZipErrorEvent")]
//[Event(name="entryParsed",		type="nochump.util.zip.ZipEvent")]
//[Event(name="progress",			type="flash.events.ProgressEvent")]
/**
* Inflater is used to decompress data that has been compressed according
* to the "deflate" standard described in rfc1950.
*
* The usage is as following.  First you have to set some input with
* <code>setInput()</code>, then inflate() it.
*
* This implementation is a port of Puff by Mark Addler that comes with
* the zlip data compression library.  It is not the fastest routine as
* he intended it for learning purposes, his actual optimized inflater code
* is very different.  I went with this approach basically because I got a
* headache looking at the optimized inflater code and porting this
* was a breeze.  The speed should be adequate but there is plenty of room
* for improvements here.
*
* @author dchang
*/
typedef HuffmanCode = {
	var count : Array <Int>;
	var symbol : Array <Int>;
}
class Inflater extends EventDispatcher 
{
	private static inline var MAXBITS : Int = 15;
	// maximum bits in a code
	private static inline var MAXLCODES : Int = 286;
	// maximum number of literal/length codes
	private static inline var MAXDCODES : Int = 30;
	// maximum number of distance codes
	private static inline var MAXCODES : Int = MAXLCODES + MAXDCODES;
	// maximum codes lengths to read
	private static inline var FIXLCODES : Int = 288;
	// number of fixed literal/length codes
	// Size base for length codes 257..285
	private static inline var LENS : Vector<Int>= Lib.vectorOfArray([3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258]);
	// Extra bits for length codes 257..285
	private static inline var LEXT : Vector<Int>= Lib.vectorOfArray([0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0]);
	// Offset base for distance codes 0..29
	private static inline var DISTS : Vector<Int>= Lib.vectorOfArray([1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193, 257, 385, 513, 769, 1025, 1537, 2049, 3073, 4097, 6145, 8193, 12289, 16385, 24577]);
	// Extra bits for distance codes 0..29
	private static inline var DEXT : Vector<Int>= Lib.vectorOfArray([0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13]);
	// Duration between parsing of each chunk of data
	private static inline var TIMER_INTERVAL : Int = 20;
	private var inbuf : ByteArray;
	// input buffer
	private var currentBuf : ByteArray;
	// current buffer being decoded
	private var incnt : UInt;
	// bytes read so far
	private var bitbuf : Int;
	// bit buffer
	private var bitcnt : Int;
	// number of bits in bit buffer
	// Huffman code decoding tables
	private var lencode : HuffmanCode;
	private var distcode : HuffmanCode;
	private var inflateTimer : Timer;
	public function new()
	{
		super();
	}
	/**
	* Sets the input.
	*
	* @param buf the input.
	*/
	public function setInput(buf : ByteArray) : Void 
	{
		inbuf = buf;
		inbuf.endian = Endian.LITTLE_ENDIAN;
		if(inflateTimer != null)
		{
			inflateTimer.stop();
			inflateTimer.removeEventListener(TimerEvent.TIMER, inflateNextChunk);
		}
		inflateTimer = new Timer(TIMER_INTERVAL);
		inflateTimer.addEventListener(TimerEvent.TIMER, inflateNextChunk);
	}
	/**
	* Inflates the compressed stream to the output buffer.
	*
	* @param buf the output buffer.
	*/
	public function inflate(buf : ByteArray) : UInt 
	{
		incnt = bitbuf = bitcnt = 0;
		var err : Int = 0;
		var last : Int;
		do 
		{
			// process blocks until last block or error
			last = bits(1);
			// one if last block
			var type : Int = bits(2);
			// block type 0..3
			//trace('	block type ' + type);
			if(type == 0)
			{
				stored(buf);
				// uncompressed block
				
			} else if(type == 3)
			{
				throw new Error('invalid block type(type == 3)', - 1);
			} else 
			{
				// compressed block
				lencode = {
					count :[] , symbol :[]
				};
				distcode = {
					count :[] , symbol :[]
				};
				if(type == 1)
				{
					constructFixedTables();
				} else if(type == 2)
				{
					err = constructDynamicTables();
				}
				if(err != 0)
				{
					return err;
				}
				err = codes(buf);
				// decode data until end-of-block code
				
			}
			if(err != 0)
			{
				break;
				// return with error
				
			}
		} while(last == 0);
		return err;
	}
	
	public function queuedInflate(buf : ByteArray) : Void 
	{
		incnt = bitbuf = bitcnt = 0;
		currentBuf = buf;
		inflateTimer.start();
	}
	private function inflateNextChunk(event : TimerEvent) : Void 
	{
		var err : Int = 0;
		var last : Int = bits(1);
		// one if last block
		var type : Int = bits(2);
		// block type 0..3
		//trace('	block type ' + type);
		if(type == 0)
		{
			stored(currentBuf);
			// uncompressed block
			
		} else if(type == 3)
		{
			throw new Error('invalid block type(type == 3)', - 1);
		} else 
		{
			// compressed block
			lencode = {
				count :[] , symbol :[]
			};
			distcode = {
				count :[] , symbol :[]
			};
			if(type == 1)
			{
				constructFixedTables();
			} else if(type == 2)
			{
				err = constructDynamicTables();
			}
			if(err != 0)
			{
				inflateTimer.stop();
				dispatchEvent(new ZipErrorEvent(ZipErrorEvent.PARSE_ERROR, false, false, err));
			}
			err = codes(currentBuf);
			// decode data until end-of-block code
			
		}
		if(err != 0)
		{
			inflateTimer.stop();
			dispatchEvent(new ZipErrorEvent(ZipErrorEvent.PARSE_ERROR, false, false, err));
		}
		if(last != 0)
		{
			inflateTimer.stop();
			dispatchEvent(new ZipEvent(ZipEvent.ENTRY_PARSED, false, false, currentBuf));
		}
		dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, incnt, currentBuf.length));
	}
	
	private function bits(need : Int) : Int 
	{
		// bit accumulator(can use up to 20 bits)
		// load at least need bits into val
		var val : Int = bitbuf;
		while(bitcnt <need)
		{
			if(incnt == inbuf.length)
			{
				throw new Error('available inflate data did not terminate', 2);
			}
			val |= inbuf[incnt ++] <<bitcnt;
			// load eight bits
			bitcnt += 8;
		}
		// drop need bits and update buffer, always zero to seven bits left
		bitbuf = val>> need;
		bitcnt -= need;
		// return need bits, zeroing the bits above that
		return val &((1 <<need) - 1);
	}
	
	private function construct(h : HuffmanCode, length : Array <Int>, n : Int) : Int 
	{
		var offs : Array <Int>= new Array <Int>();
		// offsets in symbol table for each length
		// count number of codes of each length
		for(len in 0...(MAXBITS + 1))
		{
			h.count[len] = 0;
		}
		// assumes lengths are within bounds
		for(symbol in 0...n)
		{
			h.count[length[symbol]] ++;
		}
		// no codes! complete, but decode() will fail
		if(h.count[0] == n)
		{
			return 0;
		}
		// check for an over-subscribed or incomplete set of lengths
		var left : Int = 1;
		// one possible code of zero length
		for(len in 1...(MAXBITS + 1))
		{
			left <<= 1;
			// one more bit, double codes left
			left -= h.count[len];
			// deduct count from possible codes
			if(left <0)
			{
				return left;
				// over-subscribed--return negative
				
			}
		} // left> 0 means incomplete
		// generate offsets into symbol table for each length for sorting
		offs[1] = 0;
		for(len in 1...(MAXBITS + 1))
		{
			offs[len + 1] = offs[len] + h.count[len];
		}
		// put symbols in table sorted by length, by symbol order within each length
		for(symbol in 0...n)
		{
			if(length[symbol] != 0)
			{
				h.symbol[offs[length[symbol]] ++] = symbol;
			}
		}
		// return zero for complete set, positive for incomplete set
		return left;
	}
	private function decode(h : HuffmanCode) : Int 
	{
		var code : Int = 0;
		// len bits being decoded
		var first : Int = 0;
		// first code of length len
		var index : Int = 0;
		// index of first code of length len in symbol table
		for(len in 1...(MAXBITS + 1))
		{
			// current number of bits in code
			code |= bits(1);
			// get next bit
			var count : Int = h.count[len];
			// number of codes of length len
			// if length len, return symbol
			if(code <first + count)
			{
				return h.symbol[index +(code - first)];
			}
			index += count;
			// else update for next length
			first += count;
			first <<= 1;
			code <<= 1;
		}
		return - 9;
		// ran out of codes
		
	}
	private function codes(buf : ByteArray) : Int 
	{
		// decode literals and length/distance pairs
		var symbol : Int;
		do 
		{
			symbol = decode(lencode);
			if(symbol <0)
			{
				return symbol;
				// invalid symbol
				
			}
			if(symbol <256)
			{
				buf[buf.length] = symbol;
				// literal: symbol is the byte
				
			} else if(symbol> 256)
			{
				// length
				// get and compute length
				symbol -= 257;
				if(symbol>= 29)
				{
					throw new Error("invalid literal/length or distance code in fixed or dynamic block", - 9);
				}
				var len : Int = LENS[symbol] + bits(LEXT[symbol]);
				// length for copy
				// get and check distance
				symbol = decode(distcode);
				if(symbol <0)
				{
					return symbol;
					// invalid symbol
					
				}
				var dist : UInt = DISTS[symbol] + bits(DEXT[symbol]);
				// distance for copy
				if(dist> buf.length)
				{
					throw new Error("distance is too far back in fixed or dynamic block", - 10);
				}
				// copy length bytes from distance bytes back
				while((len --) != 0)
				{
					buf[buf.length] = buf[buf.length - dist];
				}
			}
		} while(symbol != 256);
		// end of block symbol
		return 0;
		// done with a valid fixed or dynamic block
		
	}
	private function stored(buf : ByteArray) : Void 
	{
		// discard leftover bits from current byte(assumes s->bitcnt <8)
		bitbuf = 0;
		bitcnt = 0;
		// get length and check against its one's complement
		if(incnt + 4> inbuf.length)
		{
			throw new Error('available inflate data did not terminate', 2);
		}
		var len : UInt = inbuf[incnt ++];
		// length of stored block
		len |= inbuf[incnt ++] <<8;
		if(inbuf[incnt ++] !=(~len & 0xff) || inbuf[incnt ++] !=((~len>> 8) & 0xff))
		{
			throw new Error("stored block length did not match one's complement", - 2);
		}
		if(incnt + len> inbuf.length)
		{
			throw new Error('available inflate data did not terminate', 2);
		} 
		while((len --) != 0)
		{
			buf[buf.length] = inbuf[incnt ++];
			// copy len bytes from in to out
			
		}
	}
	private function constructFixedTables() : Void 
	{
		var lengths : Array <Int>= new Array <Int>();
		// literal/length table
		var symbol : Int = 0;
		while(symbol <144)
		{
			lengths[symbol] = 8;
			symbol ++;
		} 
		while(symbol <256)
		{
			lengths[symbol] = 9;
			symbol ++;
		} 
		while(symbol <280)
		{
			lengths[symbol] = 7;
			symbol ++;
		} 
		while(symbol <FIXLCODES)
		{
			lengths[symbol] = 8;
			symbol ++;
		}
		construct(lencode, lengths, FIXLCODES);
		// distance table
		for(symbol in 0...MAXDCODES)
		{
			lengths[symbol] = 5;
		}
		construct(distcode, lengths, MAXDCODES);
	}
	private function constructDynamicTables() : Int 
	{
		var lengths : Array <Int>= new Array <Int>();
		// descriptor code lengths
		// permutation of code length codes
		var order : Vector<Int>= Lib.vectorOfArray([16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15]);
		// get number of lengths in each table, check lengths
		var nlen : Int = bits(5) + 257;
		var ndist : Int = bits(5) + 1;
		var ncode : Int = bits(4) + 4;
		// number of lengths in descriptor
		if(nlen> MAXLCODES || ndist> MAXDCODES)
		{
			throw new Error("dynamic block code description: too many length or distance codes", - 3);
		}
		// read code length code lengths(really), missing lengths are zero
		var index : Int = 0;
		while(index <ncode)
		{
			//for(var index:Int = 0; index <ncode; index++) {
			lengths[order[index]] = bits(3);
			index ++;
		} 
		while(index <19)
		{
			//for(; index <19; index++) {
			lengths[order[index]] = 0;
			index ++;
		}
		// build huffman table for code lengths codes(use lencode temporarily)
		var err : Int = construct(lencode, lengths, 19);
		if(err != 0)
		{
			throw new Error("dynamic block code description: code lengths codes incomplete", - 4);
		}
		// read length/literal and distance code length tables
		index = 0;
		while(index <nlen + ndist)
		{
			var symbol : Int;
			// decoded value
			var len : Int;
			// last length to repeat
			symbol = decode(lencode);
			if(symbol <16)
			{
				lengths[index ++] = symbol;
				// length in 0..15
				
			} else 
			{
				// repeat instruction
				len = 0;
				// assume repeating zeros
				if(symbol == 16)
				{
					// repeat last length 3..6 times
					if(index == 0)
					{
						throw new Error("dynamic block code description: repeat lengths with no first length", - 5);
					}
					len = lengths[index - 1];
					// last length
					symbol = 3 + bits(2);
				} else if(symbol == 17)
				{
					symbol = 3 + bits(3);
					// repeat zero 3..10 times
					
				} else 
				{
					symbol = 11 + bits(7);
					// == 18, repeat zero 11..138 times
					
				}
				if(index + symbol> nlen + ndist)
				{
					throw new Error("dynamic block code description: repeat more than specified lengths", - 6);
				} 
				while((symbol --) != 0)
				{
					lengths[index ++] = len;
					// repeat last or zero symbol times
					
				}
			}
		}
		// build huffman table for literal/length codes
		err = construct(lencode, lengths, nlen);
		// only allow incomplete codes if just one code
		if(err <0 ||(err> 0 && nlen - lencode.count[0] != 1))
		{
			throw new Error("dynamic block code description: invalid literal/length code lengths", - 7);
		}
		// build huffman table for distance codes
		err = construct(distcode, lengths.slice(nlen) , ndist);
		// only allow incomplete codes if just one code
		if(err <0 ||(err> 0 && ndist - distcode.count[0] != 1))
		{
			throw new Error("dynamic block code description: invalid distance code lengths", - 8);
		}
		return err;
	}
}
