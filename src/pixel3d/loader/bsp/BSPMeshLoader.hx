package pixel3d.loader.bsp;
import flash.display.BitmapData;
import flash.events.TimerEvent;
import flash.geom.Vector3D;
import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.Vector;
import pixel3d.events.MeshEvent;
import pixel3d.events.MeshProgressEvent;
import pixel3d.loader.MeshLoader;
import pixel3d.material.LoadingTexture;
import pixel3d.material.Texture;
import pixel3d.math.Plane3D;
import pixel3d.math.Vertex;
import pixel3d.mesh.MeshBuffer;
import pixel3d.mesh.Q3LevelMesh;
import pixel3d.utils.BitmapDataUtil;
import pixel3d.utils.Logger;

class BSPMeshLoader extends MeshLoader
{
	private var bspTextures : Vector<BSPTexture>;
	private var textures : Vector<LoadingTexture>;
	private var numTextures : Int;
	
	private var lightMaps : Vector<Texture>;
	private var numLightMaps : Int;
	
	private var vertices : Vector<Vertex>;
	private var numVertices : Int;

	// The vertex offsets for a mesh
	private var meshIndices : Vector<Int>;
	private var numMeshIndices : Int;

	private var levelMesh : Q3LevelMesh;
	
	private var lumps : Vector<BSPLump>;

	private var bspName:String;
	private var folder:String;
	private var bspData:ByteArray;
	
	private var currentStep:Int;
	private var timer:Timer;
	
	private var loaderInfo:String;
	
	private var curveTessellation:Int;
	
	private var useLightmap:Bool;
	
	private var bezier:BSPBezier;

	private var gamma:Float;

	public function new(folder:String,curveTessellation:Int=3,lightmap:Bool=true,gamma:Float = 2.5)
	{
		super(MeshLoader.STATIC_MESH);
		
		this.folder = folder;
		this.curveTessellation = curveTessellation;
		this.useLightmap = lightmap;
		//Change the gamma settings on the lightmaps (make them brighter)
		this.gamma = gamma / 255;
		
		bezier = new BSPBezier();
	}
 
	override public function loadBytes(data:ByteArray, type:Int):Void
	{
		this.bspData = data;
		if(type != 0)
		{
			dispatchEvent(new MeshEvent(MeshEvent.COMPLETE, null));
		}
		else
		{
			currentStep = 0;
			timer = new Timer(100);
			timer.addEventListener(TimerEvent.TIMER, __timer);
			timer.start();
		}
	}

	public function getLoaderInfo():String
	{
		return loaderInfo;
	}
	
	public function setLoaderInfo(info:String):Void
	{
		loaderInfo = info;
		
		#if debug
		    Logger.log(loaderInfo);
		#end
	}
	
