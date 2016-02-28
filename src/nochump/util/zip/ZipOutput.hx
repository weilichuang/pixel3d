 /*
nochump.util.zip.ZipOutput
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

import flash.Error;
import flash.Vector;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.Endian;
class ZipOutput 
{
		private var _entry : ZipEntry;
		private var _entries : Vector<ZipEntry>;
		private var _names : Hash<ZipEntry> ;
		private var _def : Deflater ;
		private var _crc : CRC32 ;
		private var _buf : ByteArray;
		private var _comment : String;
		public function ZipOutput()
		{
			_entries = new Vector<ZipEntry>();
			_names  = new Hash<ZipEntry>();
			_def  = new Deflater();
			_crc  = new CRC32();
			_buf  = new ByteArray();
			_buf.endian = Endian.LITTLE_ENDIAN;
			_comment = "";
		}
		/**
		* Returns the number of entries in this zip file.
		*/
		public function getSize() : UInt 
		{
			return _entries.length;
		}
		/**
		* Returns the byte array of the finished zip.
		*/
		public function getByteArray() : ByteArray 
		{
			_buf.position = 0;
			return _buf;
		}
		/**
		*
		*/
		public function setComment(value : String) : Void 
		{
			_comment = value;
		}
		public function putNextEntry(e : ZipEntry) : Void 
		{
			if(_entry != null) closeEntry();
			// TODO:
			if(e.dostime == 0) e.time = Date.now().getTime();
			if(e.method == - 1) e.method = ZipConstants.DEFLATED;
			// use default method
			switch(e.method)
			{
				case ZipConstants.DEFLATED :
				if(e.size == - 1 || e.compressedSize == - 1 || e.crc == 0)
				{
					// store size, compressed size, and crc-32 in data descriptor
					// immediately following the compressed entry data
					e.flag = 8;
				} else if(e.size != - 1 && e.compressedSize != - 1 && e.crc != 0)
				{
					// store size, compressed size, and crc-32 in LOC header
					e.flag = 0;
				} else 
				{
					throw new ZipError("DEFLATED entry missing size, compressed size, or crc-32");
				}
				e.version = 20;
				case ZipConstants.STORED :
				// compressed size, uncompressed size, and crc-32 must all be
				// set for entries using STORED compression method
				if(e.size == - 1)
				{
					e.size = e.compressedSize;
				} else if(e.compressedSize == - 1)
				{
					e.compressedSize = e.size;
				} else if(e.size != e.compressedSize)
				{
					throw new ZipError("STORED entry where compressed != uncompressed size");
				}
				if(e.size == - 1 || e.crc == 0)
				{
					throw new ZipError("STORED entry missing size, compressed size, or crc-32");
				}
				e.version = 10;
				e.flag = 0;
				default :
				throw new ZipError("unsupported compression method");
			}
			e.offset = _buf.position;
			if(_names.get(e.name) != null)
			{
				throw new ZipError("duplicate entry: " + e.name);
			} else 
			{
				_names.set(e.name,e);
			}
			writeLOC(e);
			_entries.push(e);
			_entry = e;
		}
		public function write(b : ByteArray) : Void 
		{
			if(_entry == null)
			{
				throw new ZipError("no current ZIP entry");
			}
			//*
			switch(_entry.method)
			{
				case ZipConstants.DEFLATED :
				//super.write(b, off, len);
				var cb : ByteArray = new ByteArray();
				_def.setInput(b);
				_def.deflate(cb);
				_buf.writeBytes(cb);
				// TODO: test if Deflater can deflate to the end of _buf(saves from using variable cb and an extra copy)
				case ZipConstants.STORED :
				// TODO:
				//if(written - locoff> _entry.size) {
				//	throw new ZipError("attempt to write past end of STORED entry");
				//}
				//out.write(b, off, len);
				_buf.writeBytes(b);
				default :
				throw new Error("invalid compression method");
			}
			/**/
			_crc.update(b);
		}
		// check if this method is still necessary since we're not dealing with streams
		// seems crc and whether a data descriptor i necessary is determined here
		public function closeEntry() : Void 
		{
			var e : ZipEntry = _entry;
			if(e != null)
			{
				switch(e.method)
				{
					case ZipConstants.DEFLATED :
					if((e.flag & 8) == 0)
					{
						// verify size, compressed size, and crc-32 settings
						if(e.size != _def.getBytesRead())
						{
							throw new ZipError("invalid entry size(expected " + e.size + " but got " + _def.getBytesRead() + " bytes)");
						}
						if(e.compressedSize != _def.getBytesWritten())
						{
							throw new ZipError("invalid entry compressed size(expected " + e.compressedSize + " but got " + _def.getBytesWritten() + " bytes)");
						}
						if(e.crc != _crc.getValue())
						{
							throw new ZipError("invalid entry CRC-32(expected 0x" + e.crc + " but got 0x" + _crc.getValue() + ")");
						}
					} else 
					{
						e.size = _def.getBytesRead();
						e.compressedSize = _def.getBytesWritten();
						e.crc = _crc.getValue();
						writeEXT(e);
					}
					_def.reset();
					case ZipConstants.STORED :
					// TODO:
					default :
					throw new Error("invalid compression method");
				}
				_crc.reset();
				_entry = null;
			}
		}
		public function finish() : Void 
		{
			if(_entry != null) closeEntry();
			if(_entries.length <1) throw new ZipError("ZIP file must have at least one entry");
			var off : UInt = _buf.position;
			// write central directory
			for(i in 0..._entries.length)
			{
				writeCEN(_entries[i]);
			}
			writeEND(off, _buf.position - off);
		}
		private function writeLOC(e : ZipEntry) : Void 
		{
			_buf.writeUnsignedInt(ZipConstants.LOCSIG);
			_buf.writeShort(e.version);
			_buf.writeShort(e.flag);
			_buf.writeShort(e.method);
			_buf.writeUnsignedInt(e.dostime);
			// dostime
			if((e.flag & 8) == 8)
			{
				// store size, uncompressed size, and crc-32 in data descriptor
				// immediately following compressed entry data
				_buf.writeUnsignedInt(0);
				_buf.writeUnsignedInt(0);
				_buf.writeUnsignedInt(0);
			} else 
			{
				_buf.writeUnsignedInt(e.crc);
				// crc-32
				_buf.writeUnsignedInt(e.compressedSize);
				// compressed size
				_buf.writeUnsignedInt(e.size);
				// uncompressed size
				
			}
			_buf.writeShort(e.name.length);
			_buf.writeShort(e.extra != null ? e.extra.length : 0);
			_buf.writeUTFBytes(e.name);
			if(e.extra != null)
			{
				_buf.writeBytes(e.extra);
			}
		}
		/*
		* Writes extra data descriptor(EXT) for specified entry.
		*/
		private function writeEXT(e : ZipEntry) : Void 
		{
			_buf.writeUnsignedInt(ZipConstants.EXTSIG);
			// EXT header signature
			_buf.writeUnsignedInt(e.crc);
			// crc-32
			_buf.writeUnsignedInt(e.compressedSize);
			// compressed size
			_buf.writeUnsignedInt(e.size);
			// uncompressed size
			
		}
		/*
		* Write central directory(CEN) header for specified entry.
		* REMIND: add support for file attributes
		*/
		private function writeCEN(e : ZipEntry) : Void 
		{
			_buf.writeUnsignedInt(ZipConstants.CENSIG);
			// CEN header signature
			_buf.writeShort(e.version);
			// version made by
			_buf.writeShort(e.version);
			// version needed to extract
			_buf.writeShort(e.flag);
			// general purpose bit flag
			_buf.writeShort(e.method);
			// compression method
			_buf.writeUnsignedInt(e.dostime);
			// last modification time
			_buf.writeUnsignedInt(e.crc);
			// crc-32
			_buf.writeUnsignedInt(e.compressedSize);
			// compressed size
			_buf.writeUnsignedInt(e.size);
			// uncompressed size
			_buf.writeShort(e.name.length);
			_buf.writeShort(e.extra != null ? e.extra.length : 0);
			_buf.writeShort(e.comment != null ? e.comment.length : 0);
			_buf.writeShort(0);
			// starting disk number
			_buf.writeShort(0);
			// internal file attributes(unused)
			_buf.writeUnsignedInt(0);
			// external file attributes(unused)
			_buf.writeUnsignedInt(e.offset);
			// relative offset of local header
			_buf.writeUTFBytes(e.name);
			if(e.extra != null)
			{
				_buf.writeBytes(e.extra);
			}
			if(e.comment != null)
			{
				_buf.writeUTFBytes(e.comment);
			}
		}
		/*
		* Writes end of central directory(END) header.
		*/
		private function writeEND(off : UInt, len : UInt) : Void 
		{
			_buf.writeUnsignedInt(ZipConstants.ENDSIG);
			// END record signature
			_buf.writeShort(0);
			// number of this disk
			_buf.writeShort(0);
			// central directory start disk
			_buf.writeShort(_entries.length);
			// number of directory entries on disk
			_buf.writeShort(_entries.length);
			// total number of directory entries
			_buf.writeUnsignedInt(len);
			// length of central directory
			_buf.writeUnsignedInt(off);
			// offset of central directory
			_buf.writeUTF(_comment);
			// zip file comment
			
		}
}
