
#include "Sequence.h"
using namespace std;

Sequence::Node::Node() //default constructor
	: m_next(NULL), m_prev(NULL)
{
}

Sequence::Node::Node(const ItemType& value) //constructor for node, initializes Node's m_data to inputted value.
	:m_data(value), m_next(NULL), m_prev(NULL)
{
}

//HELPER FUNCTION IMPLEMENTATION

Sequence::Node* Sequence::pointer_to(int pos) const
{
	Node* position = m_head; //initialize pos to point to the first item
	if (0<=pos && pos<m_size) //pos refers to a valid node
	{
		 for (int i=0; i<pos; ++i) //we bring up the position pointer to the pos node.
			 position=position->m_next; //now position points to the i'th item in the list;
	}
	else //pos does not refer to a valid node; return NULL
		position = NULL;
	return position;
}
 Sequence::Node* Sequence::search(Node* starting_pos, const ItemType& value) const
 {
	 Node* result;
	 for (result = starting_pos; result != NULL && result->m_data != value; result = result->m_next)
		 ; //we start the check from result = starting_pos
	 // check if m_data == value, or if we've reached the end of the list (indicated by null)
	 // go to the next Node if result != NULL and m_data !=value.
	 return result;
 }

 Sequence::Node* Sequence::search(int starting_pos, const ItemType& value) const
 {
	 Node* start = pointer_to(starting_pos); //convert the int starting_pos to a pointer to a Node.
	 return search(start, value);
 }

 //PUBLIC FUNCTIONS IMPLEMENTATION

Sequence::Sequence() //default constructor, initializes size to 0.
	:m_size(0), m_head(NULL), m_tail(NULL)
{
}

bool Sequence::insert(int pos, const ItemType& value)
{
	if (!(0<=pos && pos<=m_size)) //pos is out of bounds
		return false;
	Node* toInsert = new Node(value); //constructs the relevant Node to insert.
	toInsert->m_next = pointer_to(pos); //if we are inserting the node at the end of the sequence, m_next becomes NULL (pos = m_size)
	toInsert->m_prev = pointer_to(pos-1); //if we are inserting the node at the beginning of the sequence, m_prev becomes NULL (pos-1 = -1)
	if (toInsert->m_next != NULL) //if there is a valid item after toInsert, i.e. toInsert is not at the end of the list
		(toInsert->m_next)->m_prev = toInsert; //we adjust the next item's m_prev pointer
	else //toInsert is at the end, we adjust the tail pointer
		m_tail = toInsert;
	if(toInsert->m_prev != NULL) //if toInsert is not at the beginning
		(toInsert->m_prev)->m_next = toInsert;
	else //toInsert is at the beginning, we adjust the head pointer
		m_head = toInsert;

	m_size++; //update size
	return true;
}

