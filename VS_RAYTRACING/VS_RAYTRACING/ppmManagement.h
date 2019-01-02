#pragma once
#include "Util.h"
#include "ray.h"
#include "sphere.h"
#include "hitable_list.h"
#include "hitable.h"

class ppmManagement{
	public:
		ppmManagement();
		~ppmManagement();

		glm::vec3 getColor(const ray&,hitable*);
		void createImage(int,int,const std::string&);
};

