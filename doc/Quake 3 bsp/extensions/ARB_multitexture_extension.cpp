//////////////////////////////////////////////////////////////////////////////////////////
//	ARB_multitexture_extension.cpp
//	ARB_multitexture extension setup
//	Downloaded from: www.paulsprojects.net
//	Created:	20th July 2002
//
//	Copyright (c) 2006, Paul Baker
//	Distributed under the New BSD Licence. (See accompanying file License.txt or copy at
//	http://www.paulsprojects.net/NewBSDLicense.txt)
//////////////////////////////////////////////////////////////////////////////////////////	
#include <windows.h>
#include <GL\gl.h>
#include <GL\glext.h>
#include <GL\wglext.h>
#include "../LOG.h"
#include "ARB_multitexture_extension.h"

extern LOG errorLog;

bool ARB_multitexture_supported=false;

bool SetUpARB_multitexture()
{
	//Check for support
	char * extensionString=(char *)glGetString(GL_EXTENSIONS);
	char * extensionName="GL_ARB_multitexture";

	char * endOfString;									//store pointer to end of string
	unsigned int distanceToSpace;						//distance to next space

	endOfString=extensionString+strlen(extensionString);

	//loop through string
	while(extensionString<endOfString)
	{
		//find distance to next space
		distanceToSpace=strcspn(extensionString, " ");

		//see if we have found extensionName
		if((strlen(extensionName)==distanceToSpace) &&
			(strncmp(extensionName, extensionString, distanceToSpace)==0))
		{
			ARB_multitexture_supported=true;
		}

		//if not, move on
		extensionString+=distanceToSpace+1;
	}
	
	if(!ARB_multitexture_supported)
	{
		errorLog.OutputError("ARB_multitexture unsupported!");
		return false;
	}

	errorLog.OutputSuccess("ARB_multitexture supported!");

	//get function pointers
	glActiveTextureARB			=	(PFNGLACTIVETEXTUREARBPROC)
									wglGetProcAddress("glActiveTextureARB");
	glClientActiveTextureARB	=	(PFNGLCLIENTACTIVETEXTUREARBPROC)
									wglGetProcAddress("glClientActiveTextureARB");
	glMultiTexCoord1dARB		=	(PFNGLMULTITEXCOORD1DARBPROC)
									wglGetProcAddress("glMultiTexCoord1dARB");
	glMultiTexCoord1dvARB		=	(PFNGLMULTITEXCOORD1DVARBPROC)
									wglGetProcAddress("glMultiTexCoord1dvARB");
	glMultiTexCoord1fARB		=	(PFNGLMULTITEXCOORD1FARBPROC)
									wglGetProcAddress("glMultiTexCoord1fARB");
	glMultiTexCoord1fvARB		=	(PFNGLMULTITEXCOORD1FVARBPROC)
									wglGetProcAddress("glMultiTexCoord1fvARB");
	glMultiTexCoord1iARB		=	(PFNGLMULTITEXCOORD1IARBPROC)
									wglGetProcAddress("glMultiTexCoord1iARB");
	glMultiTexCoord1ivARB		=	(PFNGLMULTITEXCOORD1IVARBPROC)
									wglGetProcAddress("glMultiTexCoord1ivARB");
	glMultiTexCoord1sARB		=	(PFNGLMULTITEXCOORD1SARBPROC)
									wglGetProcAddress("glMultiTexCoord1sARB");
	glMultiTexCoord1svARB		=	(PFNGLMULTITEXCOORD1SVARBPROC)
									wglGetProcAddress("glMultiTexCoord1svARB");
	glMultiTexCoord2dARB		=	(PFNGLMULTITEXCOORD2DARBPROC)
									wglGetProcAddress("glMultiTexCoord2dARB");
	glMultiTexCoord2dvARB		=	(PFNGLMULTITEXCOORD2DVARBPROC)
									wglGetProcAddress("glMultiTexCoord2dvARB");
	glMultiTexCoord2fARB		=	(PFNGLMULTITEXCOORD2FARBPROC)
									wglGetProcAddress("glMultiTexCoord2fARB");
	glMultiTexCoord2fvARB		=	(PFNGLMULTITEXCOORD2FVARBPROC)
									wglGetProcAddress("glMultiTexCoord2fvARB");
	glMultiTexCoord2iARB		=	(PFNGLMULTITEXCOORD2IARBPROC)
									wglGetProcAddress("glMultiTexCoord2iARB");
	glMultiTexCoord2ivARB		=	(PFNGLMULTITEXCOORD2IVARBPROC)
									wglGetProcAddress("glMultiTexCoord2ivARB");
	glMultiTexCoord2sARB		=	(PFNGLMULTITEXCOORD2SARBPROC)
									wglGetProcAddress("glMultiTexCoord2sARB");
	glMultiTexCoord2svARB		=	(PFNGLMULTITEXCOORD2SVARBPROC)
									wglGetProcAddress("glMultiTexCoord2svARB");
	glMultiTexCoord3dARB		=	(PFNGLMULTITEXCOORD3DARBPROC)
									wglGetProcAddress("glMultiTexCoord3dARB");
	glMultiTexCoord3dvARB		=	(PFNGLMULTITEXCOORD3DVARBPROC)
									wglGetProcAddress("glMultiTexCoord3dvARB");
	glMultiTexCoord3fARB		=	(PFNGLMULTITEXCOORD3FARBPROC)
									wglGetProcAddress("glMultiTexCoord3fARB");
	glMultiTexCoord3fvARB		=	(PFNGLMULTITEXCOORD3FVARBPROC)
									wglGetProcAddress("glMultiTexCoord3fvARB");
	glMultiTexCoord3iARB		=	(PFNGLMULTITEXCOORD3IARBPROC)
									wglGetProcAddress("glMultiTexCoord3iARB");
	glMultiTexCoord3ivARB		=	(PFNGLMULTITEXCOORD3IVARBPROC)
									wglGetProcAddress("glMultiTexCoord3ivARB");
	glMultiTexCoord3sARB		=	(PFNGLMULTITEXCOORD3SARBPROC)
									wglGetProcAddress("glMultiTexCoord3sARB");
	glMultiTexCoord3svARB		=	(PFNGLMULTITEXCOORD3SVARBPROC)
									wglGetProcAddress("glMultiTexCoord3svARB");
	glMultiTexCoord4dARB		=	(PFNGLMULTITEXCOORD4DARBPROC)
									wglGetProcAddress("glMultiTexCoord4dARB");
	glMultiTexCoord4dvARB		=	(PFNGLMULTITEXCOORD4DVARBPROC)
									wglGetProcAddress("glMultiTexCoord4dvARB");
	glMultiTexCoord4fARB		=	(PFNGLMULTITEXCOORD4FARBPROC)
									wglGetProcAddress("glMultiTexCoord4fARB");
	glMultiTexCoord4fvARB		=	(PFNGLMULTITEXCOORD4FVARBPROC)
									wglGetProcAddress("glMultiTexCoord4fvARB");
	glMultiTexCoord4iARB		=	(PFNGLMULTITEXCOORD4IARBPROC)
									wglGetProcAddress("glMultiTexCoord4iARB");
	glMultiTexCoord4ivARB		=	(PFNGLMULTITEXCOORD4IVARBPROC)
									wglGetProcAddress("glMultiTexCoord4ivARB");
	glMultiTexCoord4sARB		=	(PFNGLMULTITEXCOORD4SARBPROC)
									wglGetProcAddress("glMultiTexCoord4sARB");
	glMultiTexCoord4svARB		=	(PFNGLMULTITEXCOORD4SVARBPROC)
									wglGetProcAddress("glMultiTexCoord4svARB");

	return true;
}