	private function __timer(e:TimerEvent):Void
	{
		switch(currentStep)
		{
			case 0:
			      readHeader();
				  setLoaderInfo("read bsp header");
				  dispatchEvent(new MeshProgressEvent(MeshProgressEvent.PROGRESS, this.loaderInfo));
			case 1:
			      loadTexture(lumps[LUMPS.Textures]);
				  setLoaderInfo("loadTexture");
				  dispatchEvent(new MeshProgressEvent(MeshProgressEvent.PROGRESS, this.loaderInfo));
			case 2:
			      if(useLightmap)
				  {
					loadLightmaps(lumps[LUMPS.Lightmaps]);
				    setLoaderInfo("loadLightmaps");
				    dispatchEvent(new MeshProgressEvent(MeshProgressEvent.PROGRESS, this.loaderInfo));  
				  }
			case 3:
			      loadVertices(lumps[LUMPS.Vertices]);
				  setLoaderInfo("loadVertices");
				  dispatchEvent(new MeshProgressEvent(MeshProgressEvent.PROGRESS, this.loaderInfo));
			case 4:
			      loadFaces(lumps[LUMPS.Faces]);
				  setLoaderInfo("loadFaces");
				  dispatchEvent(new MeshProgressEvent(MeshProgressEvent.PROGRESS, this.loaderInfo));
			case 5:
			      loadPlanes(lumps[LUMPS.Planes]);
				  setLoaderInfo("loadPlanes");
				  dispatchEvent(new MeshProgressEvent(MeshProgressEvent.PROGRESS, this.loaderInfo));
			case 6:
			      loadNodes(lumps[LUMPS.Nodes]);
				  setLoaderInfo("loadNodes");
				  dispatchEvent(new MeshProgressEvent(MeshProgressEvent.PROGRESS, this.loaderInfo));
			case 7:
			      loadLeafs(lumps[LUMPS.Leafs]);
				  setLoaderInfo("loadLeafs");
				  dispatchEvent(new MeshProgressEvent(MeshProgressEvent.PROGRESS, this.loaderInfo));
			case 8:
			      loadLeafFaces(lumps[LUMPS.LeafFaces]);
				  setLoaderInfo("loadLeafFaces");
				  dispatchEvent(new MeshProgressEvent(MeshProgressEvent.PROGRESS, this.loaderInfo));
			case 9:
			      loadVisData(lumps[LUMPS.VisData]);
				  setLoaderInfo("loadVisData");
				  dispatchEvent(new MeshProgressEvent(MeshProgressEvent.PROGRESS, this.loaderInfo));
			case 10:
			       loadEntities(lumps[LUMPS.Entities]);
			       setLoaderInfo("loadEntities");
				   dispatchEvent(new MeshProgressEvent(MeshProgressEvent.PROGRESS, this.loaderInfo));
			//case 11:
			      //loadModels(lumps[LUMPS.Models]);
				  //setLoaderInfo("loadModels");
				  //dispatchEvent(new MeshProgressEvent(MeshProgressEvent.PROGRESS, this.loaderInfo));
			case 12:
			      loadMeshIndices(lumps[LUMPS.MeshIndices]);
				  setLoaderInfo("loadMeshVerts");
				  dispatchEvent(new MeshProgressEvent(MeshProgressEvent.PROGRESS, this.loaderInfo));
			//case 13:
			      //loadBrushes(lumps[LUMPS.Brushes]);
				  //setLoaderInfo("loadBrushes");
				  //dispatchEvent(new MeshProgressEvent(MeshProgressEvent.PROGRESS, this.loaderInfo));
			//case 14:
			      //loadBrushSides(lumps[LUMPS.BrushSides]);
				  //setLoaderInfo("loadBrushSides");
				  //dispatchEvent(new MeshProgressEvent(MeshProgressEvent.PROGRESS, this.loaderInfo));
			//case 15:
			      //loadLeafBrushes(lumps[LUMPS.LeafBrushes]);
				  //setLoaderInfo("loadLeafBrushes");
				  //dispatchEvent(new MeshProgressEvent(MeshProgressEvent.PROGRESS, this.loaderInfo));
			case 16:
			      createPolygon();
				  setLoaderInfo("createPolygon");
				  dispatchEvent(new MeshProgressEvent(MeshProgressEvent.PROGRESS, this.loaderInfo));
			case 17:
			      createMesh();
				  setLoaderInfo("createMesh");
				  dispatchEvent(new MeshProgressEvent(MeshProgressEvent.PROGRESS, this.loaderInfo));
			case 18:
			      createPatch();
				  setLoaderInfo("createPatch");
				  dispatchEvent(new MeshProgressEvent(MeshProgressEvent.PROGRESS, this.loaderInfo));
			//case 19:
			      //createBillboard();
				  //setLoaderInfo("createBillboard");
				  //dispatchEvent(new MeshProgressEvent(MeshProgressEvent.PROGRESS, this.loaderInfo));
			case 20:
			      cleanup();
				  dispatchEvent(new MeshEvent(MeshEvent.COMPLETE, levelMesh));
		}
		currentStep++;
	}
	
	private function readHeader() : Void
	{
		levelMesh = new Q3LevelMesh();
		
		bspData.position = 0;
		
		// Read the Header This should always be 'IBSP' & be 0x2e for Quake 3 files
		if(bspData.readInt() != 0x50534249 || bspData.readInt() != 0x2E)
		{
			loaderInfo = "Load bsp file error";
			Logger.log(loaderInfo, Logger.ERROR);
			__loadError();
			return;
		}
		
		// now read the header lumps
		lumps = new Vector<BSPLump>(LUMPS.MaxLumps,true);
		for(i in 0...LUMPS.MaxLumps)
		{
			var lump : BSPLump = new BSPLump();
			lump.offset = bspData.readInt();
		    lump.length = bspData.readInt();
			lumps[i] = lump;
		}
	}
	
