
#ifndef SEQUENCE_H
#define SEQUENCE_H

#include <string>

using namespace std;

typedef unsigned long ItemType;

class Sequence
{
  public:
    Sequence(); // Create an empty sequence.

    inline bool empty() const; // Return true if the sequence is empty, otherwise false.

    inline int size() const; // Return the number of items in the sequence.
	
	bool insert(int pos, const ItemType& value);
      // Insert value into the sequence so that it becomes the item at
      // position pos.  The original item at position pos and those that
      // follow it end up at positions one higher than they were at before.
      // Return true if 0 <= pos <= size() and the value could be
      // inserted.  (It might not be, if the sequence has a fixed capacity,
      // e.g., because it's implemented using a fixed-size array.)  Otherwise,
      // leave the sequence unchanged and return false.  Notice that
      // if pos is equal to size(), the value is inserted at the end.

    bool insert(const ItemType& value);
      // Let p be the smallest integer such that value <= the item at
      // position p in the sequence; if no such item exists (i.e.,
      // value > all items in the sequence), let p be size().  Insert
      // value into the sequence so that it becomes the item at position
      // p.  The original item at position p and those that follow it end
      // up at positions one higher than before.  Return true if the value
      // was actually inserted.  Return false if the value was not inserted
      // (perhaps because the sequence has a fixed capacity and is full).
     
    bool erase(int pos);
      // If 0 <= pos < size(), remove the item at position pos from
      // the sequence (so that all items that followed this item end up at
      // positions one lower than they were at before), and return true.
      // Otherwise, leave the sequence unchanged and return false.
     
    int remove(const ItemType& value);
      // Erase all items from the sequence that == value.  Return the
      // number of items removed (which will be 0 if no item == value).

    bool get(int pos, ItemType& value) const;
      // If 0 <= pos < size(), copy into value the item at position pos
      // in the sequence and return true.  Otherwise, leave value unchanged
      // and return false.

    bool set(int pos, const ItemType& value);
      // If 0 <= pos < size(), replace the item at position pos in the
      // sequence with value and return true.  Otherwise, leave the sequence
      // unchanged and return false.

    int find(const ItemType& value)const;
      // Let p be the smallest integer such that value == the item at
      // position p in the sequence; if no such item exists, let p be -1.
      // Return p.

    void swap(Sequence& other);
      // Exchange the contents of this sequence with the other one.

	//Housekeeping functions
	~Sequence();
	Sequence(const Sequence& other);
	Sequence& operator=(const Sequence& rhs);

  private:
	  //Class Invariant:
	  // m_size > 0;
	  // m_head and m_tail are NULL iff the list is empty.
	  // if there is only item in the list, m_head == m_tail != NULL.

	  int m_size; //size of sequence

	  struct Node
	  {
	  public:
		  Node();
		  Node(const ItemType& value);
		  ItemType m_data;
		  Node* m_next;
		  Node* m_prev;
	  };

	  Node* m_head; //points to the first node in the list (or NULL if the list is empty).
	  Node* m_tail; //points to the last node in the list (or NULL if the list is empty).

	  //Helper functions

	  Node* pointer_to(int pos) const;
	  //returns a Node* pointing to the element in the list at position = pos.
	  //pos = 0 is the first element, m_size-1 is the last element.
	  //returns NULL if pos is out of bounds.

	  Node* search(Node* starting_pos, const ItemType& value) const; 
	  //searches for value from the list, starting from the place in the list 'starting_pos'.
	  //returns a pointer to the first Node it encounters which contains value (we include starting_pos in the search).
	  //if value doesn't exist anywhere till the end of the sequence (from the starting_pos), we return NULL.
	  //Note: if we input a NULL pointer for starting_pos, we are returned a NULL pointer.

	  Node* search(int starting_pos, const ItemType& value) const;
	  //similar to the above function, except that it accepts an int starting_pos
	  //as an argument, instead of a Node*
	  //If !(0<=starting_pos<size) return NULL
};

int subsequence(const Sequence& seq1, const Sequence& seq2);
//Sequence2 should be a subsequence of seq1
//Consider all the items in seq2; let's call them seq20, seq21, ..., seq2n. 
//If there exists at least one k such that seq1k == seq20 and seq1k+1 == seq21 and ... and seq1k+n == seq2n,
//and k+n < seq1.size(), then this function returns the smallest such k.
//If no such k exists or if seq2 is empty, the function returns -1

void interleave(const Sequence& seq1, const Sequence& seq2, Sequence& result);
//This function produces as a result a sequence that consists of the first item in seq1,
//then the first in seq2, then the second in seq1, then the second in seq2, etc.
//Once the smallest sequence is finished, it appends the remaining items of the larger sequence to result.

//Inline implementations

inline
	bool Sequence::empty() const
{
	return m_size==0;
}

inline
	int Sequence::size() const
{
	return m_size;
}

#endif