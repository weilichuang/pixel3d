 /*
nochump.util.zip.ZipConstants
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
class ZipConstants 
{
	/* The local file header */
	public static inline var LOCSIG : UInt = 0x04034b50;
	// "PK\003\004"
	public static inline var LOCHDR : UInt = 30;
	// LOC header size
	public static inline var LOCVER : UInt = 4;
	// version needed to extract
	//public static inline var LOCFLG:UInt = 6; // general purpose bit flag
	//public static inline var LOCHOW:UInt = 8; // compression method
	//public static inline var LOCTIM:UInt = 10; // modification time
	//public static inline var LOCCRC:UInt = 14; // uncompressed file crc-32 value
	//public static inline var LOCSIZ:UInt = 18; // compressed size
	//public static inline var LOCLEN:UInt = 22; // uncompressed size
	public static inline var LOCNAM : UInt = 26;
	// filename length
	//public static inline var LOCEXT:UInt = 28; // extra field length
	/* The Data descriptor */
	public static inline var EXTSIG : UInt = 0x08074b50;
	// "PK\007\008"
	public static inline var EXTHDR : UInt = 16;
	// EXT header size
	//public static inline var EXTCRC:UInt = 4; // uncompressed file crc-32 value
	//public static inline var EXTSIZ:UInt = 8; // compressed size
	//public static inline var EXTLEN:UInt = 12; // uncompressed size
	/* The central directory file header */
	public static inline var CENSIG : UInt = 0x02014b50;
	// "PK\001\002"
	public static inline var CENHDR : UInt = 46;
	// CEN header size
	//public static inline var CENVEM:UInt = 4; // version made by
	public static inline var CENVER : UInt = 6;
	// version needed to extract
	//public static inline var CENFLG:UInt = 8; // encrypt, decrypt flags
	//public static inline var CENHOW:UInt = 10; // compression method
	//public static inline var CENTIM:UInt = 12; // modification time
	//public static inline var CENCRC:UInt = 16; // uncompressed file crc-32 value
	//public static inline var CENSIZ:UInt = 20; // compressed size
	//public static inline var CENLEN:UInt = 24; // uncompressed size
	public static inline var CENNAM : UInt = 28;
	// filename length
	//public static inline var CENEXT:UInt = 30; // extra field length
	//public static inline var CENCOM:UInt = 32; // comment length
	//public static inline var CENDSK:UInt = 34; // disk number start
	//public static inline var CENATT:UInt = 36; // internal file attributes
	//public static inline var CENATX:UInt = 38; // external file attributes
	public static inline var CENOFF : UInt = 42;
	// LOC header offset
	/* The entries in the end of central directory */
	public static inline var ENDSIG : UInt = 0x06054b50;
	// "PK\005\006"
	public static inline var ENDHDR : UInt = 22;
	// END header size
	//public static inline var ENDSUB:UInt = 8; // number of entries on this disk
	public static inline var ENDTOT : UInt = 10;
	// total number of entries
	//public static inline var ENDSIZ:UInt = 12; // central directory size in bytes
	public static inline var ENDOFF : UInt = 16;
	// offset of first CEN header
	//public static inline var ENDCOM:UInt = 20; // zip file comment length
	/* Compression methods */
	public static inline var STORED : UInt = 0;
	public static inline var DEFLATED : UInt = 8;
}
