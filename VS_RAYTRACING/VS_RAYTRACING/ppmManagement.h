#pragma once
#include "Util.h"
#include "ray.h"
#include "sphere.h"
#include "hitable_list.h"
#include "hitable.h"
#include "camera.h"

class ppmManagement{
	public:
		ppmManagement();
		~ppmManagement();

		glm::vec3 getColor(const ray&,hitable*);
		glm::vec3 randomInUnitSphere();
		void createImage(int,int,int,const std::string&);
};

