#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>

using namespace std;

#define SEED 88
#define DRAMFILE "dram.dat"
#define START 65536
#define END 196608

int main()
{
	srand(SEED);
	ofstream dram;
	dram.open(DRAMFILE);
	
	unsigned int dram_data;
	string dram_data_str;

	// shop info
	int numLargeItems;
	int numMediumItems;
	int numSmallItems;
	int userLevel;
	int exp;

	// user info
	int money;
	int itemID;
	int numOfItems;
	int sellerID;

	// start to write DRAM data in dram.dat
	int dram_address = START;
	int idxUser = 0;
	while (dram_address < END)
	{
		// begin of shop info
		dram << "@" << hex << dram_address << endl;
		numLargeItems  = rand() % 64;
		numMediumItems = rand() % 64;
		numSmallItems  = rand() % 64;
		userLevel	   = rand() % 4;
		if (userLevel == 0)
		{
			exp = 0;
		}
		else if (userLevel == 1)
		{
			exp = rand() % 4000;
		}
		else if (userLevel == 2)
		{
			exp = rand() % 2500;
		}
		else if (userLevel == 3)
		{
			exp = rand() % 1000;
		}
		ostringstream shop_info_ss;
		dram_data = (numLargeItems << 26) + (numMediumItems << 20) + (numSmallItems << 14) + (userLevel << 12) + (exp);
		shop_info_ss << setw(8) << setfill('0') << hex << dram_data;
		dram_data_str = shop_info_ss.str();
		dram << dram_data_str[0] << dram_data_str[1] << " " << dram_data_str[2] << dram_data_str[3] << " " << dram_data_str[4] << dram_data_str[5] << " " << dram_data_str[6] << dram_data_str[7] << endl;
		// end of shop info
		dram_address += 4;
		// begin of user info
		dram << "@" << hex << dram_address << endl;
		money      = rand() % 65536;
		itemID     = rand() % 3 + 1; // 1 ~ 3
		numOfItems = rand() % 63 + 1; // 1 ~ 63
		sellerID   = rand() % 256;
		while (sellerID == idxUser)
		{
			sellerID = rand() % 256;
		}
		ostringstream user_info_ss;
		dram_data = (money << 16) + (itemID << 14) + (numOfItems << 8) + (sellerID);
		user_info_ss << setw(8) << setfill('0') << hex << dram_data;
		dram_data_str = user_info_ss.str();
		dram << dram_data_str[0] << dram_data_str[1] << " " << dram_data_str[2] << dram_data_str[3] << " " << dram_data_str[4] << dram_data_str[5] << " " << dram_data_str[6] << dram_data_str[7] << endl;
		// end of user info

		idxUser++;
		dram_address += 4;
	}

	dram.close();
	return 0;
}