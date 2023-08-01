bool isWhite(int index) {
  int x = index ~/ 8; //this give us the integer division ie.row
  int y = index % 8; //this give us the remainder ie.column

  bool isWhite = (x + y) % 2 == 0; //alternate colors for each square

  return isWhite;
}

bool isInBoard(int row, int column) {
  return row >= 0 && row < 8 && column >= 0 && column < 8;
}
