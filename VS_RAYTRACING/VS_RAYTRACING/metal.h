#pragma once

#include "Util.h"
#include "ray.h"
#include "material.h"

class metal : public material {
	private:
		glm::vec3 albedo;
		float fuzz;
	public:
		__device__ metal(const glm::vec3&, float);
		__device__ virtual bool scatter(const ray&, const hit_record&, glm::vec3&, ray&) const;
};

__device__ metal::metal(const glm::vec3 &a, float f = 0) {
	albedo = a;

	(f < 1) ? fuzz = f : fuzz = 1.0;
}

__device__ bool metal::scatter(const ray &r_in, const hit_record &rec, glm::vec3 &attenuation, ray &scattered) const {
	glm::vec3 reflected = glm::reflect(glm::normalize(r_in.getDirection()), rec.normal);
	scattered = ray(rec.p, reflected + fuzz * randomInUnitSphere());
	attenuation = albedo;
	return true;
}