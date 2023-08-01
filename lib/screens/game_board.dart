import 'package:chess/components/dead_piece.dart';
import 'package:chess/components/piece.dart';
import 'package:chess/components/square.dart';
import 'package:chess/helper/helper_methods.dart';
import 'package:flutter/material.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
//A 2D list representing the chessboard,
//with each position possibly containing a chess piece
  late List<List<ChessPiece?>> board;

//currently selected piece on chess board
//if no piece is selected , its be null
  ChessPiece? selectedPiece;

  //the row index of the selected piece
  //Default value -1 indicates no piece is currently selected
  int selectedRow = -1;

  //the column index of the selected piece
  //Default value -1 indicates no piece is currently selected
  int selectedColumn = -1;

  //A list of valid moves for currently seleceted piece
  //each move is represented as a list with 2 elements:row and column
  List<List<int>> validMoves = [];

  //A list of white pieces killed by black
  List<ChessPiece> whitePieceTaken = [];

  //A list of black pieces killed by white
  List<ChessPiece> blackPieceTaken = [];

  //a boolean to indicate whose turn it is..
  bool isWhiteTurn = true;

  //initial positions of kings(keep track of this to make it easiar later to see if king is in check?)
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;

  @override
  void initState() {
    super.initState();
    initializeBoard();
  }

  //initialize the board
  void initializeBoard() {
    //initialize the board with nulls,meaning no pieces in those positions
    late List<List<ChessPiece?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    // Place pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
        type: ChessPieceType.pawn,
        isWhite: false,
        imgPath: "assets/pawn.png",
      );
      newBoard[6][i] = ChessPiece(
        type: ChessPieceType.pawn,
        isWhite: true,
        imgPath: "assets/pawn.png",
      );
    }

    // Place rooks
    newBoard[0][0] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: false,
      imgPath: "assets/rook.png",
    );
    newBoard[0][7] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: false,
      imgPath: "assets/rook.png",
    );
    newBoard[7][0] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: true,
      imgPath: "assets/rook.png",
    );
    newBoard[7][7] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: true,
      imgPath: "assets/rook.png",
    );
    // Place knights
    newBoard[0][1] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: false,
      imgPath: "assets/knight.png",
    );
    newBoard[0][6] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: false,
      imgPath: "assets/knight.png",
    );
    newBoard[7][1] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: true,
      imgPath: "assets/knight.png",
    );
    newBoard[7][6] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: true,
      imgPath: "assets/knight.png",
    );
    // Place bishops
    newBoard[0][2] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: false,
      imgPath: "assets/bishop.png",
    );
    newBoard[0][5] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: false,
      imgPath: "assets/bishop.png",
    );
    newBoard[7][2] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: true,
      imgPath: "assets/bishop.png",
    );
    newBoard[7][5] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: true,
      imgPath: "assets/bishop.png",
    );

    // Place queens
    newBoard[0][3] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: false,
      imgPath: "assets/queen.png",
    );
    newBoard[7][3] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: true,
      imgPath: "assets/queen.png",
    );
    // Place kings
    newBoard[0][4] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: false,
      imgPath: "assets/king.png",
    );
    newBoard[7][4] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: true,
      imgPath: "assets/king.png",
    );

    board = newBoard;
  }

