#pragma once

#include "ray.h"
#include "Util.h"

class material;

struct hit_record {
	float t;
	glm::vec3 p;
	glm::vec3 normal;
	material *mat_ptr;
};

class hitable {
	public:
		__device__ virtual bool hit(const ray &r, float tmin, float t_max, hit_record& rec) const = 0;
};