//function pointers

PFNGLACTIVETEXTUREARBPROC				glActiveTextureARB				=NULL;
PFNGLCLIENTACTIVETEXTUREARBPROC			glClientActiveTextureARB		=NULL;
PFNGLMULTITEXCOORD1DARBPROC				glMultiTexCoord1dARB			=NULL;
PFNGLMULTITEXCOORD1DVARBPROC			glMultiTexCoord1dvARB			=NULL;
PFNGLMULTITEXCOORD1FARBPROC				glMultiTexCoord1fARB			=NULL;
PFNGLMULTITEXCOORD1FVARBPROC			glMultiTexCoord1fvARB			=NULL;
PFNGLMULTITEXCOORD1IARBPROC				glMultiTexCoord1iARB			=NULL;
PFNGLMULTITEXCOORD1IVARBPROC			glMultiTexCoord1ivARB			=NULL;
PFNGLMULTITEXCOORD1SARBPROC				glMultiTexCoord1sARB			=NULL;
PFNGLMULTITEXCOORD1SVARBPROC			glMultiTexCoord1svARB			=NULL;
PFNGLMULTITEXCOORD2DARBPROC				glMultiTexCoord2dARB			=NULL;
PFNGLMULTITEXCOORD2DVARBPROC			glMultiTexCoord2dvARB			=NULL;
PFNGLMULTITEXCOORD2FARBPROC				glMultiTexCoord2fARB			=NULL;
PFNGLMULTITEXCOORD2FVARBPROC			glMultiTexCoord2fvARB			=NULL;
PFNGLMULTITEXCOORD2IARBPROC				glMultiTexCoord2iARB			=NULL;
PFNGLMULTITEXCOORD2IVARBPROC			glMultiTexCoord2ivARB			=NULL;
PFNGLMULTITEXCOORD2SARBPROC				glMultiTexCoord2sARB			=NULL;
PFNGLMULTITEXCOORD2SVARBPROC			glMultiTexCoord2svARB			=NULL;
PFNGLMULTITEXCOORD3DARBPROC				glMultiTexCoord3dARB			=NULL;
PFNGLMULTITEXCOORD3DVARBPROC			glMultiTexCoord3dvARB			=NULL;
PFNGLMULTITEXCOORD3FARBPROC				glMultiTexCoord3fARB			=NULL;
PFNGLMULTITEXCOORD3FVARBPROC			glMultiTexCoord3fvARB			=NULL;
PFNGLMULTITEXCOORD3IARBPROC				glMultiTexCoord3iARB			=NULL;
PFNGLMULTITEXCOORD3IVARBPROC			glMultiTexCoord3ivARB			=NULL;
PFNGLMULTITEXCOORD3SARBPROC				glMultiTexCoord3sARB			=NULL;
PFNGLMULTITEXCOORD3SVARBPROC			glMultiTexCoord3svARB			=NULL;
PFNGLMULTITEXCOORD4DARBPROC				glMultiTexCoord4dARB			=NULL;
PFNGLMULTITEXCOORD4DVARBPROC			glMultiTexCoord4dvARB			=NULL;
PFNGLMULTITEXCOORD4FARBPROC				glMultiTexCoord4fARB			=NULL;
PFNGLMULTITEXCOORD4FVARBPROC			glMultiTexCoord4fvARB			=NULL;
PFNGLMULTITEXCOORD4IARBPROC				glMultiTexCoord4iARB			=NULL;
PFNGLMULTITEXCOORD4IVARBPROC			glMultiTexCoord4ivARB			=NULL;
PFNGLMULTITEXCOORD4SARBPROC				glMultiTexCoord4sARB			=NULL;
PFNGLMULTITEXCOORD4SVARBPROC			glMultiTexCoord4svARB			=NULL;

