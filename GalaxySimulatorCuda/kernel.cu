
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <math.h>

#include "GalaxySimulator.h"

const int ThreadCount = 500;

__global__ void move(Body* space, Body* nextSpace, const int BodyCount)
{
	int i = blockIdx.x*ThreadCount + threadIdx.x;
	if (i >= BodyCount)
		return;

	Body* b2 = space + i;
	Body* b = nextSpace + i;
	double b2x = b2->x;
	double b2y = b2->y;
	double ax_sum = 0.0;
	double ay_sum = 0.0;
	for (int k = 0; k < BodyCount; k++)
	{
		Body* b1 = space + k;
		if (i != k)
		{
			double dx = b2x - b1->x;
			double dy = b2y - b1->y;
			double dist2 = dx*dx + dy*dy;
			double dist = sqrt(dist2);
			double a = (double)b1->mass / dist2;
			double ax = a * (dx / dist);
			double ay = a * (dy / dist);

			ax_sum += ax;
			ay_sum += ay;
		}
	}

	double ax = -GravitationalConstant * ax_sum;
	double ay = -GravitationalConstant * ay_sum;

	b->x = b2->x + b2->vx;
	b->y = b2->y + b2->vy;
	b->vx = b2->vx + ax;
	b->vy = b2->vy + ay;
	if (b->x <= -SpaceBorder || b->x >= SpaceBorder || b->y <= -SpaceBorder || b->y >= SpaceBorder)
		b->mass = -1;
	else
		b->mass = b2->mass;
}

Body *devInput = 0;
Body *devOutput = 0;

// Helper function for using CUDA to add vectors in parallel.
cudaError_t moveWithCuda(Body* space, Body* nextSpace)
{
	cudaError_t cudaStatus;
	
	// Copy input vectors from host memory to GPU buffers.
	cudaStatus = cudaMemcpy(devInput, space, BodyCount * sizeof(Body), cudaMemcpyHostToDevice);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMemcpy failed!");
		goto Error;
	}

	const int BlockCount = ceil(BodyCount / (double)ThreadCount);
	// Launch a kernel on the GPU with one thread for each element.
	move<<<BlockCount, ThreadCount>>>(devInput, devOutput, BodyCount);

	// Check for any errors launching the kernel
	cudaStatus = cudaGetLastError();
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "addKernel launch failed: %s\n", cudaGetErrorString(cudaStatus));
		goto Error;
	}

	// cudaDeviceSynchronize waits for the kernel to finish, and returns
	// any errors encountered during the launch.
	cudaStatus = cudaDeviceSynchronize();
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaDeviceSynchronize returned error code %d after launching addKernel!\n", cudaStatus);
		goto Error;
	}

	// Copy output vector from GPU buffer to host memory.
	cudaStatus = cudaMemcpy(nextSpace, devOutput, BodyCount * sizeof(Body), cudaMemcpyDeviceToHost);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMemcpy failed!");
		goto Error;
	}

Error:
	return cudaStatus;
}

class SimulateWithCudaStrategy
{
public:

	static void initialize(Body* space) {
	}

	static void simulateDay(Body* space, Body* nextSpace) {
		cudaError_t cudaStatus = moveWithCuda(space, nextSpace);
		if (cudaStatus != cudaSuccess) {
			fprintf(stderr, "moveWithCuda failed!");
			throw "moveWithCuda failed!";
		}
	}
};

int main()
{
	// Choose which GPU to run on, change this on a multi-GPU system.
	cudaError_t cudaStatus = cudaSetDevice(0);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaSetDevice failed!  Do you have a CUDA-capable GPU installed?");
		goto Error;
	}

	// Allocate GPU buffers for three vectors (two input, one output)    .
	cudaStatus = cudaMalloc((void**)&devInput, BodyCount * sizeof(Body));
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMalloc failed!");
		goto Error;
	}

	cudaStatus = cudaMalloc((void**)&devOutput, BodyCount * sizeof(Body));
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMalloc failed!");
		goto Error;
	}

	simulateGalaxy<SimulateWithCudaStrategy>();

    // cudaDeviceReset must be called before exiting in order for profiling and
    // tracing tools such as Nsight and Visual Profiler to show complete traces.
	cudaStatus = cudaDeviceReset();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaDeviceReset failed!");
		goto Error;
	}

Error:
	cudaFree(devInput);
	cudaFree(devOutput);
	return 0;
}
