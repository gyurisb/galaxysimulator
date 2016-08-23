#include <iostream>
#include <vector>

#include "cl.hpp"
#include "Common.h"

#include "GalaxySimulator.h"

using namespace std;

cl::Context context;
cl::CommandQueue queue;
cl::Kernel kernel;
cl::Event event;
cl_int err = CL_SUCCESS;
cl::Buffer clInputBuffer;
cl::Buffer clResultBuffer;

int InitContext()
{

	std::vector<cl::Platform> platforms;
	cl::Platform::get(&platforms);
	if (platforms.size() == 0)
	{
		std::cout << "Unable to find suitable platform." << std::endl;
		return -1;
	}

	cl_context_properties properties[] = { CL_CONTEXT_PLATFORM, (cl_context_properties)(platforms[0])(), 0 };
	context = cl::Context(CL_DEVICE_TYPE_GPU, properties);

	std::vector<cl::Device> devices = context.getInfo<CL_CONTEXT_DEVICES>();

	std::string programSource = FileToString("..\\kernels\\programs.cl");
	cl::Program program = cl::Program(context, programSource);
	program.build(devices);

	kernel = cl::Kernel(program, "move", &err);

	clInputBuffer = cl::Buffer(context, CL_MEM_READ_WRITE, sizeof(Body) * BodyCount, NULL, &err);
	clResultBuffer = cl::Buffer(context, CL_MEM_READ_WRITE, sizeof(Body) * BodyCount, NULL, &err);

	queue = cl::CommandQueue(context, devices[0], 0, &err);
	return 0;
}


class SimulateWithOpenCLStrategy
{
public:

	static void initialize(Body* space)
	{
	}

	static void simulateDay(Body* space, Body* nextSpace) 
	{
		//clInputBuffer = cl::Buffer(context, CL_MEM_READ_WRITE, sizeof(Body) * BodyCount, NULL, &err);
		//clResultBuffer = cl::Buffer(context, CL_MEM_READ_WRITE, sizeof(Body) * BodyCount, NULL, &err);
		queue.enqueueWriteBuffer(clInputBuffer, true, 0, sizeof(Body) * BodyCount, space);

		kernel.setArg(0, clInputBuffer);
		kernel.setArg(1, clResultBuffer);
		kernel.setArg(2, BodyCount);
		queue.enqueueNDRangeKernel(kernel,
			cl::NullRange,
			cl::NDRange(ceil(BodyCount / 500.0) * 500, 1),
			cl::NullRange,
			NULL,
			&event);
		event.wait();

		queue.enqueueReadBuffer(clResultBuffer, true, 0, sizeof(Body) * BodyCount, nextSpace);
	}
};

int main(int argc, char** argv)
{
	InitContext();

	//Run simulation using OpenMP parallelism (only CPU cores)
	//simulateGalaxy<>();

	//Run simulation using OpenCL libraries (GPU)
	simulateGalaxy<SimulateWithOpenCLStrategy>();
}
