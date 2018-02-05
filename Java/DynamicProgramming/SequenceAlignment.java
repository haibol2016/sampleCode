package cs567.hw5;


public class SequenceAlignment 
{
  
  /*
   * Takes as input two strings of nucleotides x and y
   * which may be of different length
   * 
   * (see Alignment.java for constants representing valid nucleotides)
   * 
   * returns an Alignment object representing an optimal alignment for x and y
   * 
   * (hint: Use dynamic programming to find the optimal locations to insert blank
   * characters (perhaps by using integer matrices).Create two new strings, placing
   * "Alignment.BLANK" (i.e. '_' underscore) characters in the appropriate locations
   * (as determined by your algorithm). Instantiate and return an Alignment object 
   * by calling its constructor on the two strings (using the "new" keyword: see 
   * Alignment.java for additional methods).)
   * 
   * For example, If x = ATTTT and y = TTTTCC,
   * we let x2 = ATTTT__ and y2 = _TTTTCC
   * then we return "new Alignment(x2,y2)"
   * 
   * note: we can store Alignments in variables of type "Alignment"
   * For example, 
   * 
   * "Alignment a = new Alignment(x2,y2);
   *  System.out.println(a);"
   * 
   * would result in the following string being printed to the console:
   * ATTTT__
   *  ||||  
   * _TTTTCC
   * 
   */
  public static Alignment bestAlignment(String x, String y)
  {
    // using 2 integer arrays of 2 dimensions (row * col) to store the scores and 
    // the direction, respectively
    int row = x.length();
    int col = y.length();
    
    // score array
    int[][] score = new int[row+1][col+1];
    
    // Path array
    String[][] path = new String[row+1][col+1];
    
    
    // initiate the first column of the score array
    for (int i = 0; i <= row; i++)
    {
      score[i][0]=0;
    }
    
    // initiate the first row of the score array
    for (int j =1; j<= col; j++)
    {
      score[0][j]=0;
    }
    
   
    // calculate the maximum scores for each other cell in the score 
    // array and record the alignment path
    for ( int i = 1; i <= row; i++)
    {
      char xchar = x.charAt(i-1);
      for (int j = 1; j <= col; j++ )
      {
        char ychar = y.charAt(j-1);
        if( xchar == ychar) 
        {
          score[i][j] = Math.max(score[i - 1][j - 1] + 1, Math.max(score[i - 1][j], score[i][j - 1]));
          if(score[i][j]== score[i-1][j-1]+1)
          {
            path[i][j] = "northwestern";
          }
          else if(score[i][j] == score[i-1][j])
          {
            path[i][j]="northern";
          }
          else
          {
            path[i][j]="western";
          }
        }
        else
        {
          score[i][j] = Math.max(score[i - 1][j], score[i][j - 1]);
          if(score[i][j] == score[i-1][j])
          {
            path[i][j]="northern";
          }
          else
          {
            path[i][j]="western";
          }
        }
      }
    }
    
    // get the 2 aligned strings by backtracking
    String[] aligned = convertPath2String(path, x, y);
    
    Alignment alignment = new Alignment(aligned[0], aligned[1]);
    return alignment;
  }
  
  /**
   * helper method used to retrieve the 2 aligned strings with "_" inserted in the 
   * appropriate locations in each string.
   * @param path  matrix recording the alignment path
   * @param x  the first input string to be aligned
   * @param y  the second string to be aligned
   * @return  an array consisting two aligned strings
   */
  private static String[] convertPath2String(String[][] path, String x, String y)
  {
    int row = x.length();
    int col = y.length();
    
    StringBuilder sbX = new StringBuilder("");
    StringBuilder sbY = new StringBuilder("");
    
    while ( row > 0 && col > 0)
    {
      //match between x.charAt(row-1) and y.charAt(col-1)
      if (path[row][col].equals("northwestern"))
      {
        sbX.insert(0, x.charAt(row-1));
        sbY.insert(0, y.charAt(col-1));
        row--;
        col--;
      }
     //insertion occur to string y, add "_" to x at the corresponding position
      else if(path[row][col].equals("western"))
      {
        sbX.insert(0, Alignment.BLANK);
        sbY.insert(0, y.charAt(col-1));
        col--;
      }
      //insertion occur to string x, add "_" to y at the corresponding position
      else
      {
          sbX.insert(0, x.charAt(row-1));
          sbY.insert(0, Alignment.BLANK);
          row--;
      }
    }
    
    // first character in String x has been reached
    if (row == 0 && col >=0)
    {
      // if there are still some characters in string y has not been reached, while
      // string x has run out.So blank has to be added to the beginning of string x.
      for (int i = col; i >= 1; i--)
      {
        sbX.insert(0, Alignment.BLANK);
        sbY.insert(0, y.charAt(col - 1));
      }
    }
    
    // first character in String y has been reached
    if (col == 0 && row >0)  
    {
      // there are still some characters in string x has run out,while string y 
      // has run out.So blank has to be added to the beginning of string y.
      for (int i = row; i >= 1; i--)
      {
        sbX.insert(0, x.charAt(row - 1));
        sbY.insert(0, Alignment.BLANK);
      }
    }
    String[] alignedSeq = new String[]{sbX.toString(), sbY.toString()};
    
    return alignedSeq;
  }
}
