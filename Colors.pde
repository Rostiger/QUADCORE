class Colors {

	color bg, solid, node1, node2, item, hudBg;
	color[] player = new color[4];
	String[] colorSchemes = new String[]{ "RANDOM", "DEFAULT", "RUSSIAN", "SWAMP", "CANDY" };

	Colors() {}

	void pickColorScheme(int _colorScheme) {
		int colorScheme = _colorScheme;

		player[0] = #F13687;
		player[1] = #F1F187;
		player[2] = #2fff3a;
		player[3] = #31ccff;

		// set a random color scheme
		if (colorScheme == 0) colorScheme = ceil(random(0,colorSchemes.length - 1));

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
				node1 = #6E4E87;
				node2 = #4F365B;
				item = #EDA8C6;
			break;
			case 3:
				bg = #0A3542;
				solid = #335C64;
				node1 = #3B6B73;
				node2 = #24465C;
				item = #78A9BC;
			break;
			case 4:
				bg = #773470;
				solid = #63186B;
				node1 = #BB54B7;
				node2 = #89176B;
				item = #D69DC9;
			break;
		}
	}
}