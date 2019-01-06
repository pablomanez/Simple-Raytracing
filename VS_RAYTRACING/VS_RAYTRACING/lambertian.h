#pragma once

#include "Util.h"
#include "ray.h"
#include "material.h"

class lambertian : public material {
	private:
		glm::vec3 albedo;
	public:
		__device__ lambertian(const glm::vec3&);
		__device__ virtual bool scatter(const ray&, const hit_record&, glm::vec3&, ray&) const;
};

__device__ lambertian::lambertian(const glm::vec3 &a) {
	albedo = a;
}

__device__ bool lambertian::scatter(const ray &r_in, const hit_record &rec, glm::vec3 &attenuation, ray &scattered) const {
	glm::vec3 target = rec.p + rec.normal + randomInUnitSphere();
	scattered = ray(rec.p, target - rec.p);
	attenuation = albedo;
	return true;
}