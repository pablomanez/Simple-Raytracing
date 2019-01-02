#include "ppmManagement.h"

ppmManagement::ppmManagement(){}
ppmManagement::~ppmManagement(){}

glm::vec3 ppmManagement::getColor(const ray& r, hitable *WORLD) {
	hit_record rec;
	if (WORLD->hit(r, 0.0, FLT_MAX, rec)) {
		return 0.5f*glm::vec3(rec.normal.x + 1, rec.normal.y + 1, rec.normal.z + 1);
	}
	else {
		glm::vec3 unitDirection = glm::normalize(r.getDirection());
		float t = 0.5 * (unitDirection.y + 1.0f);
		return ((1.f - t) * glm::vec3(1.f)) + (t * glm::vec3(0.5, 0.7, 1.0));
	}
}

void ppmManagement::createImage(int _w, int _h, const std::string &_name) {
	std::ofstream _out(_name);
	int ir, ig, ib;
	float u,v;
	ray r;
	glm::vec3 color, dir;

	glm::vec3 lower_left_corner	(-2.0, -1.0, -1.0);
	glm::vec3 horizontal		( 4.0,  0.0,  0.0);
	glm::vec3 vertical			( 0.0,  2.0,  0.0);
	glm::vec3 camOrigin			( 0.0,  0.0,  0.0);

	int const total_hitables = 2;
	hitable *list[total_hitables];
	list[0] = new sphere(glm::vec3(0, 0, -1), 0.5);
	list[1] = new sphere(glm::vec3(0, -100.5, -1), 100);

	hitable *WORLD = new hitable_list(list, total_hitables);

	// Inicio del archivo PPM
	//	P3  -> El archivo esta en ASCII
	//	255 -> Color 'maximo'
	_out << "P3\n" << _w << " " << _h << "\n255\n";
	for (int j = _h - 1; j >= 0; j--) {
		for (int i = 0; i < _w; i++) {
			u = float(i) / float(_w);
			v = float(j) / float(_h);

			dir = lower_left_corner + u * horizontal + v * vertical;
			r.setRayParameters(camOrigin, dir);

			glm::vec3 p = r.getPointAtParameter(2.0);
			color = getColor(r, WORLD);

			ir = int(255.99 * color.r);
			ig = int(255.99 * color.g);
			ib = int(255.99 * color.b);

			// Valores de los pixeles
			_out << ir << " ";
			_out << ig << " ";
			_out << ib << "\n";
		}
	}
}
