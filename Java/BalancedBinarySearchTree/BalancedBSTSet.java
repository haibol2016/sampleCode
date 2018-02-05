package edu.iastate.cs228.hw5;
import java.util.AbstractSet;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.NoSuchElementException;

/**
 * Binary search tree implementation of the Set interface.  The contains() and
 * remove() methods of AbstractSet are overridden to search the tree without
 * using the iterator.  Instances of this class always maintain node counts; that
 * is, the count() method of the BSTNode interface is implemented to be O(1).
 * If constructed with the isSelfBalancing flag true, instances of this tree are 
 * self-balancing: whenever an add(), remove(), or Iterator.remove() operation 
 * causes any node to become unbalanced, a rebalance operation is automatically
 * performed at the highest unbalanced node.
 * 
 * @author HAIBO LIU
 */
public class BalancedBSTSet<E extends Comparable<? super E>> extends AbstractSet<E>
{
  /**
   * Root of this tree.
   */
  protected Node root;
  
  /**
   * Number of elements in this tree.
   */
  protected int size;
  
  /**
   * flag to show whether the binary search  tree is self balancing
   */
  protected boolean isSelfBalancing;
  
  /**
   * numerator of alpha,
   */
  protected int top;
  
  /**
   * denominator of alpha
   */
  protected int bottom;
    
  /**
   * Node type for this implementation.
   */
  protected class Node implements BSTNode<E>
  { 
    /**
     * the left child of a given node
     */
    public Node left;
    
    /**
     * the right child of a given node
     */
    public Node right;
    
    /**
     * the parent of a given node
     */
    public Node parent;
    
    /**
     * the data stored in a given node
     */
    public E data;
    
    /**
     * the number of nodes consisting of a subtree rooted at a given node
     */
    public int sizeOfSubtree;

    public Node(E key, Node parent)
    {
      this.data = key;
      this.parent = parent;
    }
    
    @Override
    public BSTNode<E> left()
    {
      return left;
    }

    @Override
    public BSTNode<E> right()
    {
      return right;
    }

    @Override
    public int count()
    {
      return sizeOfSubtree;
    }

    @Override
    public E data()
    {
      return data;
    }

    @Override
    public BSTNode<E> parent()
    {
      return parent;
    }
    
    @Override
    public String toString()
    {
      return data.toString();
    }
  }  
  
  /**
   * Constructs an empty binary search tree.  This tree will maintain
   * node counts but will not automatically perform rebalance operations.
   */
  public BalancedBSTSet()
  {
    root = null;
    isSelfBalancing = false;
    size = 0;
  }

  /**
   * Constructs an empty binary search tree. If the isSelfBalancing
   * flag is true, the tree will be self-balancing: if so, whenever an add(), 
   * remove(), or Iterator.remove() operation causes any node to become 
   * unbalanced, a rebalance operation is automatically performed at the 
   * highest unbalanced node.  The default value alpha = 2/3 is used for
   * the balance condition.  Maintains node counts whether or not 
   * isSelfBalancing is true.
   * 
   * @param isSelfBalancing true if this binary search tree is 
   *   to be self-balancing, false otherwise
   */
  public BalancedBSTSet(boolean isSelfBalancing)
  {
    root = null;
    this.isSelfBalancing = isSelfBalancing;
    if (isSelfBalancing)
    {
      top = 2;
      bottom =3;
    }
    size =0;
  }
  

  /**
   * Constructs an empty binary search tree. If the isSelfBalancing
   * flag is true, the tree will be self-balancing: if so, whenever an add(), 
   * remove(), or Iterator.remove() operation causes any node to become 
   * unbalanced, a rebalance operation is automatically performed at the 
   * highest unbalanced node.  The given alpha = top/bottom is used for
   * the balance condition.  Maintains node counts whether or not 
   * isSelfBalancing is true.
   * 
   * @param isSelfBalancing true if this binary search tree is 
   *   to be self-balancing, false otherwise
   * @param top numerator of the fraction alpha
   * @param bottom denominator of the fraction alpha
   * @throws IllegalArgumentException if top / bottom is less than 1/2 
   */
  public BalancedBSTSet(boolean isSelfBalancing, int top, int bottom)
  {
        
    if (2*top< bottom || top >= bottom)
    {
      throw new IllegalArgumentException();
    }
    
    root = null;
    this.isSelfBalancing = isSelfBalancing;
    if (isSelfBalancing)
    {
      this.top= top;
      this.bottom = bottom;
    }
    size =0;
  }  

