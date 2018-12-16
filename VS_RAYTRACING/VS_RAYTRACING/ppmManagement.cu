#include "ppmManagement.h"

ppmManagement::ppmManagement(){}
ppmManagement::~ppmManagement(){}

void ppmManagement::createImage(int _w, int _h, const std::string &_name) {
	std::ofstream _out(_name);
	int ir, ig, ib;
	ray r;
	float u,v;
	glm::vec3 color, dir;

	glm::vec3 lower_left_corner	(-2.0, -1.0, -1.0);
	glm::vec3 horizontal		( 4.0,  0.0,  0.0);
	glm::vec3 vertical			( 0.0,  2.0,  0.0);
	glm::vec3 camOrigin			( 0.0,  0.0,  0.0);

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
			color = r.getColor();

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
