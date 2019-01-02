#pragma once

#include "ray.h"
#include "Util.h"

struct hit_record {
	float t;
	glm::vec3 p;
	glm::vec3 normal;
};

class hitable {
	public:
		virtual bool hit(const ray &r, float tmin, float t_max, hit_record& rec) const = 0;
};
