/*
===========================================================================
Copyright (C) 2008 Daniel �rstadius

This file is part of bsp-renderer source code.

bsp-renderer is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

bsp-renderer is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with bsp-renderer.  If not, see <http://www.gnu.org/licenses/>.

*/
// main.cpp -- start up the engine

#include "BaseApp.h"
#include <iostream>
#include <string.h>
using namespace std;

static void showLicenseMsg(void);

//int WINAPI WinMain (HINSTANCE hInstance, HINSTANCE prevInstance,
//				    PSTR cmdLine, int showCmd)
int main(void)
{			
  // Enable run-time memory check for debug builds.
#if defined(DEBUG) | defined(_DEBUG)
  _CrtSetDbgFlag( _CRTDBG_ALLOC_MEM_DF | _CRTDBG_LEAK_CHECK_DF );
#endif

#ifdef RELEASE_BUILD
  showLicenseMsg();
#endif

  BaseApp e;
  gBaseApp = &e;	

  gBaseApp->initDInput();
  gBaseApp->initRenderer("bsp.cfg");

  gBaseApp->run();

  return 0;
}

void showLicenseMsg(void)
{
  cout << "bsp-renderer  Copyright (C) 2008  Daniel Orstadius\n\
    This program comes with ABSOLUTELY NO WARRANTY.\n\
    This is free software, and you are welcome to redistribute it\n\
    under certain conditions. These are described in file COPYING.\n";

  cout << "\n\nIf no level is specified in file bsp.cfg, then \"The Forlorn Hope\"";
  cout << " by JustOneFiX will be loaded.\n";
  cout << "\nTo run bsp-renderer type 'y' and press return: ";
  string answer;
  answer = "y";
  getline(cin, answer); 
  
  if (answer.compare("y"))
  {
    exit(0);
  }  
}