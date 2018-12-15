#pragma once
#include "Util.h"
#include "ray.h"

class ppmManagement{
	public:
		ppmManagement();
		~ppmManagement();

		void createImage(int,int,const std::string&);
};