bool Sequence::insert(const ItemType& value)
{
	Node* check = m_head;
	int i;
	for (i=0; i<m_size && value>check->m_data; ++i)
		// we begin checking from the first item m_head
		// we continue checking until we hit the end of the sequence (i=m_size) or until value<=m_data at that position
		// i points to the position where we want to insert value.
		check =check->m_next;
	return insert(i, value);
}

 bool Sequence::erase(int pos)
 {
  if (!(0<=pos && pos<m_size)) //position is out of bounds
	  return false;
  Node* toErase = pointer_to(pos);
  if (toErase->m_next == NULL) //toErase is the last element
	  m_tail = toErase->m_prev; //the tail becomes the (earlier) 2nd-to-last element.
  else //toErase is not the last element
	  (toErase->m_next)->m_prev = toErase->m_prev; //we adjust the next element's m_prev pointer
  if (toErase ->m_prev == NULL) //toErase is the first element
	  m_head = toErase->m_next;
  else //toErase is not the first element
	  (toErase->m_prev)->m_next = toErase->m_next; //we adjust the previous element's m_next pointer

  delete toErase; //delete the node which toErase points to, since it is no longer part of the sequence
  m_size--;
  return true;
 }

 int Sequence::remove(const ItemType& value)
 {
	 int counter = 0;
	 Node* check = m_head;
	 for (int pos = 0; pos<m_size; ++pos, check = check->m_next) 
	 {
		 //pos and check both refer to the same element during the body of the loop
		 if (check->m_data == value)
		 {
			 erase(pos);
			 counter++;
		 }
	 }
	 return counter;
 }

 bool Sequence::get(int pos, ItemType& value) const
 {
	 if (!(0<=pos && pos<m_size)) //if pos is out of bounds return false
		 return false;
	 Node* position = pointer_to(pos); //get a pointer to the item at pos
	 value = position->m_data; //set value to the m_data at pos
	 return true;
 }

 bool Sequence::set(int pos, const ItemType& value)
 {
	 if (!(0<=pos && pos<m_size))
		 return false;
	 Node* position = pointer_to(pos); //get a pointer to the item at pos
	 position->m_data = value; //set m_data at pos to equal value
	 return true;
 }

 int Sequence::find(const ItemType& value)const
 {
	 Node* check =m_head;
	 for (int i=0; i<m_size; ++i, check = check->m_next) // check and i both refer to the same position in the body
		 if (check->m_data == value)
			 return i;
	 return -1;
 }

 void Sequence::swap(Sequence& other)
 {
	 int tempSize; 
	 Node* tempPointer;

	 tempSize = this->m_size;
	 this->m_size = other.m_size;
	 other.m_size = tempSize;

	 tempPointer = this->m_head;
	 this->m_head = other.m_head;
	 other.m_head = tempPointer;

	 tempPointer = this->m_tail;
	 this->m_tail = other.m_tail;
	 other.m_tail = tempPointer;
 }

 //Housekeeping Functions Implementations
 Sequence::~Sequence()
 {
	 Node* nextToDelete;
	 // we only dereference toDelete, and call delete on toDelete, which is why we ensure toDelete != NULL (which happens at the end of the sequence)
	 //there is no need to check if nextToDelete is a bad pointer, because we never perform any operations on it.
	 for (Node* toDelete = m_head; toDelete != NULL; toDelete = nextToDelete)
	 {
		 nextToDelete = toDelete->m_next;
		 delete toDelete;
	 }
 }

 Sequence::Sequence(const Sequence& other)
	 :m_size(0), m_head(NULL), m_tail(NULL)
 {
	 ItemType tempVal;
	 for (int i=0; i<m_size; ++i)
	 {
		 other.get(i, tempVal); //we get the value from 'other' sequence in the ith location and store it in tempVal.
		 this->insert(i, tempVal); //we insert tempVal into the ith location in 'this' sequence.
		 m_size++;
	 }
 }

 Sequence& Sequence::operator=(const Sequence& rhs)
 {
	 Sequence temp(rhs);
	 this->swap(temp);
	 return *this;
 }

 int subsequence(const Sequence& seq1, const Sequence& seq2)
 {
	 Sequence temp1 = seq1; //we'll work with this temp sequence to check	
	 int counter = 0; //counts deletions from temp1.
	 ItemType firstItem;
	 ItemType value1, value2; //used in the while loop to store seq1 item, seq2 item

	 seq2.get(0, firstItem); //firstItem contains the first item in seq2. This is what we first have to look for in seq1.
	 int pos = temp1.find(firstItem);

	 while (pos != -1)
	 {
		 if ((seq1.size() - pos) < seq2.size()) 
		 //this checks whether there are enough items in seq1 after the occurence of firstItem,
		 // for seq2 to be a subsequence of seq1.
		 // if there aren't, it sets pos to -1 and breaks out of the while loop 
		 {
			 pos = -1;
			 break;
		 }

		 //this for loop checks whether the rest of seq2 exists in seq1.
		 for (int pos1 = pos, pos2 = 0; pos!= -1 && pos2<seq2.size(); pos1++, pos2++) 
		 {
			 temp1.get(pos1, value1);
			 seq2.get(pos2, value2);
			 if (value1 != value2)
			 {
				 temp1.erase(pos);
				 counter++;
				 pos =-1;
			 }
		 }
		 pos = temp1.find(firstItem);
	 }

	 if (pos == -1)
		 return pos;
	 else
		 return pos+counter; 
	 //if the subsequence was found say only on the third occurence of firstItem
	 //we have already deleted two items from temp1, therefore the pos value it returns will be 2 less
	 //than what it should be. We thus add this 2, which will be stored in 'counter'.
 }

 void interleave(const Sequence& seq1, const Sequence& seq2, Sequence& result)
 {
	 int maxSize, minSize;
	 ItemType valueToInsert;
	 Sequence largerSequence, resultCopy; //we create the required sequence in resultCopy, at later assign it's value to result.

	 //this if/else statement assigns the right values to maxSize, minSize, largerSequence
	 if (seq1.size() <= seq2.size())
	 {
		 minSize = seq1.size();
		 maxSize = seq2.size();
		 largerSequence = seq2;
	 }
	 else
	 {
		 maxSize = seq1.size();
		 minSize = seq2.size();
		 largerSequence = seq1;
	 }

	 for (int pos = 0; pos<minSize; ++pos)
	 {
		 seq1.get(pos, valueToInsert);
		 resultCopy.insert(2*pos, valueToInsert); //first insert seq1 item
		 seq2.get(pos, valueToInsert);
		 resultCopy.insert((2*pos)+1, valueToInsert); //then insert seq2 item
	 }

	 for (int pos = minSize; pos<maxSize; ++pos)
	 {
		 largerSequence.get(pos, valueToInsert); //then insert remaining items of the larger sequence
		 resultCopy.insert(pos, valueToInsert);
	 }
	 result = resultCopy;
 }

		 



