#include <iostream>
#include <fstream>
#include <random>
#include <iomanip>

using namespace std;

#define PATNUM 10
#define SEED 99
#define INPUTFILE "input.txt"
#define OUTPUTFILE "output.txt"
#define DEBUGFILE "debug.txt"
#define DEBUGPATNUM 0
void conv(int image[6][6], int ker[3][3], int out[4][4]);
void firstQuantization(int image[4][4], int out[4][4]);
void maxPool(int image[4][4], int out[2][2]);
void fullyConnect(int image[2][2], int weight[2][2], int out[4]);
void secondQuantization(int image[4], int out[4]);
int L1Distance(int image1[4], int image2[4]);

int main()
{
	srand(SEED);
	ofstream input;
	ofstream output;
	ofstream debug;
	input.open(INPUTFILE);
	output.open(OUTPUTFILE);
	debug.open(DEBUGFILE);

	input << PATNUM << endl;

	for (int patcount = 0; patcount < PATNUM; patcount++)
	{
		int image1[6][6];
		int image2[6][6];
		int ker[3][3];
		int weight[2][2];



		// generate image1 and image2 randomly
		for (int row = 0; row < 6; row++)
		{
			for (int col = 0; col < 6; col++)
			{
				image1[row][col] = rand() % 256;
				image2[row][col] = rand() % 256;
			}
		}

		// gerate ker randomly
		for (int row = 0; row < 3; row++)
		{
			for (int col = 0; col < 3; col++)
			{
				ker[row][col] = rand() % 256;
			}
		}

		// generate weight randomly
		for (int row = 0; row < 2; row++)
		{
			for (int col = 0; col < 2; col++)
			{
				weight[row][col] = rand() % 256;
			}
		}

		// write input in input.txt
		for (int i = 0; i < 72; i++)
		{
			if (i < 36)
				input << image1[i / 6][i % 6] << endl;
			else
				input << image2[(i - 36) / 6][(i - 36) % 6] << endl;
			if (i < 9)
				input << ker[i / 3][i % 3] << endl;
			if (i < 4)
				input << weight[i / 2][i % 2] << endl;
		}

		// convolution
		int conv1[4][4];
		int conv2[4][4];
		conv(image1, ker, conv1);
		conv(image2, ker, conv2);

		// quantization of 4x4 feature map
		int firstQuantize1[4][4];
		int firstQuantize2[4][4];
		firstQuantization(conv1, firstQuantize1);
		firstQuantization(conv2, firstQuantize2);

		// max pooling
		int maxPool1[2][2];
		int maxPool2[2][2];
		maxPool(firstQuantize1, maxPool1);
		maxPool(firstQuantize2, maxPool2);

		// fully connected
		int fullyConnect1[4];
		int fullyConnect2[4];
		fullyConnect(maxPool1, weight, fullyConnect1);
		fullyConnect(maxPool2, weight, fullyConnect2);

		// second quantization
		int secondQuantize1[4];
		int secondQuantize2[4];
		secondQuantization(fullyConnect1, secondQuantize1);
		secondQuantization(fullyConnect2, secondQuantize2);

		// L1Distance
		int distance;
		distance = L1Distance(secondQuantize1, secondQuantize2);

		// activation function
		int golden_out;
		if (distance < 16)
			golden_out = 0;
		else
			golden_out = distance;

		// write golden answer in output.txt
		output << golden_out << endl;

		// write all input, output and calculation process in debug.txt
		if (patcount == DEBUGPATNUM)
		{
			debug << "=========================================" << endl;
			debug << "                  input                  " << endl;
			debug << "=========================================" << endl;
			debug << "image 1:" << endl;
			for (int row = 0; row < 6; row++)
			{
				for (int col = 0; col < 6; col++)
				{
					debug << setw(4) << image1[row][col];
				}
				debug << endl;
			}
			debug << endl;
			debug << "image 2:" << endl;
			for (int row = 0; row < 6; row++)
			{
				for (int col = 0; col < 6; col++)
				{
					debug << setw(4) << image2[row][col];
				}
				debug << endl;
			}
			debug << endl;
			debug << "ker:" << endl;
			for (int row = 0; row < 3; row++)
			{
				for (int col = 0; col < 3; col++)
				{
					debug << setw(4) << ker[row][col];
				}
				debug << endl;
			}
			debug << endl;
			debug << "weight:" << endl;
			for (int row = 0; row < 2; row++)
			{
				for (int col = 0; col < 2; col++)
				{
					debug << setw(4) << weight[row][col];
				}
				debug << endl;
			}
			debug << endl;
			debug << "=========================================" << endl;
			debug << "                   conv                  " << endl;
			debug << "=========================================" << endl;
			debug << "image 1:" << endl;
			for (int row = 0; row < 4; row++)
			{
				for (int col = 0; col < 4; col++)
				{
					debug << setw(7) << conv1[row][col];
				}
				debug << endl;
			}
			debug << "image 2:" << endl;
			for (int row = 0; row < 4; row++)
			{
				for (int col = 0; col < 4; col++)
				{
					debug << setw(7) << conv2[row][col];
				}
				debug << endl;
			}
			debug << endl;
			debug << "=========================================" << endl;
			debug << "             first quantization          " << endl;
			debug << "=========================================" << endl;
			debug << "image 1:" << endl;
			for (int row = 0; row < 4; row++)
			{
				for (int col = 0; col < 4; col++)
				{
					debug << setw(5) << firstQuantize1[row][col];
				}
				debug << endl;
			}
			debug << "image 2:" << endl;
			for (int row = 0; row < 4; row++)
			{
				for (int col = 0; col < 4; col++)
				{
					debug << setw(5) << firstQuantize2[row][col];
				}
				debug << endl;
			}
			debug << endl;
			debug << "=========================================" << endl;
			debug << "                max pooling              " << endl;
			debug << "=========================================" << endl;
			debug << "image 1:" << endl;
			for (int row = 0; row < 2; row++)
			{
				for (int col = 0; col < 2; col++)
				{
					debug << setw(5) << maxPool1[row][col];
				}
				debug << endl;
			}
			debug << "image 2:" << endl;
			for (int row = 0; row < 2; row++)
			{
				for (int col = 0; col < 2; col++)
				{
					debug << setw(5) << maxPool2[row][col];
				}
				debug << endl;
			}
			debug << endl;
			debug << "=========================================" << endl;
			debug << "              fully connected            " << endl;
			debug << "=========================================" << endl;
			debug << "image 1:" << endl;
			for (int i = 0; i < 4; i++)
			{
				debug << setw(7) << fullyConnect1[i] << endl;
			}
			debug << "image 2:" << endl;
			for (int i = 0; i < 4; i++)
			{
				debug << setw(7) << fullyConnect2[i] << endl;
			}
			debug << endl;
			debug << "=========================================" << endl;
			debug << "            second quantization          " << endl;
			debug << "=========================================" << endl;
			debug << "image 1:" << endl;
			for (int i = 0; i < 4; i++)
			{
				debug << setw(4) << secondQuantize1[i] << endl;
			}
			debug << "image 2:" << endl;
			for (int i = 0; i < 4; i++)
			{
				debug << setw(4) << secondQuantize2[i] << endl;
			}
			debug << endl;
			debug << "=========================================" << endl;
			debug << "                L1 distance              " << endl;
			debug << "=========================================" << endl;
			debug << "L1 Distance = " << setw(10) << distance << endl << endl;
			debug << "=========================================" << endl;
			debug << "            activation function          " << endl;
			debug << "=========================================" << endl;
			debug << "golden_out = " << setw(10) << golden_out;

			debug.close();
		}
	}
	input.close();
	output.close();
}
void conv(int image[6][6], int kernel[3][3], int out[4][4])
{
	for (int m = 0; m < 4; m++)
	{
		for (int n = 0; n < 4; n++)
		{
			int sum = 0;
			for (int i = 0; i < 3; i++)
			{
				for (int j = 0; j < 3; j++)
				{
					sum += image[m + i][n + j] * kernel[i][j];
				}
			}
			out[m][n] = sum;
		}
	}
}

