package pacman.game;

import pacman.board.BoardItem;
import pacman.board.PacmanBoard;
import pacman.ghost.Ghost;
import pacman.ghost.Phase;
import pacman.hunter.*;
import pacman.util.*;
import java.io.*;
import java.util.*;

public class GameReader {
    //store entries at each position of the board,size in PacmanBoard.height;
    private static List<String> boardEntries = new ArrayList<>();
    //store board dimentions, size for 1.
    private static ArrayList<String> boardDimensions = new ArrayList<>();
    //store all the information for [Game] block, trivial attributes, hunter and ghosts respectively.
    //size for 11 in total(including blank line in the end), trivialAttributes size in 5, hunter in 1, and ghosts in 4.
    private static ArrayList<String> gameInformation = new ArrayList<>();
    //store scores information for other users.
    private static ArrayList<String> scoresInformation = new ArrayList<>();

    /**
     * Reads in a game according to the the following specification.
     * Assignment Definitions
     * Name	Value format
     * title	string
     * author	string
     * lives	Integer greater than or equal to zero
     * level	Integer greater than or equal to zero
     * score	Integer greater than or equal to zero
     * hunter	A comma separated list of attributes in the following order:
     * x, y, DIRECTION, special duration, HunterType
     * blinky|inky|pinky|clyde	A comma separated list of attributes in the following order:
     * x,y,DIRECTION,PHASE:PhaseDuration
     *
     * @param reader to read the save game from.
     * @return a PacmanGame that reflects the state from the reader.
     * @throws IOException when unable to read from the reader.
     */
    public static PacmanGame read(Reader reader) throws IOException, UnpackableException {
        //get Informationrmation from reader.
        getInformation(reader);
        //set board size
        PacmanBoard board = setBoardDimension();
        String[] trivialInformation = setTrivial();
        //set the hunter
        var temp = gameInformation.get(5).split("=")[1];
        var hunterInformation = temp.split(",");
        Hunter hunter = setHunter(hunterInformation);
        //setup game
        String title = trivialInformation[0];
        String author = trivialInformation[1];
        PacmanGame game = new PacmanGame(title, author, hunter, board);
        //set board entries
        setBoardEntries(game);
        //set trivial attributes
        int lives = Integer.parseInt(trivialInformation[2].strip());
        int level = Integer.parseInt(trivialInformation[3].strip());
        int score = Integer.parseInt(trivialInformation[4].strip());
        game.setLevel(level);
        game.setLives(lives);
        game.getScores().increaseScore(score);
        //set scores
        setGameScores(game);
        //set ghosts.
        setGhosts(game);
        return game;
    }

    /*
        get string of Information from game reader.
    */
    private static void getInformation(Reader reader) throws IOException, UnpackableException {
        BufferedReader br = (BufferedReader) reader;
        var Information = new ArrayList<String>();
        var line = br.readLine();

        while (line != null) {
            //get board information
            if (line.equals("[Board]")) {
                line = br.readLine();
                //stop when line starts with "X"
                while (!line.startsWith("X")) {
                    //ignore ";" commenting
                    if (!line.startsWith(";")) {
                        //board dimensionally initializing
                        boardDimensions.add(line);
                        line = br.readLine();
                    } else {
                        line = br.readLine();
                    }
                }
                //continue from line starts with "X" and ends in "[Game]" block
                while (!line.startsWith("[Game]")) {
                    //ignore ";" commenting
                    if (!line.startsWith(";")) {
                        // board entries information stored
                        boardEntries.add(line);
                        line = br.readLine();
                    } else {
                        line = br.readLine();
                    }
                }
                //"[Board]" block read finishing.
            }
            //"[Game]" block read starts
            if (line.equals("[Game]")) {
                line = br.readLine();
                // block read continues til "[Scores]" block reached
                while (!line.equals("[Scores]")) {
                    ////ignore ";" commenting
                    if (!line.startsWith(";")) {
                        // game information stored, having trivial attributes, hunter and ghosts included in.
                        gameInformation.add(line);
                        line = br.readLine();
                    } else {
                        line = br.readLine();
                    }
                }
            }
            //"[Scores]" block read starts
            if (line.equals("[Scores]")) {
                line = br.readLine();
                //block read continues til reaching end of the file.
                while (line != null) {
                    if (!line.startsWith(";")) {
                        //scores information added
                        scoresInformation.add(line);
                        line = br.readLine();
                    } else {
                        line = br.readLine();
                    }
                }
                break;
            }
            // this section gets called only before "[Board]" block
            if (line.startsWith(";")) {
                line = br.readLine();
            } else {
                //unexpected lines appear resulting UnpackableException thrown.
                throw new UnpackableException("Invalid lines before Game block.");
            }
        }
    }