	private function cleanup() : Void
	{
		removeListener();
		if(timer != null)
		{
			timer.removeEventListener(TimerEvent.TIMER, __timer);
			timer.stop();
			timer = null;
		}
		lumps = null;
		bspTextures = null;
		textures = null;
		lightMaps = null;
		vertices = null;
		meshIndices = null;
	}
    
	/**
	 * 读取贴图
	 * @param	lump
	 */
	//TODO 加载图片那块不应该放在这里，应该单独写个函数
	//还有就是需要写一个加载序列，不应该一次性加载所有图片，而应该顺序加载，一次加载3到4张
	private function loadTexture(lump : BSPLump) : Void
	{
		numTextures = Std.int(lump.length / 72);// BSPTexture.sizeof);
		bspTextures = new Vector<BSPTexture>();
		
		textures = new Vector<LoadingTexture>();
		
		bspData.position = lump.offset;
		var texture : LoadingTexture;
		var bspTexture:BSPTexture;
		for(i in 0...numTextures)
		{
			bspTexture = new BSPTexture();
			bspTexture.name = bspData.readUTFBytes(64);
			bspTexture.flags = bspData.readUnsignedInt();
			bspTexture.contents = bspData.readUnsignedInt();
			bspTextures[i] = bspTexture;
			
			var not_visible:Bool = false;
			if((bspTexture.flags & BSPTexture.SURF_SKY) == BSPTexture.SURF_SKY)
		    {
		        not_visible = true;
		    }
			
		    // check no draw
		    if((bspTexture.flags & BSPTexture.SURF_NODRAW) == BSPTexture.SURF_NODRAW)
		    {
		        not_visible = true;
		    }
			
		    // check hint
		    if((bspTexture.flags & BSPTexture.SURF_HINT) == BSPTexture.SURF_HINT)
		    {
		        not_visible = true;
		    }
			
		    // check skip
		    if((bspTexture.flags & BSPTexture.SURF_SKIP) == BSPTexture.SURF_SKIP)
		    {
		        not_visible = true;
		    }
			
		    // check transparent
		    //if(bspTexture.contents == BSPTexture.CONTENTS_TRANSLUCENT)
		    //{
		        //not_visible = true;
		    //}
			
		    if(bspTexture.name == "noshader" || bspTexture.name == "flareShader")
		    {
		        not_visible = true;
		    }
			
			//部分图片不加载
			if(not_visible)
			{
				textures[i] = null;
			}
			else
			{
				texture = new LoadingTexture();
				texture.setName(bspTexture.name);
				texture.loadFile(folder + texture.getName() + ".jpg");
				textures[i] = texture;
			}
		}
	}
    
	/**
	 * 加载光照图
	 * @param	lump
	 */
	private function loadLightmaps(lump : BSPLump) : Void
	{
		numLightMaps = Std.int(lump.length /(128*128*3));
		lightMaps = new Vector<Texture>();
		
		bspData.position = lump.offset;
		var bitmapData:BitmapData = new BitmapData(128, 128, true, 0x0);

		for(i in 0...numLightMaps)
		{
			var lightTexture : Texture = new Texture();
			var vec:Vector<UInt>=new Vector<UInt>(16384,true);
			for(i in 0...16384)
			{
				// get rgb and brighter
				var r : Float = bspData.readUnsignedByte() * gamma;
				var g : Float = bspData.readUnsignedByte() * gamma;
				var b : Float = bspData.readUnsignedByte() * gamma;

				//find the value to scale back up
				var scale:Float = 1.0;
				var temp:Float = 0.0;
				if(r> 1.0 && (temp =(1.0 / r)) < scale) scale = temp;
				if(g> 1.0 && (temp =(1.0 / g)) < scale) scale = temp;
				if(b> 1.0 && (temp =(1.0 / b)) < scale) scale = temp;

				// scale up color values
				scale *= 255.0;		
				r *= scale;
				g *= scale;
				b *= scale;
				
				vec[i] =(0xFF000000 | Std.int(r) <<16 | Std.int(g) <<8 | Std.int(b));
			}
			
			//放大光照图，这样调和之后效果更好一些，否则原来的都会有一块一块的感觉
			bitmapData.setVector(bitmapData.rect, vec);
			var data:BitmapData = BitmapDataUtil.scale(bitmapData, 2.0, true, 0x0);
			lightTexture.setVector(data.getVector(data.rect), 256, 256);
			data.dispose();
			data = null;
			
			lightMaps[i] = lightTexture;
		}
		bitmapData.dispose();
		bitmapData = null;
	}
	
