class Collision {
	boolean checkBoxCollision (
		float xPosA, float yPosA, float hSizeA, float vSizeA,
		float xPosB, float yPosB, float hSizeB, float vSizeB) {

		float aTop = yPosA;
		float aRight = xPosA + hSizeA;
		float aBottom = yPosA + vSizeA;
		float aLeft = xPosA;

		float bTop = yPosB;
		float bRight = xPosB + hSizeB;
		float bBottom = yPosB + vSizeB;
		float bLeft = xPosB;

		return (bRight > aLeft && aRight > bLeft && bBottom > aTop && aBottom > bTop);
	}
}