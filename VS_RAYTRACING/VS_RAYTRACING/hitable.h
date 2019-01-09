#pragma once

#include "Util.h"
#include "ray.h"

class material;

class hitable {
	public:
		__device__ virtual bool hit(const ray &r, float tmin, float t_max, hit_record& rec) const = 0;
};