	/**
	 * 加载顶点数据
	 * @param	lump
	 */
	private function loadVertices(lump : BSPLump) : Void
	{ 
		//(3+2+2+3)*4+1*4=44;
		numVertices = Std.int(lump.length / 44);
		vertices = new Vector<Vertex>();
		
		bspData.position = lump.offset;
		for(i in 0...numVertices)
		{
			var vx : Vertex = new Vertex();
			
			//(x, y, z) position. f32[3];
			vx.x = bspData.readFloat();
			vx.z = bspData.readFloat();
			vx.y = bspData.readFloat();

			//(u, v) texture coordinate     f32[2];
			vx.u = bspData.readFloat();
			vx.v = bspData.readFloat();

			//(u, v) lightmap coordinate f32[2];
			vx.u2 = bspData.readFloat();
			vx.v2 = bspData.readFloat();
			
			//(x, y, z) normal vector f32[3];
			vx.nx = bspData.readFloat();
			vx.nz = bspData.readFloat();
			vx.ny = bspData.readFloat();
			
			// RGBA color for the vertex   u8[4];
			vx.r = bspData.readUnsignedByte();//r
			vx.g = bspData.readUnsignedByte();//g
			vx.b = bspData.readUnsignedByte();//b
			vx.a = bspData.readUnsignedByte();//a
			
			vertices[i] = vx;
		}
	}
	
	/**
	 * 
	 * @param	lump
	 */
	private function loadFaces(lump : BSPLump) : Void
	{
		levelMesh.numFaces = Std.int(lump.length / BSPFace.sizeof);
		levelMesh.faces = new Vector<BSPFace>();
		
		levelMesh.facesToDraw = new BitSet(levelMesh.numFaces);
		
		bspData.position = lump.offset;
		for(i in 0...levelMesh.numFaces)
		{
			var face : BSPFace = new BSPFace();
			face.textureID = bspData.readInt();//贴图id
			face.fogNum = bspData.readInt();//
			face.type = bspData.readInt();//
			face.firstVertexIndex = bspData.readInt();//
			face.numVertices = bspData.readInt();//顶点数
			face.firstMeshIndex = bspData.readInt();//
			face.numMeshIndices = bspData.readInt();//
			face.lightmapID = bspData.readInt();//光照图id

			bspData.position += 16 * 4;
			//face.lMapCorner0 = bspData.readInt();
			//face.lMapCorner1 = bspData.readInt();
			//face.lMapSize0 = bspData.readInt();
			//face.lMapSize1 = bspData.readInt();
			//face.lMapPos0 = bspData.readFloat();
			//face.lMapPos1 = bspData.readFloat();
			//face.lMapPos2 = bspData.readFloat();
			//face.lMapBitsets00 = bspData.readFloat();
			//face.lMapBitsets01 = bspData.readFloat();
			//face.lMapBitsets02 = bspData.readFloat();
			//face.lMapBitsets10 = bspData.readFloat();
			//face.lMapBitsets11 = bspData.readFloat();
			//face.lMapBitsets12 = bspData.readFloat();
			//face.vNormal0 = bspData.readFloat();
			//face.vNormal1 = bspData.readFloat();
			//face.vNormal2 = bspData.readFloat();

			face.width = bspData.readInt();
			face.height = bspData.readInt();
			
			levelMesh.faces[i] = face;
		}
		
		levelMesh.faces.fixed = true;
	}
	
	/**
	* Loads the planes, we convert straight to Plane3D objects
	*/
	private function loadPlanes(lump : BSPLump) : Void
	{
		levelMesh.numPlanes = Std.int(lump.length / 16);
		levelMesh.planes = new Vector<Plane3D>();
		
		bspData.position = lump.offset;
		
		// plane data is packed as follows
		// Plane normal[3](f32)
		// The plane distance from origin(f32)
		// get planes
		for(i in 0...levelMesh.numPlanes)
		{
			var x : Float = bspData.readFloat();
			var y : Float = bspData.readFloat();
			var z : Float = bspData.readFloat();
			var d : Float = bspData.readFloat();
			levelMesh.planes[i] = new Plane3D(new Vector3D(x, z, y) , d);//y,z需要调整一下
		}
		levelMesh.planes.fixed = true;
	}
	