  /**
   * Returns a read-only view of the root node of this tree.
   * @return root node of this tree
   */
  public BSTNode<E> root()
  {
    return root;
  }

  /**
   * Performs a rebalance operation on the given subtree.  This operation
   * does not create or destroy any nodes and does not change the size of
   * this tree.
   * @param bstNode root of the subtree to be rebalanced.
   * @throws IllegalArgumentException if the given node is not part of this tree.
   * @throws ClassCastException if the given node cannot be cast to the 
   *   correct concrete node type for this tree.
   */
  public void rebalance(BSTNode<E> bstNode)
  {  
    if ( bstNode== null || !contains(bstNode.data()))
    {
      throw new IllegalArgumentException();
    }
    
    try
    {
      Node node = (Node) bstNode;
    }
    catch (ClassCastException e)
    {
      System.out.println("Caught ClassCastException: a given node cannot be cast to the " +
          "correct concrete node type for this tree");
      throw new ClassCastException();
    }
    
    // find the given node bstNode's parent
    Node n = (Node) bstNode.parent();
    
    //an ArrayList to store a subtree rooted at a given node in a sorted order
    ArrayList<Node> arr = new ArrayList<Node>();
    
    //convert the subtree rooted at bstNode to a sorted ArrayList
    BST2ArrayListByTraverseInorder(bstNode, arr);
    
    //reroot the subtree rooted at bstNode to make it a well-balanced subtree
    Node reroot = sortedArrayListToBalancedBSTSet(arr, 0, arr.size() - 1);
    
    //link the balanced subtree to its parent node
    {
      if (n == null)
      {
        root = reroot;
        reroot.parent = null;
      }
      else
      {
        if (reroot.data().compareTo(n.data()) < 0)
        {
          n.left = reroot;
          reroot.parent = n;
        }
        else if (reroot.data().compareTo(n.data()) > 0)
        {
          n.right = reroot;
          reroot.parent = n;
        }
      }
    }
  }
  
  /**
   * helper method used to convert a sorted ArrayList to a balanced binary using recursion
   * search tree representing a set
   * @param arr  a sorted ArrayList
   * @param first  first index of a sorted ArrayList
   * @param last   last index of a sorted ArrayList
   * @param tempRoot the root of the resulting balanced subtree
   */
  private Node sortedArrayListToBalancedBSTSet(ArrayList<Node> arr, int first, int last)
  {
    if (first >last)
    {
      return null;
    }
    int mid = (first + last)/2;
    Node midNode = arr.get(mid);
    midNode.left = sortedArrayListToBalancedBSTSet(arr, first, mid-1);
    int sizeOfLeft = 0;
    if ( midNode.left != null)
    {
      midNode.left.parent = midNode;
      sizeOfLeft = midNode.left.sizeOfSubtree;
    }
    midNode.right = sortedArrayListToBalancedBSTSet(arr,mid+1, last);
    int sizeOfRight = 0;
    if ( midNode.right != null)
    {
      midNode.right.parent = midNode;
      sizeOfRight = midNode.right.sizeOfSubtree;
    }
    midNode.sizeOfSubtree = sizeOfLeft + sizeOfRight +1;
    return midNode;
  }
  
  /**
   * helper method used to convert a binary search tree rooted at a given node bstNode to a 
   * sorted ArrayList
   * @param bstNode the root node of a subtree
   */
  private void BST2ArrayListByTraverseInorder(BSTNode<E> bstNode, ArrayList<Node> arr)
  {
    if(bstNode == null)
    {
      return;
    }
    else 
    {
      BST2ArrayListByTraverseInorder(bstNode.left(), arr);
      Node node = (Node) bstNode;
      node.sizeOfSubtree =0;
      arr.add(node);
      BST2ArrayListByTraverseInorder(bstNode.right(), arr);
    }
  }

  @Override
  public boolean contains(Object obj)
  {
    // This cast may cause comparator to throw ClassCastException at runtime,
    // which is the expected behavior
    E key = (E) obj;
    return findEntry(key) != null;
  }
  
