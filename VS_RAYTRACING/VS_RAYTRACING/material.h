#pragma once

#include "Util.h"
#include "hitable.h"
#include "ray.h"

class material {
	public:
		__device__ virtual bool scatter(const ray &r_in, const hit_record &rec, glm::vec3 &atten, ray &scattered) const = 0;
};