	private function loadNodes(lump : BSPLump) : Void
	{
		levelMesh.numNodes = Std.int(lump.length / BSPNode.sizeof);
		levelMesh.nodes = new Vector<BSPNode>();
		
		bspData.position = lump.offset;
		for(i in 0...levelMesh.numNodes)
		{
			var node : BSPNode = new BSPNode();
			// The index into the planes array
			node.plane = bspData.readInt();
			
			// The child index for the front node
			node.front = bspData.readInt();
			
			// The child index for the back node
			node.back = bspData.readInt();
			
			// The bounding box min position.[3]:Int;
			node.boundingBox.minX = bspData.readInt();
			node.boundingBox.minZ = bspData.readInt();
			node.boundingBox.minY = bspData.readInt();
			// The bounding box max position.[3]:Int;
			node.boundingBox.maxX = bspData.readInt();
			node.boundingBox.maxZ = bspData.readInt();
			node.boundingBox.maxY = bspData.readInt();
			
			levelMesh.nodes[i] = node;
		}
		levelMesh.nodes.fixed = true;
	}
	
	/**
	 * Loads the leaves
	 */
	private function loadLeafs(lump : BSPLump) : Void
	{
		levelMesh.numLeafs = Std.int(lump.length / BSPLeaf.sizeof);
		levelMesh.leafs = new Vector<BSPLeaf>(levelMesh.numLeafs,true);
		
		bspData.position = lump.offset;
		for(i in 0...levelMesh.numLeafs)
		{
			var leaf : BSPLeaf = new BSPLeaf();

			leaf.cluster = bspData.readInt();
			leaf.area = bspData.readInt();
			
			// The bounding box min position[3]:Int;
			leaf.boundingBox.minX = bspData.readInt();
			leaf.boundingBox.minZ = bspData.readInt();
			leaf.boundingBox.minY = bspData.readInt();
			
			// The bounding box max position[3]:Int;
			leaf.boundingBox.maxX = bspData.readInt();
			leaf.boundingBox.maxZ = bspData.readInt();
			leaf.boundingBox.maxY = bspData.readInt();
		
			leaf.firstLeafFace = bspData.readInt();
			leaf.numFaces = bspData.readInt();
			leaf.firstLeafBrush = bspData.readInt();
			leaf.numBrushes = bspData.readInt();
			
			levelMesh.leafs[i] = leaf;
		}
	}

	private function loadLeafFaces(lump : BSPLump) : Void
	{
		levelMesh.numLeafFaces = Std.int(lump.length / 4);
		levelMesh.leafFaces = new Vector<Int>(levelMesh.numLeafFaces,true);
		
		bspData.position = lump.offset;
		for(i in 0...levelMesh.numLeafFaces)
		{
			levelMesh.leafFaces[i] = bspData.readInt();
		}
	}
	
	private function loadVisData(lump : BSPLump) : Void
	{
		bspData.position = lump.offset;
		levelMesh.visData = new BSPVisData();
		
		if (lump.length > 0)
		{
			levelMesh.visData.numClusters = bspData.readInt();
			levelMesh.visData.bytesPerCluster = bspData.readInt();

			var bits : ByteArray = new ByteArray();
			bits.endian = bspData.endian;
			bspData.readBytes(bits, 0, lump.length - 8);// subtract the above
			
			// load into array
			var len : Int = bits.length;
			levelMesh.visData.bitsets = new Array<Int>();
			for(i in 0...len)
			{
				levelMesh.visData.bitsets[i] = bits[i];
			}
			bits.clear();
			bits = null;
		}
	}
	