    /*
    set width and height for a pacman game using board Information.
     */
    private static PacmanBoard setBoardDimension() throws NullPointerException, UnpackableException {
        //check redundancy to make sure there is only one pair existing.
        if (boardDimensions.size() != 1) {
            throw new UnpackableException("redundant assigning for PacmanBoard");
        }
        try {
            //get width and height by converting String to int.
            int width = Integer.parseInt(boardDimensions.get(0).split(",")[0]);
            int height = Integer.parseInt(boardDimensions.get(0).split(",")[1]);
            //unreasonable dimensions case
            if (width < 0 || height < 0) {
                throw new UnpackableException("Board dimensions must be greater than zero");
            } else {
                return new PacmanBoard(width, height);
            }
        // exception thrown only when dimension converting failed due to illegal dimension format.
        } catch (NumberFormatException nfe) {
            throw new UnpackableException("illegal format for width and height.");
        }
    }

    /*
    initialize entries for a pacman game using board entries.
     */
    private static void setBoardEntries(PacmanGame game) throws UnpackableException {
        //check blank line between [Board] and [Game]
        if (!boardEntries.get(boardEntries.size() - 1).equals("")) {
            throw new UnpackableException(" Missing blank line between blocks");
        }
        int width = boardEntries.get(0).length();
        for (int i = 0; i < width; i++) {
            //check first row of board.
            if (boardEntries.get(0).charAt(i) != 'X') {
                throw new UnpackableException("Illegal entry(ies) on top of the map");
            }
        }
        // check last row of board.
        if (!boardEntries.get(0).equals(boardEntries.get(boardEntries.size() - 2))) {
            throw new UnpackableException("Illegal entry(ies) on bottom of the map");
        }
        //
        for (int j = 1; j < boardEntries.size() - 3; j++) {
            var line = boardEntries.get(j);
            //check board width validity
            if (line.length() < width) {
                throw new UnpackableException(String.format("Row %d of board is too short",j));
            } else if (line.length() > width) {
                throw new UnpackableException(String.format("Row %d of board is too long",j));
            }
            for (int i = 0; i < width; i++) {
                try {
                    //assertion fail when non-wall entry(ies) existing on left(right) of board.
                    List<Character> chars = new ArrayList<>(7);
                    assert (line.charAt(0) == line.charAt(width - 1) && line.charAt(width - 1) == 'X');
                    for (BoardItem item : BoardItem.values()) {
                        chars.add(item.getChar());
                        if (line.charAt(i) == item.getChar()) {
                            game.getBoard().setEntry(new Position(i, j), item);
                            break;
                        }
                    }
                    // invalid charKey when not contained in the char list.
                    if (!chars.contains(line.charAt(i))){
                        throw new UnpackableException(String.format
                                ("%c at (%d,%d) is not a valid BoardItem key",line.charAt(i),i,j));
                    }
                //assertion error thrown
                } catch (AssertionError ae) {
                    throw new UnpackableException("Illegal entry(ies) on left(right) border of the map");
                }
            }
        }
    }

