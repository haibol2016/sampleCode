package cs567.hw5;

/*
 * The only thing that you will actually need to solve the problem is the constructor
 * which is called by the means "new Alignment(x,y)" where x and y are strings
 * 
 * The additional fields and methods are for your (and my) convenience.
 */
public class Alignment {
  
  /*
   * use this field to designate blank characters
   */
  public static final char BLANK = '_';
  
  /*
   * these fields designate valid nucleotide characters
   */
  public static final char A = 'A';
  public static final char T = 'T';
  public static final char G = 'G';
  public static final char C = 'C';
  
  /*
   * the strings of the alignment
   */
  private String first;
  private String second;
  
  /*
   * creates an instance representing an alignment between the strings x and y
   * 
   * x and y are both Strings of nucleotides: 'A', 'T', 'C', and 'G'
   * also containing gaps as occurrences of Alignment.BLANK
   * 
   * both x and y must be the same length, and it cannot be the case that a BLANK 
   * is matched with a BLANK
   */
  public Alignment(String x, String y)
  {
    if (x.length() != y.length())
    {
      throw new IllegalArgumentException(x + " and " + y + " are not the same length.");
    }
    for (int i = 0; i < x.length(); i++)
    {
      char curX = x.charAt(i);
      char curY = y.charAt(i);
      if (curX == curY && curX == BLANK)
      { // we have aligned blanks, which is a no-no
        throw new IllegalArgumentException("invalid alignment: blank aligned with blank \n"
                                            + x + " -> " + y);
      }
      else
        if (curX != A && curX != T && curX != G && curX != C && curX != BLANK 
            || curY != A && curY != T && curY != G && curY != C && curY != BLANK)
        {
          throw new IllegalArgumentException("invalid alignment: existance of "
              + "non-nucleotide character \n" + x + " -> " + y);
        }
    }
    first = x;
    second = y;
  }
  
  /*
   * implements a simple scoring for this Alignment. The score is equal to the 
   * number of matching nucleotides.
   */
  public int score()
  {
    int s = 0;
    for (int i = 0; i < first.length(); i++)
    {
      if (first.charAt(i) == second.charAt(i))
      { 
        // it has already been guaranteed that blanks will not be matched
        s++;
      }
    }
    return s;
  }
  
  /*
   * returns the first String of the Alignment, including BLANKs
   */
  public String getFirst()
  {
    return first;
  }

  /*
   * returns the second String of the Alignment, including BLANKs
   */
  public String getSecond()
  {
    return second;
  }

  /*
   * returns the first String of the Alignment, excluding BLANKs i.e. the
   * original x
   */
  public String getX()
  {
    return first.replaceAll(BLANK + "", "");
  }

  /*
   * returns the second String of the Alignment, excluding BLANKs i.e. the
   * original y
   */
  public String getY()
  {
    return second.replaceAll(BLANK + "", "");
  }
  
  /*
   * pretty-prints the Alignment object as a three-lined String
   * 
   * (allows for the Alignment to be treated as a String object)
   * 
   * @see java.lang.Object#toString()
   */
  public String toString()
  {
    StringBuilder lineBuilder = new StringBuilder();
    for (int i = 0; i < first.length(); i++)
    {
      if (first.charAt(i) == second.charAt(i))
      {
        lineBuilder.append("|");
      }
      else
      {
        lineBuilder.append(" ");
      }
    }
    return first + "\n" + lineBuilder.toString() + "\n" + second;
  }
}
