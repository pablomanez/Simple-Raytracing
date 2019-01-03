#pragma once
#include "Util.h"
#include "ray.h"
#include "sphere.h"
#include "hitable_list.h"
#include "hitable.h"
#include "camera.h"
#include "material.h"
#include "metal.h"
#include "lambertian.h"

class ppmManagement{
	public:
		ppmManagement();
		~ppmManagement();

		glm::vec3 getColor(const ray&,hitable*,int);
		void createImage(int,int,int,const std::string&);
};

