package cs567.hw5;

public class AlignmentTest
{

  
   public static void main(String[] args)
   {
      String x = "CCATCGTT";
      String y = "GGATCGAA";
     
      Alignment a = SequenceAlignment.bestAlignment(x, y);
      System.out.println(a.getFirst()+" "+ a.getX());
      System.out.println(a.getSecond()+" "+ a.getY());
      
      System.out.println(a.score());
      
      System.out.println(a.toString());
      
   }
}
