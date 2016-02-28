//////////////////////////////////////////////////////////////////////////////////////////
//	BSP.h
//	class declaration for quake 3 .bsp file
//	Downloaded from: www.paulsprojects.net
//	Created:	8th August 2002
//
//	Copyright (c) 2006, Paul Baker
//	Distributed under the New BSD Licence. (See accompanying file License.txt or copy at
//	http://www.paulsprojects.net/NewBSDLicense.txt)
//////////////////////////////////////////////////////////////////////////////////////////	

#ifndef BSP_H
#define BSP_H

#include "BITSET.h"
#include "FRUSTUM.h"

//Directory entry in header
class BSP_DIRECTORY_ENTRY
{
public:
	int offset;
	int length;
};

//Types of directory entry
enum BSP_DIRECTORY_ENTRY_TYPE
{
	bspEntities=0,
	bspTextures,
	bspPlanes,
	bspNodes,
	bspLeaves,
	bspLeafFaces,
	bspLeafBrushes,
	bspModels,
	bspBrushes,
	bspBrushSides,
	bspVertices,
	bspMeshIndices,
	bspEffect,
	bspFaces,
	bspLightmaps,
	bspLightVols,
	bspVisData
};

//BSP file header
class BSP_HEADER
{
public:
	char string[4];
	int version;
	BSP_DIRECTORY_ENTRY directoryEntries[17];
};



//vertex as found in file
class BSP_LOAD_VERTEX
{
public:
	VECTOR3D position;
	float decalS, decalT;
	float lightmapS, lightmapT;
	VECTOR3D normal;
	GLubyte color[4];
};
	
//vertex as used for drawing
class BSP_VERTEX
{
public:
	VECTOR3D position;
	float decalS, decalT;
	float lightmapS, lightmapT;

	BSP_VERTEX operator+(const BSP_VERTEX & rhs) const
	{
		BSP_VERTEX result;
		result.position=position+rhs.position;
		result.decalS=decalS+rhs.decalS;
		result.decalT=decalT+rhs.decalT;
		result.lightmapS=lightmapS+rhs.lightmapS;
		result.lightmapT=lightmapT+rhs.lightmapT;

		return result;
	}

	BSP_VERTEX operator*(const float rhs) const
	{
		BSP_VERTEX result;
		result.position=position*rhs;
		result.decalS=decalS*rhs;
		result.decalT=decalT*rhs;
		result.lightmapS=lightmapS*rhs;
		result.lightmapT=lightmapT*rhs;

		return result;
	}
};


//types of faces
enum BSP_FACE_TYPE
{
	bspPolygonFace=1,
	bspPatch,
	bspMeshFace,
	bspBillboard
};

//Stores which type each face is.
//for example, stores face 8 is a polygon face. It is polygonFace[3]
class BSP_FACE_DIRECTORY_ENTRY
{
public:
	BSP_FACE_TYPE faceType;
	int typeFaceNumber;		//face number in the list of faces of this type
};

//face as found in the file
class BSP_LOAD_FACE
{
public:
	int texture;
	int effect;
	int type;
	int firstVertexIndex;
	int numVertices;
	int firstMeshIndex;
	int numMeshIndices;
	int lightmapIndex;
	int lightmapStart[2];
	int lightmapSize[2];
	VECTOR3D lightmapOrigin;
	VECTOR3D sTangent, tTangent;
	VECTOR3D normal;
	int patchSize[2];
};

//polygon face for drawing
class BSP_POLYGON_FACE
{
public:
	int firstVertexIndex;
	int numVertices;
	int textureIndex;
	int lightmapIndex;
};

//mesh face for drawing
class BSP_MESH_FACE
{
public:
	int firstVertexIndex;
	int numVertices;
	int textureIndex;
	int lightmapIndex;
	int firstMeshIndex;
	int numMeshIndices;
};

//every patch (curved surface) is split into biquadratic (3x3) patches
class BSP_BIQUADRATIC_PATCH
{
public:
	bool Tesselate(int newTesselation);
	void Draw();
	
	BSP_VERTEX controlPoints[9];
		
	int tesselation;
	BSP_VERTEX * vertices;
	GLuint * indices;

	//arrays for multi_draw_arrays
	int * trianglesPerRow;
	unsigned int ** rowIndexPointers;

	BSP_BIQUADRATIC_PATCH() : vertices(NULL)
	{}
	~BSP_BIQUADRATIC_PATCH()
	{
		if(vertices)
			delete [] vertices; 
		vertices=NULL;

		if(indices)
			delete [] indices;
		indices=NULL;
	}
};

//curved surface
class BSP_PATCH
{
public:
	int textureIndex;
	int lightmapIndex;
	int width, height;

	int numQuadraticPatches;
	BSP_BIQUADRATIC_PATCH * quadraticPatches;
};