    /*
    set trivial attributes for a pacman game, including author, title, live, level, and score.
     */
        private static String[] setTrivial () throws UnpackableException {
            //get trivial attributes information from game information.
            List<String> trivialInformation = gameInformation.subList(0,5);
            //blank between [Game] and [Scores] checked.
            if (!gameInformation.get(gameInformation.size() - 1).equals("")) {
                throw new UnpackableException("Must have one blank line between each block.");
            }
            //game board valid size checking.
            if (gameInformation.size() > 11) {
                throw new UnpackableException("duplicated attributes assigning appear.");
            }
            //order trivial attributes as standard file represents.
            String[] trivial = {"title", "author", "lives", "level", "score"};
            // arrays of values for attributes storing initialized
            String[] trivialValues = new String[trivialInformation.size()];
            //extract single attribute each time from trivialInformation that derives from reader
            for (int i = 0; i < trivialInformation.size(); i++) {
                var attribute = trivialInformation.get(i).split("=")[0].strip();
                //value assigning each time when attribute matched, exception thrown otherwise.
                if (attribute.equals(trivial[i])) {
                    //extract value of current trivial attribute
                    trivialValues[i] = trivialInformation.get(i).split("=")[1];
                    try {
                        //check convert when i > 1(cases where lives(num), level(num) and scores(num) are assigned).
                        if (i > 1 && Integer.parseInt(trivialValues[i].strip()) < 0) {
                            throw new UnpackableException(String.
                                    format("%s must be a non-negative integer", trivial[i]));
                        }
                    //catch and handle convert failure by throwing UnpackbleException with message.
                    }catch (NumberFormatException nfe) {
                        throw new UnpackableException(String.format("%s must be a non-negative integer", trivial[i]));
                    }
                } else {
                        //throw exception when attributes are not orderly matched.
                        throw new UnpackableException(String.format("%s assignment is missing", trivial[i]));
                }
            }
           return trivialValues;
        }

    /*
    set hunters for a pacman game using hunter Information.
     */
    private static Hunter setHunter(String[] hunterInformation) throws UnpackableException {
        try {
            //get position
            Position hunterPosition = new Position(Integer.parseInt(hunterInformation[0].strip()),
                    Integer.parseInt(hunterInformation[1].strip()));
            //get direction
            Direction hunterDirection = Direction.valueOf(hunterInformation[2]);
            //get duration
            int duration = Integer.parseInt(hunterInformation[3].strip());
            // throw exception when position coordinates are negative
            if (hunterPosition.getX() < 0 || hunterPosition.getY() < 0) {
                throw new UnpackableException("Hunter's position is outside the board's dimensions");
            }
            Hunter hunter;
            //get hunter type.
            switch(hunterInformation[4]) {
                case "HUNGERY":
                    hunter = new Hungry();
                    break;
                case "PHASEY":
                    hunter = new Phasey();
                    break;
                case "PHIL":
                    hunter = new Phil();
                    break;
                case "SPPEDY":
                    hunter = new Speedy();
                    break;
                default:
                    throw new UnpackableException("Unexpected value: " + hunterInformation[4]);
            }
            //set hunter
            hunter.setPosition(hunterPosition);
            hunter.setDirection(hunterDirection);
            hunter.activateSpecial(duration);
            return hunter;
        //position is formally wrong
        } catch (NumberFormatException nfePosition) {
            throw new UnpackableException("invalid format for hunter position or special duration.");
        //no position matched
        } catch (IllegalArgumentException iaeDirection) {
            throw new UnpackableException(String.format("No enum constant %s",hunterInformation[2]));
        //uncompleted hunter attribute(s)
        } catch (ArrayIndexOutOfBoundsException hunterType) {
            throw new UnpackableException("Hunter attribute(s) missing.");
        }
    }

