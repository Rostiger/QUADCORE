class Colors {

	color bg, solid, node1, node2, item, hudBg;
	color[] player = new color[4];
	color[] player2 = new color[4];

	Colors() {}

	void pickColorScheme(String _name) {
		String name = _name;
		int numberOfColorShemes = 4;
		int colorScheme = 0;

		player[0] = #F13687;
		player[1] = #F1F187;
		player[2] = #2fff3a;
		player[3] = #31ccff;

		if (name == "DEFAULT") colorScheme = 1;
		else if (name == "RUSSIAN") colorScheme = 2;
		else if (name == "OCEAN") colorScheme = 3;
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
			break;
			case 2:
				bg = #3D3356;
				solid = #BA365D;
				node1 = #78475C;
				node2 = #AB68A3;
				item = #EDA8C6;
				item = #C082FF;
			break;
			case 3:
				bg = #0A3542;
				solid = #335C64;
				node1 = #0A3542;
				node2 = #5C4A56;
				item = #7895A4;
			break;
			case 4:
				bg = #6D1B75;
				solid = #B04DA1;
				node1 = #AB5BB3;
				node2 = #AB5BB3;
				item = #D69DC9;
			break;
		}
	}
}