//texture as found in file
class BSP_LOAD_TEXTURE
{
public:
	char name[64];
	int flags, contents;	//unknown
};

//lightmap as found in file
class BSP_LOAD_LIGHTMAP
{
public:
	GLubyte lightmapData[128*128*3];
};


//leaf of bsp tree as found in file
class BSP_LOAD_LEAF
{
public:
	int cluster;	//cluster index for visdata
	int area;		//areaportal area
	int mins[3];	//min x,y,z (bounding box)
	int maxs[3];
	int firstLeafFace;	//first index in leafFaces array
	int numFaces;
	int firstLeafBrush;	//first index into leaf brushes array
	int numBrushes;
};

//leaf of bsp tree as stored
class BSP_LEAF
{
public:
	int cluster;	//cluster index for visdata
	VECTOR3D boundingBoxVertices[8];
	int firstLeafFace;	//first index in leafFaces array
	int numFaces;
};

//node of BSP tree
class BSP_NODE
{
public:
	int planeIndex;
	int front, back;	//child nodes
	int mins[3];	//min x,y,z (bounding box)
	int maxs[3];
};

//VIS data table
class BSP_VISIBILITY_DATA
{
public:
	int numClusters;
	int bytesPerCluster;
	GLubyte * bitset;

	BSP_VISIBILITY_DATA()
	{}
	~BSP_VISIBILITY_DATA()
	{
		if(bitset)
			delete [] bitset;
		bitset=NULL;
	}
};

//main bsp class
class BSP
{
public:
	bool Load(char * filename, int curveTesselation);
	
	int CalculateCameraLeaf(const VECTOR3D & cameraPosition);

	void CalculateVisibleFaces(const VECTOR3D & cameraPosition, FRUSTUM frustum);
	void Draw();
	
	void DrawFace(int faceNumber);

	void DrawPolygonFace(int polygonFaceNumber);
	void DrawMeshFace(int meshFaceNumber);
	void DrawPatch(int patchNumber);


	//header
	BSP_HEADER header;


	//vertices
	int numVertices;
	BSP_VERTEX * vertices;

	bool LoadVertices(FILE * file);



	//faces
	int numTotalFaces;

	BSP_FACE_DIRECTORY_ENTRY * faceDirectory;

	//polygon faces
	int numPolygonFaces;
	BSP_POLYGON_FACE * polygonFaces;

	//mesh faces
	int * meshIndices;
	int numMeshFaces;
	BSP_MESH_FACE * meshFaces;

	//patches
	int numPatches;
	BSP_PATCH * patches;

	BITSET facesToDraw;	//holds which faces need to be drawn

	bool LoadFaces(FILE * file, int curveTesselation);




	//decal textures
	int numTextures;
	//OpenGL identifiers for textures
	GLuint * decalTextures;
	//did the textures load?
	bool * isTextureLoaded;

	bool LoadTextures(FILE * file);



	//lightmaps
	int numLightmaps;
	//OpenGL identifiers for lightmaps
	GLuint * lightmapTextures;
	GLuint whiteTexture;	//used if no lightmap specified

	bool LoadLightmaps(FILE * file);




	//entities
	char * entityString;



	//Leaves
	int numLeaves;
	BSP_LEAF * leaves;
	
	//leaf faces array
	int * leafFaces;

	//Planes for BSP tree
	int numPlanes;
	PLANE * planes;

	//nodes for BSP tree
	int numNodes;
	BSP_NODE * nodes;

	//visibility data
	BSP_VISIBILITY_DATA visibilityData;
	//returns true/false based on if a cluster is visible
	int isClusterVisible(int cameraCluster, int testCluster);

	bool LoadBSPData(FILE * file);


	BSP() : numVertices(0), vertices(NULL),
			numPolygonFaces(0), polygonFaces(NULL),
			numPatches(0), patches(NULL),
			numTextures(0), decalTextures(NULL),
			numLightmaps(0), lightmapTextures(NULL),
			entityString(NULL)
	{}
	~BSP()
	{
		if(vertices)
			delete [] vertices;
		vertices=NULL;

		if(faceDirectory)
			delete [] faceDirectory;
		faceDirectory=NULL;

		if(polygonFaces)
			delete [] polygonFaces;
		polygonFaces=NULL;

		if(meshIndices)
			delete [] meshIndices;
		meshIndices=NULL;

		if(meshFaces)
			delete [] meshFaces;
		meshFaces=NULL;

		if(patches)
			delete [] patches;
		patches=NULL;

		if(decalTextures)
			delete [] decalTextures;
		decalTextures=NULL;

		if(lightmapTextures)
			delete [] lightmapTextures;
		lightmapTextures=NULL;

		if(entityString)
			delete [] entityString;
		entityString=NULL;
	}
};

#endif	//BSP_H
