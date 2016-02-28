//////////////////////////////////////////////////////////////////////////////////////////
//	FRUSTUM.cpp
//	Functions for frustum
//	Downloaded from: www.paulsprojects.net
//	Created:	8th August 2002
//
//	Copyright (c) 2006, Paul Baker
//	Distributed under the New BSD Licence. (See accompanying file License.txt or copy at
//	http://www.paulsprojects.net/NewBSDLicense.txt)
//////////////////////////////////////////////////////////////////////////////////////////	
#include <windows.h>
#include <GL\gl.h>
#include "LOG.h"
#include "Maths/Maths.h"
#include "FRUSTUM.h"

extern LOG errorLog;

void FRUSTUM::Update()
{
	MATRIX4X4 projection, view;
	MATRIX4X4 clip;

	//get matrices
	glGetFloatv(GL_PROJECTION_MATRIX, projection);
	glGetFloatv(GL_MODELVIEW_MATRIX, view);

	//Multiply the matrices
	clip=projection*view;

	//calculate planes
	planes[RIGHT_PLANE].normal.x=clip.entries[3]-clip.entries[0];
	planes[RIGHT_PLANE].normal.y=clip.entries[7]-clip.entries[4];
	planes[RIGHT_PLANE].normal.z=clip.entries[11]-clip.entries[8];
	planes[RIGHT_PLANE].intercept=clip.entries[15]-clip.entries[12];

	planes[LEFT_PLANE].normal.x=clip.entries[3]+clip.entries[0];
	planes[LEFT_PLANE].normal.y=clip.entries[7]+clip.entries[4];
	planes[LEFT_PLANE].normal.z=clip.entries[11]+clip.entries[8];
	planes[LEFT_PLANE].intercept=clip.entries[15]+clip.entries[12];

	planes[BOTTOM_PLANE].normal.x=clip.entries[3]+clip.entries[1];
	planes[BOTTOM_PLANE].normal.y=clip.entries[7]+clip.entries[5];
	planes[BOTTOM_PLANE].normal.z=clip.entries[11]+clip.entries[9];
	planes[BOTTOM_PLANE].intercept=clip.entries[15]+clip.entries[13];

	planes[TOP_PLANE].normal.x=clip.entries[3]-clip.entries[1];
	planes[TOP_PLANE].normal.y=clip.entries[7]-clip.entries[5];
	planes[TOP_PLANE].normal.z=clip.entries[11]-clip.entries[9];
	planes[TOP_PLANE].intercept=clip.entries[15]-clip.entries[13];

	planes[FAR_PLANE].normal.x=clip.entries[3]-clip.entries[2];
	planes[FAR_PLANE].normal.y=clip.entries[7]-clip.entries[6];
	planes[FAR_PLANE].normal.z=clip.entries[11]-clip.entries[10];
	planes[FAR_PLANE].intercept=clip.entries[15]-clip.entries[14];

	planes[NEAR_PLANE].normal.x=clip.entries[3]+clip.entries[2];
	planes[NEAR_PLANE].normal.y=clip.entries[7]+clip.entries[6];
	planes[NEAR_PLANE].normal.z=clip.entries[11]+clip.entries[10];
	planes[NEAR_PLANE].intercept=clip.entries[15]+clip.entries[14];

	//normalize planes
	for(int i=0; i<6; ++i)
		planes[i].Normalize();
}

//is a point in the frustum?
bool FRUSTUM::IsPointInside(const VECTOR3D & point)
{
	for(int i=0; i<6; ++i)
	{
		if(planes[i].ClassifyPoint(point)==POINT_BEHIND_PLANE)
			return false;
	}

	return true;
}

//is a bounding box in the frustum?
bool FRUSTUM::IsBoundingBoxInside(const VECTOR3D * vertices)
{
	//loop through planes
	for(int i=0; i<6; ++i)
	{
		//if a point is not behind this plane, try next plane
		if(planes[i].ClassifyPoint(vertices[0])!=POINT_BEHIND_PLANE)
			continue;
		if(planes[i].ClassifyPoint(vertices[1])!=POINT_BEHIND_PLANE)
			continue;
		if(planes[i].ClassifyPoint(vertices[2])!=POINT_BEHIND_PLANE)
			continue;
		if(planes[i].ClassifyPoint(vertices[3])!=POINT_BEHIND_PLANE)
			continue;
		if(planes[i].ClassifyPoint(vertices[4])!=POINT_BEHIND_PLANE)
			continue;
		if(planes[i].ClassifyPoint(vertices[5])!=POINT_BEHIND_PLANE)
			continue;
		if(planes[i].ClassifyPoint(vertices[6])!=POINT_BEHIND_PLANE)
			continue;
		if(planes[i].ClassifyPoint(vertices[7])!=POINT_BEHIND_PLANE)
			continue;

		//All vertices of the box are behind this plane
		return false;
	}

	return true;
}