	/**
	*  function: loadEntities
	*  Entities are stored as text in the following format
	* 	{
	* 	"classname" "light"
	* 	"light" "125"
	* 	"_color" "0.75 0.5 0.25"
	* 	"origin" "1920 1344 290"
	* 	}
	*
	*/
	private function loadEntities(lump : BSPLump) : Void
	{
		levelMesh.entities = new Vector<BSPEntity>();
		
		// check length
		if(lump.length == 0)
		{
			levelMesh.entities.length = 0;
			levelMesh.numEntities = 0;
			return;
		}
		
		levelMesh.numEntities = 0;
		// seek to offset
		bspData.position = lump.offset;
		
		// read entity data into string
		var entity_data : String = bspData.readUTFBytes(lump.length);
		
		#if debug
		    Logger.log("entity_data =" + entity_data);
		#end
		
		if (entity_data.length < 1) return;

		// parse entity data
		var open_bracket : Int = entity_data.indexOf("{", 0);
		var closed_bracket : Int = entity_data.indexOf("}", 0);

		// entity data is seperated by closed brackets {}
		while (open_bracket > - 1 && closed_bracket > - 1)
		{
			// read between the brackets
			var entity_content : String = untyped entity_data.substring(open_bracket + 1, closed_bracket);
			
			// check length
			if (entity_content.length > 0)
			{
				// make new entity
				var entity : BSPEntity = new BSPEntity();
				
				levelMesh.entities[levelMesh.numEntities] = entity;
				
				levelMesh.numEntities ++;
				
				// data is seperated by closed quote marks ""
				// "classname" "light"
				var data_info : Bool = true;
				var data_prop : String = "";
				var quote_start : Int = entity_content.indexOf('\"', 0);
				var quote_end : Int = entity_content.indexOf('\"', quote_start + 1);
				while (quote_start > - 1 && quote_end > 0)
				{
					var msg_data : String = untyped entity_content.substring(quote_start + 1, quote_end);
					if (data_info)
					{
						// heading
						data_prop = msg_data;
					} 
					else 
					{
						// origin
						if(data_prop == "origin")
						{
							var positions : Array<String> = msg_data.split(" ");
							if(positions.length == 3)
							{
								
								var pos:Vector3D = new Vector3D(Std.parseFloat(positions[0]), 
								                              Std.parseFloat(positions[2]), 
															  Std.parseFloat(positions[1]));
							    untyped entity[data_prop] = pos;
						        
							}
						}
						else if (data_prop == "classname")
						{
							untyped entity[data_prop] = msg_data;
							
							#if debug
		    					Logger.log("data_prop =" + msg_data);
							#end
						}
						else
						{
							untyped entity[data_prop] = msg_data;
						}
					}
					data_info = ! data_info;
					quote_start = entity_content.indexOf('\"', quote_end + 1);
					quote_end = entity_content.indexOf('\"', quote_start + 1);
				}
			}
			open_bracket = entity_data.indexOf("{", closed_bracket + 1);
			closed_bracket = entity_data.indexOf("}", closed_bracket + 1);
		}
		
		levelMesh.defalutPositions = new Vector<Vector3D>();
		//store all info_player_deathmatch position
		for (i in 0...levelMesh.numEntities)
		{
			var entity : BSPEntity = levelMesh.entities[i];
			if (entity.classname == "info_player_deathmatch")
			{
				levelMesh.defalutPositions.push(entity.origin);
				
				#if debug
				Logger.log("info_player_deathmatch " + "origin = " + entity.origin);
				#end
			}
		}
	}

	private function loadMeshIndices(lump : BSPLump) : Void
	{
		numMeshIndices = Std.int(lump.length / 4);
		
		meshIndices = new Vector<Int>(numMeshIndices,true);
		
		bspData.position = lump.offset;
		for(i in 0...numMeshIndices)
		{
			meshIndices[i] = bspData.readInt();
		}
	}
	
	//private function loadModels(lump : BSPLump) : Void
	//{
		//numModels = Std.int(lump.length / BSPModel.sizeof);
		//models = new Vector<BSPModel>();
		//
		//bspData.position = lump.offset;
		//for(i in 0...numModels)
		//{
			//var model : BSPModel = new BSPModel();
			//model.boundingBox.minX = bspData.readFloat();
			//model.boundingBox.minZ = bspData.readFloat();
			//model.boundingBox.minY = bspData.readFloat();
			//model.boundingBox.maxX = bspData.readFloat();
			//model.boundingBox.maxZ = bspData.readFloat();
			//model.boundingBox.maxY = bspData.readFloat();
			//model.faceIndex = bspData.readInt();
			//model.numOfFaces = bspData.readInt();
			//model.brushIndex = bspData.readInt();
			//model.numOfBrushes = bspData.readInt();
			//models[i] = model;
		//}
	//}
	
	//private function loadBrushes(lump : BSPLump) : Void
	//{
		//numBrushes = Std.int(lump.length / BSPBrush.sizeof);
		//brushes = new Vector<BSPBrush>();
		//
		//bspData.position = lump.offset;
		//for(i in 0...numBrushes)
		//{
			//var brush : BSPBrush = new BSPBrush();
			//brush.firstBrushSide = bspData.readInt();
			//brush.numBrushSides = bspData.readInt();
			//brush.textureID = bspData.readInt();
			//brushes[i] = brush;
		//}
	//}
	