//user selected a piece
  void pieceSelected(int row, int column) {
    setState(() {
      // No piece has been selected yet, this is the first selection
      if (selectedPiece == null && board[row][column] != null) {
        if (board[row][column]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][column];
          selectedRow = row;
          selectedColumn = column;
        }
      }

      //There is a piece already selected,but user can select another one
      else if (board[row][column] != null &&
          board[row][column]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][column];
        selectedRow = row;
        selectedColumn = column;
      }
      //if there is a piece selected and user taps on a square that is a valid move, move there
      else if (selectedPiece != null &&
          validMoves
              .any((element) => element[0] == row && element[1] == column)) {
        movePiece(row, column);
      }

      //if a piece is selected,calculate its valid moves
      validMoves = calculateRealValidMoves(
          selectedRow, selectedColumn, selectedPiece, true);
    });
  }

  //calculate row valid moves
  List<List<int>> calculateRawValidMoves(
      int row, int column, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];

    if (piece == null) {
      return [];
    }

    //different directions based on their color
    int direction = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
        // pawn can move forward if the square is empty

        if (isInBoard(row + direction, column) &&
            board[row + direction][column] == null) {
          candidateMoves.add([row + direction, column]);
        }

        // pawn can move 2 squares forward from their initial positions
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, column) &&
              board[row + 2 * direction][column] == null &&
              board[row + direction][column] == null) {
            candidateMoves.add([row + 2 * direction, column]);
          }
        }

        // pawn can kill diagonally

        if (isInBoard(row + direction, column - 1) &&
            board[row + direction][column - 1] != null &&
            board[row + direction][column - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, column - 1]);
        }
        if (isInBoard(row + direction, column + 1) &&
            board[row + direction][column + 1] != null &&
            board[row + direction][column + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, column + 1]);
        }

        break;
      case ChessPieceType.rook:

        // horizotal and vertical directions
        var directions = [
          [-1, 0], //up
          [1, 0], //down
          [0, -1], //left
          [0, 1], //right
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newColumn = column + i * direction[1];

            if (!isInBoard(newRow, newColumn)) {
              break;
            }
            if (board[newRow][newColumn] != null) {
              if (board[newRow][newColumn]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newColumn]); //kill
              }
              break; //blocked
            }
            candidateMoves.add([newRow, newColumn]);
            i++;
          }
        }
        break;
      case ChessPieceType.knight:

        //all 8 possible L shape
        var knightMove = [
          [-2, -1], //up 2 left 1
          [-2, 1], //up 2 right 1
          [2, -1], //down 2 left 1
          [2, 1], //down 2 right 1
          [-1, -2], //up 1 left 2
          [-1, 2], //up 1 right 2
          [1, -2], //down 1 left 2
          [1, 2], //down 1 right2
        ];

        for (var move in knightMove) {
          var newRow = row + move[0];
          var newColumn = column + move[1];
          if (!isInBoard(newRow, newColumn)) {
            continue;
          }
          if (board[newRow][newColumn] != null) {
            if (board[newRow][newColumn]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newColumn]); //capture
            }
            continue; //blocked
          }
          candidateMoves.add([newRow, newColumn]);
        }
        break;
      case ChessPieceType.bishop:

        //Diagonal directions
        var directions = [
          [-1, -1], //up left
          [1, -1], //down left
          [-1, 1], //up right
          [1, 1], //down right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newColumn = column + i * direction[1];
            if (!isInBoard(newRow, newColumn)) {
              break;
            }
            if (board[newRow][newColumn] != null) {
              if (board[newRow][newColumn]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newColumn]); //capture
              }
              break; //block
            }
            candidateMoves.add([newRow, newColumn]);
            i++;
          }
        }
        break;
      case ChessPieceType.queen:

        // All 8 directions:up,down,left,right,4 diagonals
        var directions = [
          [-1, 0], //up
          [1, 0], //down
          [0, 1], //right
          [0, -1], //left
          [-1, -1], //up left
          [-1, 1], //up right
          [1, 1], //down right
          [1, -1], //down left
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newColumn = column + i * direction[1];
            if (!isInBoard(newRow, newColumn)) {
              break;
            }
            if (board[newRow][newColumn] != null) {
              if (board[newRow][newColumn]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newColumn]); //capture
              }
              break; //block
            }
            candidateMoves.add([newRow, newColumn]);
            i++;
          }
        }

        break;
      case ChessPieceType.king:

        //All 8 directions
        var directions = [
          [-1, 0], //up
          [1, 0], //down
          [0, 1], //right
          [0, -1], //left
          [-1, -1], //up left
          [-1, 1], //up right
          [1, 1], //down right
          [1, -1], //down left
        ];
        for (var direction in directions) {
          var newRow = row + direction[0];
          var newColumn = column + direction[1];
          if (!isInBoard(newRow, newColumn)) {
            continue;
          }
          if (board[newRow][newColumn] != null) {
            if (board[newRow][newColumn]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newColumn]); //capture
            }
            continue; //blocked
          }
          candidateMoves.add([newRow, newColumn]);
        }

        break;
      default:
    }
    return candidateMoves;
  }

