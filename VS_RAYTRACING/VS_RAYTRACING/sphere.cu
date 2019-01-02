#include "sphere.h"

sphere::sphere() {}
sphere::~sphere() {}

sphere::sphere(glm::vec3 cen, float r): center(cen), radius(r){}

bool sphere::hit(const ray &r, float t_min, float t_max, hit_record &rec) const{
	glm::vec3 const origin = r.getOrigin();
	glm::vec3 const dir = r.getDirection();

	glm::vec3 oc = origin - center;
	float a = glm::dot(dir, dir);
	float b = glm::dot(oc, dir);
	float c = glm::dot(oc, oc) - radius * radius;
	float disc = b*b - a*c;

	if (disc > 0) {
		float temp = (-b - glm::sqrt(b*b - a*c)) / a;
		if (temp < t_max && temp > t_min) {
			rec.t = temp;
			rec.p = r.getPointAtParameter(rec.t);
			rec.normal = (rec.p - center) / radius;
			return true;
		}

		temp = (-b + glm::sqrt(b*b - a*c)) / a;
		if (temp < t_max && temp > t_min) {
			rec.t = temp;
			rec.p = r.getPointAtParameter(rec.t);
			rec.normal = (rec.p - center) / radius;
			return true;
		}
	}
	return false;
}