  @Override
  public boolean add(E key)
  {
    if (key == null)
    {
      throw new NullPointerException();
    }
    
    if (root == null)
    {
      root = new Node(key, null);
      ++size;
      root.sizeOfSubtree ++;
      return true;
    }
    
    Node current = root;
    while (true)
    {
      int comp = current.data.compareTo(key);
      if (comp == 0)
      {
        // key is already in the tree
        return false;
      }
      else if (comp > 0)
      {
        if (current.left != null)
        {
          current = current.left;
        }
        else
        {
          current.left = new Node(key, current);
          current = current.left;
          current.sizeOfSubtree++;
          ++size;
          
          //update the counts in all ancestors of the current node and 
          //find the highest unbalanced node,then rebalance the tree if necessary
          updateSizeOfSubtreeAndRebalanceAfterAdd(current);
          return true;
        }
      }
      else
      {
        if (current.right != null)
        {
          current = current.right;
        }
        else
        {
          current.right = new Node(key, current);
          current = current.right;
          current.sizeOfSubtree ++;
          ++size;
          
          
          //update the counts in all ancestors of the current node and 
          //find the highest unbalanced node, then rebalance the tree if necessary
          updateSizeOfSubtreeAndRebalanceAfterAdd(current);
          return true;
        }
      }
    }   
  }
  
  /**
   * Helper method used to update the counts in all ancestors of the current node and 
   * find the highest unbalanced node, then rebalance the tree if necessary
   * @param current node to start with to update the size of Subtree
   */
  private void updateSizeOfSubtreeAndRebalanceAfterAdd(Node current)
  {
    Node unbalancedNode = null;
    while(current.parent !=null)
    {
      current = current.parent;
      current.sizeOfSubtree ++;
      if (isSelfBalancing && !isSubtreeBalanced(current))
      {
        unbalancedNode = current;
      }
    }
    if (unbalancedNode != null && isSelfBalancing)
    {
      rebalance(unbalancedNode);
    }
  }
  
  @Override
  public boolean remove(Object obj)
  {
    // This cast may cause comparator to throw ClassCastException at runtime,
    // which is the expected behavior
    E key = (E) obj;
    Node n = findEntry(key);
    if (n == null)
    {
      return false;
    }
    unlinkNode(n);
    return true;
  }
  
  /**
   * Returns the node containing key, or null if the key is not
   * found in the tree.
   * @param key
   * @return the node containing key, or null if not found
   */
  protected Node findEntry(E key)
  {
    Node current = root;
    while (current != null)
    {
      int comp = current.data.compareTo(key);
      if (comp == 0)
      {
        return current;
      }
      else if (comp > 0)
      {
        current = current.left;
      }
      else
      {
        current = current.right;
      }
    }   
    return null;
  }
  
  
  /**
   * Returns the successor of the given node.
   * @param n
   * @return the successor of the given node in this tree, 
   *   or null if there is no successor
   */
  protected Node successor(Node n)
  {
    if (n == null)
    {
      return null;
    }
    else if (n.right != null)
    {
      // leftmost entry in right subtree
      Node current = n.right;
      while (current.left != null)
      {
        current = current.left;
      }
      return current;
    }
    else 
    {
      // we need to go up the tree to the closest ancestor that is
      // a left child; its parent must be the successor
      Node current = n.parent;
      Node child = n;
      while (current != null && current.right == child)
      {
        child = current;
        current = current.parent;
      }
      // either current is null, or child is left child of current
      return current;
    }
  }
  
  /**
   * Removes the given node, preserving the binary search
   * tree property of the tree.
   * @param n node to be removed
   */
  protected void unlinkNode(Node n)
  {
    // first deal with the two-child case; copy
    // data from successor up to n, and then delete successor 
    // node instead of given node n
    if (n.left != null && n.right != null)
    {
      Node s = successor(n);
      n.data = s.data;
      n = s; // causes s to be deleted in code below
    }
    
    // n has at most one child
    Node replacement = null;    
    if (n.left != null)
    {
      replacement = n.left;
    }
    else if (n.right != null)
    {
      replacement = n.right;
    }
    
    // link replacement into tree in place of node n 
    // (replacement may be null)
    if (n.parent == null)
    {
      root.sizeOfSubtree --;
      root = replacement; 
      if (root != null && isSelfBalancing && !isSubtreeBalanced(root)) 
      {
        rebalance(root);
      }
    }
    else
    {
      if (n == n.parent.left)
      {
        n.parent.left = replacement;
      }
      else
      {
        n.parent.right = replacement;
      }
    } 
    if (replacement != null)
    {
      replacement.parent = n.parent;
    }
    --size;
    
    // update the counts of the ancestors of the removed node 
    // and rebalance the highest unbalanced subtree if necessary
    if (n.parent != null)
    {
      Node unbalancedNode = null;
      while (n.parent != null)
      {
        n = n.parent;
        n.sizeOfSubtree --;
       
        if (isSelfBalancing && !isSubtreeBalanced(n))
        {
          unbalancedNode = n;
        }
      }
      if (unbalancedNode != null && isSelfBalancing)
      {
        rebalance(unbalancedNode);
      }      
    }
    
  }
  
