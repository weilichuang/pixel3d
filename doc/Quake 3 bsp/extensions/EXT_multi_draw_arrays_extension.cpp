//////////////////////////////////////////////////////////////////////////////////////////
//	EXT_multi_draw_arrays_extension.cpp
//	EXT_multi_draw_arrays extension setup
//	Downloaded from: www.paulsprojects.net
//	Created:	8th August 2002
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
#include "EXT_multi_draw_arrays_extension.h"

extern LOG errorLog;

bool EXT_multi_draw_arrays_supported=false;

bool SetUpEXT_multi_draw_arrays()
{
	//Check for support
	char * extensionString=(char *)glGetString(GL_EXTENSIONS);
	char * extensionName="GL_EXT_multi_draw_arrays";

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
			EXT_multi_draw_arrays_supported=true;
		}

		//if not, move on
		extensionString+=distanceToSpace+1;
	}

	if(!EXT_multi_draw_arrays_supported)
	{
		errorLog.OutputError("EXT_multi_draw_arrays unsupported!");
		return false;
	}

	errorLog.OutputSuccess("EXT_multi_draw_arrays supported!");

	//get function pointers
	glMultiDrawArraysEXT			=	(PFNGLMULTIDRAWARRAYSEXTPROC)
										wglGetProcAddress("glMultiDrawArraysEXT");
	glMultiDrawElementsEXT			=	(PFNGLMULTIDRAWELEMENTSEXTPROC)
										wglGetProcAddress("glMultiDrawElementsEXT");

	return true;
}

//function pointers
PFNGLMULTIDRAWARRAYSEXTPROC				glMultiDrawArraysEXT	=	NULL;
PFNGLMULTIDRAWELEMENTSEXTPROC			glMultiDrawElementsEXT	=	NULL;
