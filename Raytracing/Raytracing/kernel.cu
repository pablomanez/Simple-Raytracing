#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <iostream>

#define K_TPB	256
#define K_ELEMS 25610

__global__ void sumaVectores(float *a, float *b, float *c, int total_elems) {
	int idx_ = blockIdx.x * blockDim.x + threadIdx.x;

	if (idx_ < total_elems) {
		c[idx_] = a[idx_] + b[idx_];
	}
}

__global__ void sumaVectoresSuprema(float *a, float *b, float *c, int total_elems, int bLength) {
	int idx_ = blockIdx.x * blockDim.x + threadIdx.x;

	for (int i = 0; i < total_elems; i += bLength) {
		c[idx_] = a[idx_] + b[idx_];
	}
}

// Se ejecuta en la GPU y se llama desde la GPU
// __device__

// Se ejecuta en el host y se llama desde el host
// __host__

// SABER LIMITACION DE TARJETA GRAFICA -> device query (de CUDA)
int main(void) {
	float r, g, b;
	int nx = 200;
	int ny = 100;
	int ir, ig, ib;

	std::cout << "P3\n" << nx << " " << ny << "\n255\n";
	for (int j = ny - 1; j >= 0; j--) {
		for (int i = 0; i < nx; i++) {
			r = float(i) / float(nx);
			g = float(j) / float(ny);
			b = 0.2;
			ir = int(255.99*r);
			ig = int(255.99*g);
			ib = int(255.99*b);
			std::cout << ir << " " << ig << " " << ib << "\n";
		}
	}

	// La finale
	getchar();
	exit(-1);







	// const int kNumElems = K_ELEMS;
	// const int knumBytes = sizeof(float) * kNumElems;
	// 
	// // Reservar la tarjeta grafica a la hora de realizar computo
	// cudaSetDevice(0);
	// 
	// float *h_a_ = (float*)malloc(knumBytes);
	// float *h_b_ = (float*)malloc(knumBytes);
	// float *h_c_ = (float*)malloc(knumBytes);
	// 
	// // if(h_a_ == NULL || h_b_ == NULL || h_c_ == NULL){
	// if (!h_a_ || !h_b_ || !h_c_) {
	// 	std::cerr << "Error al reservar memoria\n";
	// 	getchar();
	// 	exit(-1);
	// }
	// 
	// // Albert pone ++i
	// for (int i = 0; i < kNumElems; i++) {
	// 	h_a_[i] = rand() / (float)RAND_MAX;
	// 	h_b_[i] = rand() / (float)RAND_MAX;
	// }
	// 
	// float *d_a_ = NULL;
	// float *d_b_ = NULL;
	// float *d_c_ = NULL;
	// 
	// cudaMalloc((void**)&d_a_, knumBytes);
	// cudaMalloc((void**)&d_b_, knumBytes);
	// cudaMalloc((void**)&d_c_, knumBytes);
	// 
	// cudaMemcpy(d_a_, h_a_, knumBytes, cudaMemcpyHostToDevice);
	// cudaMemcpy(d_b_, h_b_, knumBytes, cudaMemcpyHostToDevice);
	// 
	// // Organizar bloques e hilos
	// int threads_per_block_ = K_TPB;
	// 
	// float tpb_aux = kNumElems / (float)(threads_per_block_);
	// int blocks_per_grid_ = kNumElems / threads_per_block_;
	// if (tpb_aux > blocks_per_grid_) {
	// 	blocks_per_grid_ += 1;
	// }
	// 
	// // Forma de cada thread
	// dim3 tpb_(threads_per_block_, 1, 1);
	// 
	// // Forma de la malla
	// dim3 bpg_(blocks_per_grid_, 1, 1);
	// 
	// // ----------------------------------------------
	// // Llamada a la funcion con DATOS QUE RESIDEN EN LA GRAFICA
	// // Si da el pequenyo error sint�ctico del <, no pasa nada
	// // sumaVectores<<< bpg_, tpb_ >>>(d_a_,d_b_,d_c_,kNumElems);
	// sumaVectoresSuprema << < bpg_, tpb_ >> > (d_a_, d_b_, d_c_, kNumElems, blocks_per_grid_*threads_per_block_);
	// // ----------------------------------------------
	// 
	// cudaError_t err_ = cudaGetLastError();
	// if (err_ != cudaSuccess) {
	// 	std::cerr << "Error " << cudaGetErrorString(err_) << "\n";
	// }
	// 
	// cudaMemcpy(h_c_, d_c_, knumBytes, cudaMemcpyDeviceToHost);
	// 
	// // Mirar el error
	// for (int i = 0; i < kNumElems; i++) {
	// 	if (fabs(h_a_[i] + h_b_[i] - h_c_[i]) > 1e-5) {
	// 		std::cerr << "Error en la posicion " << i << "\n";
	// 		getchar();
	// 		exit(-1);
	// 	}
	// }
	// 
	// // Liberacion de memoria
	// free(h_a_);
	// free(h_b_);
	// free(h_c_);
	// 
	// cudaFree(h_a_);
	// cudaFree(h_b_);
	// cudaFree(h_c_);
	// 
	// // Elimita todo lo de la grafica
	// cudaDeviceReset();
	// std::cout << "Optimo\n";
	// getchar();
	// exit(-1);

}