  /**
   * helper method used to check whether a subtree rooted at
   * given node is balanced based on the alpha value determined upon construction.
   * @param node the root node of a subtree
   * @return true if the tree rooted at the given node is balanced, otherwise false
   */
  private boolean isSubtreeBalanced(Node node)
  {
    if (node == null || !contains(node.data()))
    {
      throw new IllegalArgumentException();
    }
    else
    {
      int sizeOfLeftSubtree =0;
      Node leftNode = node.left;
      if (leftNode !=null)
      {
        sizeOfLeftSubtree = leftNode.sizeOfSubtree;
      }
      else
      {
        sizeOfLeftSubtree = 0;
      }
      return sizeOfLeftSubtree * bottom <= node.sizeOfSubtree*top && 
             (node.sizeOfSubtree - sizeOfLeftSubtree-1)*bottom <= node.sizeOfSubtree*top; 
    }
  }
  
  @Override
  public Iterator<E> iterator()
  {
    return new BSTIterator();
  }

  @Override
  public int size()
  {
    return size;
  }
 
  /**
   * Returns a representation of this tree as a multi-line string.
   * The tree is drawn with the root at the left and children are
   * shown top-to-bottom.  Leaves are marked with a "-" and non-leaves
   * are marked with a "+".
   */
  @Override
  public String toString()
  {
    StringBuilder sb = new StringBuilder();
    toStringRec(root, sb, 0);
    return sb.toString();
  }
  
  /**
   * Preorder traversal of the tree that builds a string representation
   * in the given StringBuilder.
   * @param n root of subtree to be traversed
   * @param sb StringBuilder in which to create a string representation
   * @param depth depth of the given node in the tree
   */
  private void toStringRec(Node n, StringBuilder sb, int depth)
  {
    for (int i = 0; i < depth; ++i)
    {
      sb.append("  ");
    }
    
    if (n == null)
    {
      sb.append("-\n");
      return;
    }
    
    if (n.left != null || n.right != null)
    {
      sb.append("+ ");
    }
    else
    {
      sb.append("- ");
    }
    sb.append(n.data.toString() + " (" + n.count() + ")");
    sb.append("\n");
    if (n.left != null || n.right != null)
    {
      toStringRec(n.left, sb, depth + 1);   
      toStringRec(n.right, sb, depth + 1);
    }
  }
  
  
  
  /**
   * Iterator implementation for this binary search tree.  The elements
   * are returned in ascending order according to their natural ordering.
   */
  private class BSTIterator implements Iterator<E>
  {
    /**
     * Node to be returned by next call to next().
     */
    private Node current;
    
    /**
     * Node returned by last call to next() and available
     * for removal.  This field is null when no node is
     * available to be removed.
     */
    private Node pending;
    
    /**
     * Constructs an iterator starting at the smallest
     * element in the tree.
     */
    public BSTIterator()
    {
      // start out at smallest value
      current = root;
      if (current != null)
      {
        while (current.left != null)
        {
          current = current.left;
        }
      }
    }
    
    @Override
    public boolean hasNext()
    {
      return current != null;
    }

    @Override
    public E next()
    {
      if (!hasNext()) throw new NoSuchElementException();
      pending = current;
      current = successor(current);
      return pending.data;
    }

    @Override
    public void remove()
    {
      if (pending == null) throw new IllegalStateException();

      // Remember, current points to the successor of 
      // pending, but if pending has two children, then
      // unlinkNode(pending) will copy the successor's data 
      // into pending and delete the successor node.
      // So in this case we want to end up with current
      // pointing to the pending node.
      if (pending.left != null && pending.right != null)
      {
        current = pending;
      }
      
      unlinkNode(pending);
      
      pending = null;
    }
  }
}