// calculate real valid moves
  List<List<int>> calculateRealValidMoves(
      int row, int column, ChessPiece? piece, bool checkSimulation) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, column, piece);

    //after generating all candidate moves , filter out any that would result in a check
    if (checkSimulation) {
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endColumn = move[1];
        //it will simulate the future move to see if it is safe
        if (simulateMoveIsSafe(piece!, row, column, endRow, endColumn)) {
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = candidateMoves;
    }
    return realValidMoves;
  }

  //move piece
  void movePiece(int newRow, int newColumn) {
    //if the new spot has an enemy piece
    if (board[newRow][newColumn] != null) {
      //add the captured piece to the appropriate list
      var capturedPiece = board[newRow][newColumn];
      if (capturedPiece!.isWhite) {
        whitePieceTaken.add(capturedPiece);
      } else {
        blackPieceTaken.add(capturedPiece);
      }
    }

    //check if the piece being moved in a king
    if (selectedPiece!.type == ChessPieceType.king) {
      //update the appropriate king's position
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [newRow, newColumn];
      } else {
        blackKingPosition = [newRow, newColumn];
      }
    }

    // move the piece and clear the old spot
    board[newRow][newColumn] = selectedPiece;
    board[selectedRow][selectedColumn] = null;

    //see if any kings are under attack
    if (isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    // clear selection
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedColumn = -1;
      validMoves = [];
    });

    //check if it is checkmate
    if (isCheckMate(!isWhiteTurn)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            "CHECKMATE!...",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            //play again button
            TextButton(
              onPressed: resetGame,
              child: Text('Play Again'),
            ),
          ],
        ),
      );
    }

    //change turns
    isWhiteTurn = !isWhiteTurn;
  }

  //Is king in check?
  bool isKingInCheck(bool isWhiteKing) {
    //get the position of the king
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

    //check if any enemy piece can attack the king
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        //skip empty squares and pieces of the same colour as the king
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }
        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], false);

        //Check if the king's position is in this piece's valid moves
        if (pieceValidMoves.any((move) =>
            move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }
    return false;
  }

//simulate a future move to see if it is safe(does not put your own king under attack)
  bool simulateMoveIsSafe(
    ChessPiece piece,
    int startRow,
    int startColumn,
    int endRow,
    int endColumn,
  ) {
    //save the current board state
    ChessPiece? originalDestinationPiece = board[endRow][endColumn];

    //if the piece is the king ,save it's current position and update to the new one
    List<int>? originalKingPosition;
    if (piece.type == ChessPieceType.king) {
      originalKingPosition =
          piece.isWhite ? whiteKingPosition : blackKingPosition;

      //update the king position
      if (piece.isWhite) {
        whiteKingPosition = [endRow, endColumn];
      } else {
        blackKingPosition = [endRow, endColumn];
      }
    }

    //simulate the move
    board[endRow][endColumn] = piece;
    board[startRow][startColumn] = null;

    //check if our own king is under attack
    bool kingInCheck = isKingInCheck(piece.isWhite);

    //restore board to original state
    board[startRow][startColumn] = piece;
    board[endRow][endColumn] = originalDestinationPiece;

    //if the piece was the king,restore it's original position
    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }
    //if king is in check=true ,means it is not a safe move,safemove = false
    return !kingInCheck;
  }

  //IS IT CHECKMATE?
  bool isCheckMate(bool isWhiteKing) {
    //if the king is not in check,then it's not checkmate
    if (!isKingInCheck(isWhiteKing)) {
      return false;
    }

    //if there is atleast one legal move for any of the player's pieces,then it's not checkmate
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        //skip empty squares and pieces of the other color
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }
        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], true);
        //if this piece has any valid move,then it's not checkmate
        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }

    //if none of the above conditions are met, then there is no legal move left to make,that's checkmate!

    return true;
  }

  //Reset to new game
  void resetGame() {
    Navigator.pop(context);
    initializeBoard();
    checkStatus = false;
    whitePieceTaken.clear();
    blackPieceTaken.clear();
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
    isWhiteTurn = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Column(
        children: [
          //WHITE PIECE TAKEN
          Expanded(
            child: GridView.builder(
              itemCount: whitePieceTaken.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) => DeadPiece(
                imgPath: whitePieceTaken[index].imgPath,
                isWhite: true,
              ),
            ),
          ),

          //GAME STATUS
          Text(
            checkStatus ? "CHECK!" : "",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),

          //CHESS BOARD
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: 8 * 8,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemBuilder: (context, index) {
                //get row and column position of this square
                int row = index ~/ 8;
                int column = index % 8;

                //check if this square is selected
                bool isSelected =
                    selectedRow == row && selectedColumn == column;

                //check if this square is a valid move
                bool isValidMove = false;
                for (var position in validMoves) {
                  //compare row and column
                  if (position[0] == row && position[1] == column) {
                    isValidMove = true;
                  }
                }

                return Square(
                  isWhite: isWhite(index),
                  piece: board[row][column],
                  isSelected: isSelected,
                  isValidMove: isValidMove,
                  onTap: () => pieceSelected(row, column),
                );
              },
            ),
          ),

          //BLACK PIECE TAKEN
          Expanded(
            child: GridView.builder(
              itemCount: blackPieceTaken.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) => DeadPiece(
                imgPath: blackPieceTaken[index].imgPath,
                isWhite: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
