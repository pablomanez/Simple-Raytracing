// Librerias
#include "Util.h"
#include "ppmManagement.h"

ppmManagement mng;

int main(void) {
	mng.createImage(200,100,"img.PPM");

	std::cout << "Finalizado" << '\n';
}
