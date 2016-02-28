 /*
nochump.util.zip.ZipEntry
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
import flash.utils.ByteArray;
/**
* This class represents a member of a zip archive.  ZipFile
* will give you instances of this class as information
* about the members in an archive.  On the other hand ZipOutput
* needs an instance of this class to create a new member.
*
* @author David Chang
*/
class ZipEntry 
{
	// some members are internal as ZipFile will need to set these directly
	// where their accessor does type conversion
	private var _name : String;
	private var _size : Int ;
	private var _compressedSize : Int ;
	private var _crc : UInt;
	/** @private */
	public var dostime : UInt;
	private var _method : Int;
	// compression method
	private var _extra : ByteArray;
	// optional extra field data for entry
	private var _comment : String;
	// optional comment string for entry
	// The following flags are used only by ZipOutput
	/** @private */
	public var flag : Int;
	// bit flags
	/** @private */
	public var version : Int;
	// version needed to extract
	/** @private */
	public var offset : Int;
	// offset of loc header
	public var name(getName, null) : String;
	public var time(getTime, setTime) : Float;
	public var size(getSize, setSize) : UInt;
	public var compressedSize(getCompressedSize, setCompressedSize) : UInt;
	public var crc(getCrc, setCrc) : UInt;
	public var method(getMethod, setMethod) : Int;
	public var extra(getExtra, setExtra) : ByteArray;
	public var comment(getComment, setComment) : String;
	/**
	* Creates a zip entry with the given name.
	* @param name the name. May include directory components separated
	* by '/'.
	*/
	public function new(name : String)
	{
		_size = - 1;
		_compressedSize = - 1;
		_method = - 1;
		_name = name;
	}
	/**
	* Returns the entry name.  The path components in the entry are
	* always separated by slashes('/').
	*/
	public function getName() : String 
	{
		return _name;
	}
	/**
	* Gets the time of last modification of the entry.
	* @return the time of last modification of the entry, or -1 if unknown.
	*/
	public function getTime() : Float 
	{
		var d : Date = new Date(((dostime>> 25) & 0x7f) + 1980,
		((dostime>> 21) & 0x0f) - 1,
		(dostime>> 16) & 0x1f,
		(dostime>> 11) & 0x1f,
		(dostime>> 5) & 0x3f,
		(dostime & 0x1f) <<1);
		return d.getTime();
	}
	/**
	* Sets the time of last modification of the entry.
	* @time the time of last modification of the entry.
	*/
	public function setTime(time : Float) : Float 
	{
		var d : Date = Date.fromTime(time);
		dostime =
		(d.getFullYear() - 1980 & 0x7f) <<25
		|(d.getMonth() + 1) <<21
		| d.getDay() <<16
		| d.getHours() <<11
		| d.getMinutes() <<5
		| d.getSeconds()>> 1;
		return time;
	}
	/**
	* Gets the size of the uncompressed data.
	*/
	public function getSize() : Int 
	{
		return _size;
	}
	/**
	* Sets the size of the uncompressed data.
	*/
	public function setSize(size : Int) : Int 
	{
		_size = size;
		return size;
	}
	/**
	* Gets the size of the compressed data.
	*/
	public function getCompressedSize() : Int 
	{
		return _compressedSize;
	}
	/**
	* Sets the size of the compressed data.
	*/
	public function setCompressedSize(csize : Int) : Int 
	{
		_compressedSize = csize;
		return csize;
	}
	/**
	* Gets the crc of the uncompressed data.
	*/
	public function getCrc() : UInt 
	{
		return _crc;
	}
	/**
	* Sets the crc of the uncompressed data.
	*/
	public function setCrc(crc : UInt) : UInt 
	{
		_crc = crc;
		return crc;
	}
	/**
	* Gets the compression method.
	*/
	public function getMethod() : Int 
	{
		return _method;
	}
	/**
	* Sets the compression method.  Only DEFLATED and STORED are
	* supported.
	*/
	public function setMethod(method : Int) : Int 
	{
		_method = method;
		return method;
	}
	/**
	* Gets the extra data.
	*/
	public function getExtra() : ByteArray 
	{
		return _extra;
	}
	/**
	* Sets the extra data.
	*/
	public function setExtra(extra : ByteArray) : ByteArray 
	{
		_extra = extra;
		return extra;
	}
	/**
	* Gets the extra data.
	*/
	public function getComment() : String 
	{
		return _comment;
	}
	/**
	* Sets the entry comment.
	*/
	public function setComment(comment : String) : String 
	{
		_comment = comment;
		return comment;
	}
	/**
	* Gets true, if the entry is a directory.  This is solely
	* determined by the name, a trailing slash '/' marks a directory.
	*/
	public function isDirectory() : Bool 
	{
		return _name.charAt(_name.length - 1) == '/';
	}
	/**
	* Gets the string representation of this ZipEntry.  This is just
	* the name as returned by name.
	*/
	public function toString() : String 
	{
		return _name;
	}
}
