class Colors {

	color bg, solid, node1, node2, item, hudBg;
	color[] player = new color[4];
	color[] player2 = new color[4];

	Colors() {}

	void pickColorScheme(String _name) {
		String name = _name;
		int numberOfColorShemes = 4;
		int colorScheme = 0;

		if (name == "DARK_PURPLE") colorScheme = 1;
		else if (name == "VIOLET_BLUE") colorScheme = 2;
		else if (name == "PURPLE_YELLOW") colorScheme = 3;
		else if (name == "BLUE_ORANGE") colorScheme = 4;
		else if (name == "RANDOM") {
			colorScheme = ceil(random(0,numberOfColorShemes));
		} else {
			println("CAN'T FIND COLOR SCHEME");
			colorScheme = 1;
		}

		switch (colorScheme) {
			case 1:
				bg = #6B4EAC;
				solid = #5039A9;
				node1 = #8A80DF;
				node2 = #574CA5;
				item = #C082FF;
				player[0] = #F13687;
				player[1] = #F1F187;
				player[2] = #20F187;
				player[3] = #31ccff;
				player2[0] = #ff76aa;
				player2[1] = #ffffbf;
				player2[2] = #66ffb1;
				player2[3] = #8be2ff;
			break;
			case 2:
				bg = #69D6C0;
				solid = #755EA2;
				node1 = #B2A9CF;
				node2 = #766C98;
				player[0] = #C7506B;
				player[1] = #F0F25E;
				player[2] = #00960F;
				player[3] = #0080DB;
				player2[0] = #ff76aa;
				player2[1] = #ffffbf;
				player2[2] = #66ffb1;
				player2[3] = #8be2ff;
			break;
			case 3:
				bg = #DEE07B;
				solid = #9256B3;
				node1 = #9553B8;
				node2 = #AA77C9;
				player[0] = #BF345F;
				player[1] = #8A7138;
				player[2] = #6ABB00;
				player[3] = #2F8BFF;
				player2[0] = #ff76aa;
				player2[1] = #ffffbf;
				player2[2] = #66ffb1;
				player2[3] = #8be2ff;
			break;
			case 4:
				bg = #E0AF7F;
				solid = #5980B3;
				node1 = #5680B8;
				node2 = #7B9FC9;
				player[0] = #FE2CB1;
				player[1] = #FFEA29;
				player[2] = #7BF37C;
				player[3] = #2452FF;
				player2[0] = #ff76aa;
				player2[1] = #ffffbf;
				player2[2] = #66ffb1;
				player2[3] = #8be2ff;
			break;
		}
	}
}