	//private function loadBrushSides(lump : BSPLump) : Void
	//{
		//numBrusheSides = Std.int(lump.length / BSPBrushSide.sizeof);
		//brusheSides = new Vector<BSPBrushSide>();
		//
		//bspData.position = lump.offset;
		//for(i in 0...numBrusheSides)
		//{
			//var brushSide : BSPBrushSide = new BSPBrushSide();
			//brushSide.plane = bspData.readInt();
			//brushSide.textureID = bspData.readInt();
			//brusheSides[i] = brushSide;
		//}
	//}
	
	//private function loadLeafBrushes(lump : BSPLump) : Void
	//{
		//numLeafBrushes = Std.int(lump.length / 4);
		//leafBrushes = new Vector<Int>();
		//
		//bspData.position = lump.offset;
		//for(i in 0...numLeafBrushes)
		//{
			//leafBrushes[i] = bspData.readInt();
		//}
	//}
	
	private function createPolygon() : Void
	{
		var buffers : Vector<MeshBuffer>= levelMesh.getMeshBuffers();
		for(i in 0...levelMesh.numFaces)
		{
			var face : BSPFace = levelMesh.faces[i];
			if(face.type != BSPFace.POLYGON_FACE)
			{
				continue;
			}

			if(face.lightmapID> numLightMaps - 1)
			{
				face.lightmapID = - 1;
			}
			
			//如果是天空，则不添加
			if(face.textureID> -1)
			{
				if((bspTextures[face.textureID].flags & BSPTexture.SURF_SKY) == BSPTexture.SURF_SKY)
				{
					continue;
				}
			}
			
			var buffer : MeshBuffer = new MeshBuffer();
			
			buffer.material.gouraudShading = true;
			buffer.material.isPowOfTow = true;
			
			if(face.textureID >= 0)
			{
				buffer.material.setTexture(textures[face.textureID],1);
			}
			
			if(face.lightmapID >= 0 && useLightmap)
			{
				buffer.material.setTexture(lightMaps[face.lightmapID], 2);
			}

			var buffer_indices : Vector<Int> = buffer.getIndices();
			var buffer_vertices : Vector<Vertex> = buffer.getVertices();

			var vertex:Vertex;
			for(j in 0...face.numMeshIndices)
			{
				vertex = vertices[meshIndices[(face.firstMeshIndex + j)] + face.firstVertexIndex];
				buffer_vertices.push(vertex);
				buffer_indices.push(j);
			}

			buffer.recalculateBoundingBox();
			buffers.push(buffer);
			
			face.buffer = buffer;
		}
	}

	private function createMesh():Void
	{
		var buffers : Vector<MeshBuffer> = levelMesh.getMeshBuffers();
		
		for(i in 0...levelMesh.numFaces)
		{
			var face : BSPFace = levelMesh.faces[i];
			if(face.type != BSPFace.MESH_FACE)
			{
				continue;
			}

			if(face.lightmapID > numLightMaps - 1)
			{
				face.lightmapID = - 1;
			}
			
			//如果是天空，则不添加
			if(face.textureID > -1)
			{
				if((bspTextures[face.textureID].flags & BSPTexture.SURF_SKY) == BSPTexture.SURF_SKY)
				{
					continue;
				}
			}

			var buffer : MeshBuffer = new MeshBuffer();

			buffer.material.gouraudShading = true;
			buffer.material.isPowOfTow = true;
			
			if(face.textureID >= 0)
			{
			//	buffer.material.setTexture(textures[face.textureID],1);
			}
			
			if(face.lightmapID >= 0 && useLightmap)
			{
			//	buffer.material.setTexture(lightMaps[face.lightmapID], 2);
			}

			var buffer_indices : Vector<Int>= buffer.getIndices();
			var buffer_vertices : Vector<Vertex>= buffer.getVertices();
            
			//TODO ????????什么意思
			for(j in 0...face.numMeshIndices)
			{
				buffer_indices.push(meshIndices[j+face.firstMeshIndex]);
			}

			var vertex:Vertex;
			for(j in 0...face.numVertices)
			{
				vertex = vertices[j + face.firstVertexIndex];
				buffer_vertices.push(vertex);
			}

			buffer.recalculateBoundingBox();
			buffers.push(buffer);

			face.buffer = buffer;
		}
	}
	
