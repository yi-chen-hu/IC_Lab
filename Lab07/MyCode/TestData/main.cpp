#include <iostream>
#include <fstream>
#include <random>
#include <iomanip>

using namespace std;

#define PATNUM 5996 // PATNUM is the number of output, so if you set PATNUM 1, then there will be 5 inputs and 1 output
// Notice that the clock cycles from "first in_valid" to "last out_valid" cannot be over 100000 clk2 cycles when number of input is 6000.
// Therefore, it is recommended to set PATNUM 5996, so that this pattern can detect whether the latency of your design is short enough to pass TA's pattern.
#define SEED 44
#define DEBUGPATNUMBER 0
#define INPUTFILE "input.txt"
#define OUTPUTFILE "output.txt"
#define DEBUGFILE "debug.txt"

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

	int doraemon_id[5];
	int size[5];
	int iq_score[5];
	int eq_score[5];
	int size_weight;
	int iq_weight;
	int eq_weight;
	int golden_ans_door;
	int golden_ans_doraemon_id;

	// Generate first 4 inputs
	for (int i = 0; i < 4; i++)
	{
		doraemon_id[i] = rand() % 32;		// from 0 ~ 31
		size[i] = rand() % 151 + 50;	// from 50 ~ 200
		iq_score[i] = rand() % 151 + 50;	// from 50 ~ 200
		eq_score[i] = rand() % 151 + 50;	// from 50 ~ 200
		input << setw(2) << doraemon_id[i] << setw(4) << size[i] << setw(4) << iq_score[i] << setw(4) << eq_score[i] << endl;
	}

	for (int patcount = 0; patcount < PATNUM; patcount++)
	{
		// Generate input data
		int in_id = rand() % 32;			// from 0 ~ 31
		int in_size = rand() % 151 + 50;	// from 50 ~ 200
		int in_iq = rand() % 151 + 50;		// from 50 ~ 200
		int in_eq = rand() % 151 + 50;		// from 50 ~ 200
		size_weight = rand() % 8;		// from 0 ~ 7
		iq_weight = rand() % 8;			// from 0 ~ 7
		eq_weight = rand() % 8;			// from 0 ~ 7

		// Write input data in input.txt
		input << setw(2) << in_id << setw(4) << in_size << setw(4) << in_iq << setw(4) << in_eq << " " << size_weight << " " << iq_weight << " " << eq_weight << endl;

		// Save the new input data in specific index of array depending on last output data
		if (patcount == 0)
		{
			doraemon_id[4] = in_id;
			size[4] = in_size;
			iq_score[4] = in_iq;
			eq_score[4] = in_eq;
		}
		else
		{
			doraemon_id[golden_ans_door] = in_id;
			size[golden_ans_door] = in_size;
			iq_score[golden_ans_door] = in_iq;
			eq_score[golden_ans_door] = in_eq;
		}

		// Calculate the golden answer
		int preferenceScore0 = size_weight * size[0] + iq_weight * iq_score[0] + eq_weight * eq_score[0];
		int preferenceScore1 = size_weight * size[1] + iq_weight * iq_score[1] + eq_weight * eq_score[1];
		int preferenceScore2 = size_weight * size[2] + iq_weight * iq_score[2] + eq_weight * eq_score[2];
		int preferenceScore3 = size_weight * size[3] + iq_weight * iq_score[3] + eq_weight * eq_score[3];
		int preferenceScore4 = size_weight * size[4] + iq_weight * iq_score[4] + eq_weight * eq_score[4];

		if (preferenceScore0 >= preferenceScore1
			&& preferenceScore0 >= preferenceScore2
			&& preferenceScore0 >= preferenceScore3
			&& preferenceScore0 >= preferenceScore4)
		{
			golden_ans_door = 0;
			golden_ans_doraemon_id = doraemon_id[0];
		}
		else if (preferenceScore1 >= preferenceScore0
			&& preferenceScore1 >= preferenceScore2
			&& preferenceScore1 >= preferenceScore3
			&& preferenceScore1 >= preferenceScore4)
		{
			golden_ans_door = 1;
			golden_ans_doraemon_id = doraemon_id[1];
		}
		else if (preferenceScore2 >= preferenceScore0
			&& preferenceScore2 >= preferenceScore1
			&& preferenceScore2 >= preferenceScore3
			&& preferenceScore2 >= preferenceScore4)
		{
			golden_ans_door = 2;
			golden_ans_doraemon_id = doraemon_id[2];
		}
		else if (preferenceScore3 >= preferenceScore0
			&& preferenceScore3 >= preferenceScore1
			&& preferenceScore3 >= preferenceScore2
			&& preferenceScore3 >= preferenceScore4)
		{
			golden_ans_door = 3;
			golden_ans_doraemon_id = doraemon_id[3];
		}
		else
		{
			golden_ans_door = 4;
			golden_ans_doraemon_id = doraemon_id[4];
		}

		// Write golden answer in output.txt
		output << golden_ans_door << setw(3) << golden_ans_doraemon_id << endl;

		// Write debug information in debug.txt
		if (DEBUGPATNUMBER == patcount)
		{
			debug << "*** Notice that all value below is in decimal format ***" << endl;
			debug << endl;
			debug << "======================================================" << endl;
			debug << "  All parameters of 5 doraemons at every single door  " << endl;
			debug << "======================================================" << endl;
			debug << "        doraemon_id  size  iq_score  eq_score" << endl;
			debug << "door 0: " << setw(7) << doraemon_id[0] << setw(10) << size[0] << setw(8) << iq_score[0] << setw(9) << eq_score[0] << endl;
			debug << "door 1: " << setw(7) << doraemon_id[1] << setw(10) << size[1] << setw(8) << iq_score[1] << setw(9) << eq_score[1] << endl;
			debug << "door 2: " << setw(7) << doraemon_id[2] << setw(10) << size[2] << setw(8) << iq_score[2] << setw(9) << eq_score[2] << endl;
			debug << "door 3: " << setw(7) << doraemon_id[3] << setw(10) << size[3] << setw(8) << iq_score[3] << setw(9) << eq_score[3] << endl;
			debug << "door 4: " << setw(7) << doraemon_id[4] << setw(10) << size[4] << setw(8) << iq_score[4] << setw(9) << eq_score[4] << endl;
			debug << endl;
			debug << "======================================================" << endl;
			debug << "                     All 3 weights                    " << endl;
			debug << "======================================================" << endl;
			debug << "size_weight = " << size_weight << endl;
			debug << "iq_weight   = " << iq_weight << endl;
			debug << "eq_weight   = " << eq_weight << endl;
			debug << endl;
			debug << "=======================================================" << endl;
			debug << "  Prefernce score of 5 doraemons at every single door  " << endl;
			debug << "=======================================================" << endl;
			debug << "        size_weight * size + iq_weight * iq_score + eq_weight * eq_score = prefernce score" << endl;
			debug << "door 0: " << setw(7) << size_weight << setw(6) << "*" << setw(5) << size[0] << setw(2) << "+" << setw(7) << iq_weight << setw(5) << "*" << setw(7) << iq_score[0] << setw(4) << "+" << setw(7) << eq_weight << setw(5) << "*" << setw(7) << eq_score[0] << "   = " << preferenceScore0 << endl;
			debug << "door 1: " << setw(7) << size_weight << setw(6) << "*" << setw(5) << size[1] << setw(2) << "+" << setw(7) << iq_weight << setw(5) << "*" << setw(7) << iq_score[1] << setw(4) << "+" << setw(7) << eq_weight << setw(5) << "*" << setw(7) << eq_score[1] << "   = " << preferenceScore1 << endl;
			debug << "door 2: " << setw(7) << size_weight << setw(6) << "*" << setw(5) << size[2] << setw(2) << "+" << setw(7) << iq_weight << setw(5) << "*" << setw(7) << iq_score[2] << setw(4) << "+" << setw(7) << eq_weight << setw(5) << "*" << setw(7) << eq_score[2] << "   = " << preferenceScore2 << endl;
			debug << "door 3: " << setw(7) << size_weight << setw(6) << "*" << setw(5) << size[3] << setw(2) << "+" << setw(7) << iq_weight << setw(5) << "*" << setw(7) << iq_score[3] << setw(4) << "+" << setw(7) << eq_weight << setw(5) << "*" << setw(7) << eq_score[3] << "   = " << preferenceScore3 << endl;
			debug << "door 4: " << setw(7) << size_weight << setw(6) << "*" << setw(5) << size[4] << setw(2) << "+" << setw(7) << iq_weight << setw(5) << "*" << setw(7) << iq_score[4] << setw(4) << "+" << setw(7) << eq_weight << setw(5) << "*" << setw(7) << eq_score[4] << "   = " << preferenceScore4 << endl;
			debug << endl;
			debug << "=======================================================" << endl;
			debug << "                      Golden Answer                    " << endl;
			debug << "=======================================================" << endl;
			debug << "out = {door_number, doraemon_id} = {" << golden_ans_door << ", " << golden_ans_doraemon_id << "}" << endl;
		}
	}


	input.close();
	output.close();
	debug.close();

	return 0;
}
