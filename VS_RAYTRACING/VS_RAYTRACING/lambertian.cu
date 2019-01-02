#include "lambertian.h"

lambertian::lambertian(const glm::vec3 &a) {
	albedo = a;
}

bool lambertian::scatter(const ray &r_in, const hit_record &rec, glm::vec3 &attenuation, ray &scattered) const {
	glm::vec3 target = rec.p + rec.normal + randomInUnitSphere();
	scattered = ray(rec.p, target - rec.p);
	attenuation = albedo;
	return true;
}