	private function createPatch():Void
	{
		var buffers : Vector<MeshBuffer>= levelMesh.getMeshBuffers();

		for(i in 0...levelMesh.numFaces)
		{
			var face : BSPFace = levelMesh.faces[i];
			if(face.type != BSPFace.PATCH_FACE)
			{
				continue;
			}
			
			if(face.width == 0 || face.height == 0)
			{
				continue;
			}

			if(face.lightmapID > numLightMaps - 1)
			{
				face.lightmapID = - 1;
			}
			
			var buffer : MeshBuffer = new MeshBuffer();

			buffer.material.gouraudShading = true;
			buffer.material.isPowOfTow = true;
			
			if(face.textureID >= 0)
			{
				buffer.material.setTexture(textures[face.textureID],1);
			}
			
			if(face.lightmapID >= 0 && useLightmap)
			{
				buffer.material.setTexture(lightMaps[face.lightmapID], 2);
			}

			// number of biquadratic patches
			var biquadWidth = Math.round((face.width - 1) / 2);
			var biquadHeight = Math.round((face.height - 1) / 2);

			var len :Int = face.width * face.height;
			var controlPoints:Vector<Vertex> = new Vector<Vertex>(len, true);
			for(j in 0...len)
			{
				controlPoints[j] = vertices[face.firstVertexIndex + j];
			}
			
			bezier.meshBuffer = buffer;
			//Loop through the biquadratic patches
        	for( j in 0...biquadHeight)
	    	{
		    	for( k in 0...biquadWidth)
		    	{
			    	// set up this patch
			    	var inx:Int = j * face.width * 2 + k * 2;

			    	// setup bezier control points for this patch
			    	bezier.control[0] = controlPoints[inx + 0];
			    	bezier.control[1] = controlPoints[inx + 1];
			    	bezier.control[2] = controlPoints[inx + 2];
			    	bezier.control[3] = controlPoints[inx + face.width + 0 ];
			    	bezier.control[4] = controlPoints[inx + face.width + 1 ];
			    	bezier.control[5] = controlPoints[inx + face.width + 2 ];
			    	bezier.control[6] = controlPoints[inx + face.width * 2 + 0];
			    	bezier.control[7] = controlPoints[inx + face.width * 2 + 1];
			    	bezier.control[8] = controlPoints[inx + face.width * 2 + 2];

			    	bezier.tesselate(this.curveTessellation);
		    	}
	    	}
		
			buffer.recalculateBoundingBox();
			buffers.push(buffer);

			face.buffer = buffer;
		}
	}
	
	//private function createBillboard():Void
	//{
		
	//}
}

class LUMPS
{
	public static inline var Entities     : Int = 0;// Stores player/object positions, etc...
	public static inline var Textures     : Int = 1;// Stores texture information
	public static inline var Planes       : Int = 2;// Stores the splitting planes
	public static inline var Nodes        : Int = 3;// Stores the BSP nodes
	public static inline var Leafs        : Int = 4;// Stores the leafs of the nodes
	public static inline var LeafFaces    : Int = 5;// Stores the leaf's indices into the faces
	public static inline var LeafBrushes  : Int = 6;// Stores the leaf's indices into the brushes
	public static inline var Models       : Int = 7;// Stores the info of world models
	public static inline var Brushes      : Int = 8;// Stores the brushes info(for collision)
	public static inline var BrushSides   : Int = 9;// Stores the brush surfaces info
	public static inline var Vertices     : Int = 10;// Stores the level vertices
	public static inline var MeshIndices  : Int = 11;// Stores the model vertices offsets
	public static inline var Shaders      : Int = 12;// Stores the shader files(blend(ing, anims..)
	public static inline var Faces        : Int = 13;// Stores the faces for the level
	public static inline var Lightmaps    : Int = 14;// Stores the lightmaps for the level
	public static inline var LightVolumes : Int = 15;// Stores extra world lighting information
	public static inline var VisData      : Int = 16;// Stores PVS and cluster info(visibility)
	public static inline var MaxLumps     : Int = 17;// A constant to store the Float of lumps
}

class BSPLump
{
	public var offset : Int;
	public var length : Int;
	public function new()
	{
	}
}