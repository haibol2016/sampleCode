package cs567.hw5;

import java.util.LinkedList;
import java.util.Queue;

/**
 * This class models a silly elevator in a building of a given total number of floors, 
 * with floors numbered starting off 1. This elevator has only two buttons to control it: 
 * one is upward button. If it is pushed, it will bring the elevator x floors up; the 
 * other one (downward) if pushed will bring the elevator y floors down.
 * 
 * @author HAIBO LIU
 *
 */
public class Elevator
{
  /**
   * the lowest floor number
   */
  private static final int FIRSTFLOOR =1;
  
  /**
   * the total number of floors
   */
  private int numFloors;
  
  /**
   * the number of floors the elevator will go upward if the upward button is pushed
   */
  private int upButton;
  
  /**
   * the number of floors the elevator will go downward if the upward button is pushed
   */
  private int downButton;
  
  
  /**
   * constructor
   */
  public Elevator(int totalFloors, int up, int down)
  {
    if(totalFloors<=1 || up < 1 || down < 1 || totalFloors <= up || totalFloors <= down)
    {
      throw new IllegalArgumentException("Input number is not valid.");
    }
    
    numFloors = totalFloors;
    upButton = up;
    downButton =down;
  }
  
  
  /**
   * This method calculates the minimum number of button one has to push and minimum 
   * number of floors one has to pass from a given  floor to another given floor.
   * @param fromFloor the starting off floor
   * @param toFloor  the destination floor
   */
  public void take(int fromFloor, int toFloor)
  {
    if(fromFloor < 1 || fromFloor > numFloors || toFloor < 1 || toFloor > numFloors)
    {
      throw new IllegalArgumentException();
    }
    
    //using an array of Floor type to store the floors from 1 to the highest floor,
    //with the first element being null.
    int size = numFloors+1;
    Floor[] floors = new Floor[size];
    
    //initiate the array
    for (int i = 1; i<size; i++)
    {
      floors[i] = this.new Floor(i, false, Integer.MAX_VALUE, Integer.MAX_VALUE);
    }
    
    //using a queue to store to floor to be visited
    Queue<Floor> q = new LinkedList<Floor>();
    
    q.add(floors[fromFloor]);
    floors[fromFloor].isVisited= true;
    floors[fromFloor].minimumPush =0;
    floors[fromFloor].minimumTime =0;
    
    // if the destination floor has not been visited and the queue is not empty,
    // continue trying.
    while (!floors[toFloor].isVisited && !q.isEmpty())
    {
      Floor f = q.remove();
     
      int floorNum = f.floorNum;
      int upFloor = floorNum+upButton;
      int downFloor = floorNum-downButton;
      
      // the upward button is valid if the current floor number plus the number of floors the elevator
      // would go upward if the upward button was pushed is equal to or less than the largest floor 
      // number and the destination floor has not been visited.
      if (upFloor <= numFloors && !floors[upFloor].isVisited)
      {
        q.add(floors[upFloor]);
        floors[upFloor].isVisited = true;
        floors[upFloor].minimumPush = f.minimumPush +1;
        floors[upFloor].minimumTime = f.minimumTime +upButton;
      }
      
      // the downward button is valid if the current floor number minus the number of floors 
      // the elevator would go downward if the downward button was pushed is equal to or larger
      // than 1 and the destination floor has not been visited.
      if (downFloor >= FIRSTFLOOR && !floors[downFloor].isVisited)
      {
        q.add(floors[downFloor]);
        floors[downFloor].isVisited = true;
        floors[downFloor].minimumPush = f.minimumPush +1;
        floors[downFloor].minimumTime = f.minimumTime +downButton;
      }
    }
    System.out.println("The minimum number of buttons one has to press to get to floor " + toFloor +
                        " from floor " +fromFloor+ " is: "+ floors[toFloor].minimumPush);
    System.out.println("The shortest time one needs to get from foor "+ fromFloor +" to "
                        + toFloor +" is: " +floors[toFloor].minimumTime);
  }
  
  
  /**
   * An inner class models a floor
   * @author HAIBO LIU
   *
   */
  private class Floor
  {
    private int floorNum;
    private boolean isVisited=false;
    private int minimumTime =0;
    private int minimumPush =0;
    
    public Floor( int number, boolean isVisited, int minTime, int minPush)
    {
      floorNum = number;
      this.isVisited = isVisited;
      minimumTime = minTime;
      minimumPush = minPush;
    }
  }
}