    private static void setGameScores(PacmanGame game) throws UnpackableException {
        try {
            for (int i = 0; i < scoresInformation.size(); i++) {
                //get player score
                var score = Integer.parseInt(scoresInformation.get(i).split(":")[1].strip());
                //throw exception when having invalid score
                if (score < 0) {
                    throw new UnpackableException("score must be a non-negative integer");
                }
                //assign otherwise
                game.getScores().setScore(scoresInformation.get(i).split(":")[0], score);
            }
        //convert failed.
        } catch (NumberFormatException nfe) {
            throw new UnpackableException("Score values must be an integer");
        }
    }

    private static void setGhosts(PacmanGame game) throws UnpackableException {
        //retrieve ghost information from game information
        List<String> ghostsInformation = gameInformation.subList(6,10);
        List<String> ghosts = new ArrayList<>(Arrays.asList("blinky", "inky", "pinky", "clyde"));
        //arrays for temporarily ghost values storing
        String[] ghostsValues = new String[ghostsInformation.size()];

        for (int i = 0; i < ghostsInformation.size(); i++) {
            var name = ghostsInformation.get(i).split("=")[0].strip();
            //check name validity
            if (ghosts.contains(name)) {
                ghostsValues[i] = ghostsInformation.get(i).split("=")[1];
                try {
                    //extract each ghost value from ghostValues
                    String[] ghostValue = ghostsValues[i].split(",");
                    //promise for ghost value completion
                    assert(ghostValue.length == 4);
                    for (Ghost ghost : game.getGhosts()) {
                        //ghost value assigning when name matched
                        if (ghost.getClass().getSimpleName().equalsIgnoreCase(name)) {
                            try {
                                //assert completion for phase and its duration
                                assert(ghostValue[3].split(":").length == 2);
                                var ghostX = Integer.parseInt(ghostValue[0].strip());
                                var ghostY = Integer.parseInt(ghostValue[1].strip());
                                //invalid position coordinates
                                if (ghostX < 0 || ghostY < 0) {
                                    throw new UnpackableException(String.format(
                                            "%s position is outside the board's dimensions", name));
                                }
                                ghost.setPosition(new Position(ghostX, ghostY));
                                //set direction
                                ghost.setDirection(Direction.valueOf(ghostValue[2]));
                            } catch (NumberFormatException nfePosition) {
                                throw new UnpackableException(String.format(
                                        "position of %s must be a non-negative integer", ghosts.get(i)));
                            //direction set fail due to Enum not matching.
                            } catch (IllegalArgumentException iaeDirection) {
                                throw new UnpackableException(String.format("No direction matches in %s",name));
                            //assert fail due to phase missing
                            } catch (AssertionError aePhase) {
                                throw new UnpackableException(String.format("%s having phase element missing",name));
                            }
                            //get phase otherwise
                            String phase = ghostValue[3].split(":")[0];
                            //get duration otherwise
                            int duration = Integer.parseInt(ghostValue[3].split(":")[1]);
                            //set phase and duration
                            ghost.setPhase(Phase.valueOf(phase), duration);
                        }
                    }
                //promise fail due to some missing value
                } catch (AssertionError ae) {
                    throw new UnpackableException(String.format("%s having value(s) missing",name));
                }
                //exception when duration is formally wrong
                catch (NumberFormatException nfeDuration) {
                    throw new UnpackableException(String.format(
                            "duration of %s must be a non-negative integer", ghosts.get(i)));
                //exception due to Enum not matching phase
                } catch (IllegalArgumentException iaePhase) {
                    throw new UnpackableException(String.format("not a valid PhaseType in %s",name));
                }
        } else {
                //ghost assigning missing due to unexpected name
                throw new UnpackableException(String.format("%s assignment is missing", ghosts.get(i)));
            }
        }
    }
    public static void main (String[]args) throws IOException, UnpackableException {
        File file = new File("some address for input file");
        FileReader fr = new FileReader(file);
        BufferedReader reader = new BufferedReader(fr);
        PacmanGame game = read(reader);

    }

}