void firstQuantization(int image[4][4], int out[4][4])
{
	for (int row = 0; row < 4; row++)
	{
		for (int col = 0; col < 4; col++)
		{
			out[row][col] = image[row][col] / 2295;
		}
	}
}

void maxPool(int image[4][4], int out[2][2])
{
	for (int row = 0; row < 4; row = row + 2)
	{
		for (int col = 0; col < 4; col = col + 2)
		{
			int max = 0;
			for (int i = 0; i < 2; i++)
			{
				for (int j = 0; j < 2; j++)
				{
					if (image[row + i][col + j] > max)
						max = image[row + i][col + j];
				}
			}
			out[row / 2][col / 2] = max;
		}
	}
}

void fullyConnect(int image[2][2], int weight[2][2], int out[4])
{
	out[0] = image[0][0] * weight[0][0] + image[0][1] * weight[1][0];
	out[1] = image[0][0] * weight[0][1] + image[0][1] * weight[1][1];
	out[2] = image[1][0] * weight[0][0] + image[1][1] * weight[1][0];
	out[3] = image[1][0] * weight[0][1] + image[1][1] * weight[1][1];
}

void secondQuantization(int image[4], int out[4])
{
	for (int i = 0; i < 4; i++)
	{
		out[i] = image[i] / 510;
	}
}

int L1Distance(int image1[4], int image2[4])
{
	int sum = 0;
	for (int i = 0; i < 4; i++)
	{
		if (image1[i] > image2[i])
			sum += image1[i] - image2[i];
		else
			sum += image2[i] - image1[i];
	}

	return sum;
}