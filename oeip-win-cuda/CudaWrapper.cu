#include "fastguidedfilter.h"
#include "colorconvert.h"

using namespace cv;
using namespace cv::cuda;
//using namespace cv::cuda::device;

//nvcc与C++编译的转接文件
#define BLOCK_X 32
#define BLOCK_Y 8

const dim3 block = dim3(BLOCK_X, BLOCK_Y);

void rgb2rgba_gpu(PtrStepSz<uchar3> source, PtrStepSz<uchar4> dest, cudaStream_t stream) {
	dim3 grid(divUp(dest.cols, block.x), divUp(dest.rows, block.y));
	rgb2rgba << <grid, block, 0, stream >> > (source, dest);
}

void rgba2bgr_gpu(PtrStepSz<uchar4> source, PtrStepSz<uchar3> dest, cudaStream_t stream) {
	dim3 grid(divUp(dest.cols, block.x), divUp(dest.rows, block.y));
	rgba2bgr << <grid, block, 0, stream >> > (source, dest);
}

void argb2rgba_gpu(PtrStepSz<uchar4> source, PtrStepSz<uchar4> dest, cudaStream_t stream) {
	dim3 grid(divUp(dest.cols, block.x), divUp(dest.rows, block.y));
	argb2rgba << <grid, block, 0, stream >> > (source, dest);
}

//yuv planer转换成rgb
void yuv2rgb_gpu(PtrStepSz<uchar> source, PtrStepSz<uchar4> dest, int32_t yuvtype, cudaStream_t stream) {
	dim3 grid(divUp(dest.cols, block.x), divUp(dest.rows, block.y));
	if (yuvtype == 1)
		yuv2rgb<1> << <grid, block, 0, stream >> > (source, dest);
	else if (yuvtype == 5)
		yuv2rgb<5> << <grid, block, 0, stream >> > (source, dest);
	else if (yuvtype == 6)
		yuv2rgb<6> << <grid, block, 0, stream >> > (source, dest);
}

//packed ufront/yfront (yuyv true/true)/(yvyu false/true)/(uyvy true/false)
void yuv2rgb_gpu(PtrStepSz<uchar4> source, PtrStepSz<uchar4> dest, bool ufront, bool yfront, cudaStream_t stream) {
	dim3 grid(divUp(source.cols, block.x), divUp(source.rows, block.y));
	int bitx = ufront ? 0 : 2;
	int yoffset = yfront ? 0 : 1;
	yuv2rgb << <grid, block, 0, stream >> > (source, dest, bitx, yoffset);
}

void rgb2yuv_gpu(PtrStepSz<uchar4> source, PtrStepSz<uchar> dest, int32_t yuvtype, cudaStream_t stream) {	
	dim3 grid(divUp(source.cols/2, block.x), divUp(source.rows/2, block.y));
	if (yuvtype == 1)
		rgb2yuv<1> << <grid, block, 0, stream >> > (source, dest);
	else if (yuvtype == 6)
		rgb2yuv<6> << <grid, block, 0, stream >> > (source, dest);
	else if (yuvtype == 5){
		dim3 grid(divUp(source.cols, block.x), divUp(source.rows/2, block.y));
		rgb2yuv<5> << <grid, block, 0, stream >> > (source, dest);
		}
}

//packed ufront/yfront (yuyv true/true)/(yvyu false/true)/(uyvy true/false)
void rgb2yuv_gpu(PtrStepSz<uchar4> source, PtrStepSz<uchar4> dest, bool ufront, bool yfront, cudaStream_t stream) {
	dim3 grid(divUp(dest.cols, block.x), divUp(dest.rows, block.y));
	int bitx = ufront ? 0 : 2;
	int yoffset = yfront ? 0 : 1;
	rgb2yuv << <grid, block, 0, stream >> > (source, dest, bitx, yoffset);
}

void textureMap_gpu(PtrStepSz<uchar4> source, PtrStepSz<uchar4> dest, MapChannelParamet paramt, cudaStream_t stream) {
	dim3 grid(divUp(source.cols, block.x), divUp(source.rows, block.y));
	textureMap << <grid, block, 0, stream >> > (source, dest, paramt);
}

void findMatrix_gpu(PtrStepSz<float4> source, PtrStepSz<float3> dest, PtrStepSz<float3> dest1, PtrStepSz<float3> dest2, cudaStream_t stream)
{
	//dim3 block(32, 4);//(16, 16)
	dim3 grid(divUp(source.cols, block.x), divUp(source.rows, block.y));
	findMatrix << <grid, block, 0, stream >> > (source, dest, dest1, dest2);
}

void guidedFilter_gpu(PtrStepSz<float4> source, PtrStepSz<float3> col1, PtrStepSz<float3> col2, PtrStepSz<float3> col3, PtrStepSz<float4> dest, float eps, cudaStream_t stream)
{
	//dim3 block(32, 4);//(16, 16)
	dim3 grid(divUp(source.cols, block.x), divUp(source.rows, block.y));
	guidedFilter << <grid, block, 0, stream >> > (source, col1, col2, col3, dest, eps);
}

void guidedFilterResult_gpu(PtrStepSz<uchar4> source, PtrStepSz<float4> guid, PtrStepSz<uchar4> dest,
	float intensity, cudaStream_t stream) {
	dim3 grid(divUp(source.cols, block.x), divUp(source.rows, block.y));
	guidedFilterResult << <grid, block, 0, stream >> > (source, guid, dest, intensity);
}

void mainAlign_gpu(PtrStepSz<uint16_t> source, PtrStepSz<uint16_t> dest, Intrinsics alignParam, cudaStream_t stream) {

	dim3 grid(divUp(source.cols, block.x), divUp(source.rows, block.y));
	mainAlign << <grid, block, 0, stream >> > (source, dest, alignParam);
}

void distortion_gpu(PtrStepSz<uchar4> source, PtrStepSz<uchar4> dest, PtrStepSz<float2> map, cudaStream_t stream) {
	//dim3 block(32, 4);//(16, 16)
	dim3 grid(divUp(source.cols, block.x), divUp(source.rows, block.y));
	distortion << <grid, block, 0, stream >> > (source, dest, map);
}

void blend_gpu(PtrStepSz<uchar4> source, PtrStepSz<uchar4> blendTex, PtrStepSz<uchar4> dest,
	int32_t left, int32_t top, float opacity, cudaStream_t stream) {
	dim3 grid(divUp(source.cols, block.x), divUp(source.rows, block.y));
	blend << <grid, block, 0, stream >> > (source, blendTex, dest, left, top, opacity);
}

void operate_gpu(PtrStepSz<uchar4> source, PtrStepSz<uchar4> dest, OperateParamet paramt, cudaStream_t stream) {
	dim3 grid(divUp(source.cols, block.x), divUp(source.rows, block.y));
	operate << <grid, block, 0, stream >> > (source, dest, paramt);
}

void uchar2float_gpu(PtrStepSz<uchar4> source, PtrStepSz<float4> dest, cudaStream_t stream){
	dim3 grid(divUp(source.cols, block.x), divUp(source.rows, block.y));
	uchar2float << <grid, block, 0, stream >> > (source, dest);
}




