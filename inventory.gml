/*  GML-INVENTORY-SYSTEM
    - A set of functions to create an inventory system for Game Maker Studio 2 written in GML
    - Feel free to use however you wish!
    - created by Anthony Silva AKA "Burning Eyece"
*/

/*  NOTES
    - our concept of an "inventory" will be an array of objects where each object represents an item slot
        - i.e. [ { id: 2, amt: 10 }, { id: 4, amt: 1 }, ... ]

    - "inv" stands for "inventory"

    - this could probably be written as an inventory Class instead with methods instead of all these functions
*/

#region standard inventory functions

// returns the given array with empty "inventory" objects to reach the given size
// use this for initializing a new inventory or adding additional size to an existing inventory
function fnInvInit(_inv = [], _extraSize = 4) {
	var currentSize = array_length(_inv)
	var targetSize = currentSize + _extraSize
	
	// set to empty objects of the "inventory" format
	for (var i = currentSize; i < targetSize; i++) {
		_inv[@ i] = {
            id: -1, // item ID, -1 represent no item, it is an empty slot
            amt: 0, // item quantity
        }
	}
	
	// return the array in the case where an inv has just been created
    // this array is now considered an inventory because of its new structure
	return _inv
}


// return whether or not every slot in the inventory is empty
function fnInvIsEmpty(_inv) {
	for (var i = 0; i < array_length(_inv); i++) {
		if (_inv.id > -1)
			return false
	}

	return true
}

// return whether or not every slot in the inventory is NOT empty
function fnInvIsFull(_inv) {
	for (var i = 0; i < array_length(_inv); i++) {
		if (_inv.id == -1)
            return false
	}

	return true
}


// return the number of items in the given inventory
// this could be used for displaying some info text about how many items are in the inventory vs the total capacity
function fnInvGetItemCount(_inv, _isCountingStacks = false) {	
	var total = 0

	for (var i = 0; i < array_length(_inv); i++) {
        // if there is an item in this slot update the total
		if (_inv.id > -1) {
            total += _isCountingStacks ? _inv.amt : 1
		}
	}

	return total
}

// find the first index that has the given item id, otherwise return -1
// use this for finding where a certain item is in the inventory
function fnInvFindIndex(_inv, _itemId) {
	for (var i = 0; i < array_length(_inv); i++) {
		if (_inv.id == _itemId)
			return i
	}

	return -1
}

// check if the given inventory has the given item and given amount of that item
// TODO - loop through to count up non stackable items
function fnInvQuery(_inv, _itemId, _itemAmt = 1) {
	var index = fnInvFindIndex(_inv, _itemId)

    // if we couldn't find the index then the item doesn't exist in the inventory
	if (index == -1)
		return false
	else
    // if we have the item and at least as much of the amount as the query is asking for then return true
		return _inv[index, 1] >= _itemAmt
}


// add given item to the given index in the given inv
function fnInvAddIndex(_inv, _index, _itemId, _itemAmt = 1) {
	var isItemAdded = false

    // only add item if this slot is free
	if (_inv[_index].id == -1) {
		_inv[@_index].id = _itemId
		_inv[@_index].amt = _itemAmt 
		isItemAdded = true
	} else {
        // show custom error message
		cle("that inventory slot it full!")
	}
	return isItemAdded
}

// add given item and amount to the given inv
function fnInvAdd(_inv, _itemId, _itemAmt = 1) {
    // don't bother running this function if the inventory is full
    if (fnInvIsFull()) { 
        // show a custom message
        fnFeedWarn("Inventory full!")
        exit
    }

    // this function must be written independently as part of the item system, not the inventory system
	var isStackable = fnIsItemStackable(_itemId)
	var index = fnInvFindIndex(_inv, _itemId)
	var itemsAdded = 0

	// add to an existing stack
	if (isStackable && fnInvQuery(_inv, _itemId)) {
		_inv[@index].amt += _itemAmt

        // all the items have been able to be added
		return _itemAmt
	}

	// otherwise, find an empty slot and add it there
	for (var i = 0; i < array_length(_inv); i++) {
        // stop trying to add an item once the inv is full
		if (fnInvIsFull(_inv)) {
			break
		}

        // if an empty slot is found
		if (_inv[i].id == -1) {
            // non stackable items can only hold 1 for their amt
			if (!isStackable) {
				_inv[@i].id = _itemId
				_inv[@i].amt = 1
				itemsAdded++

                // stop the loop if we have added enough items
				if (itemsAdded == _itemAmt)
					break
			} else {
				_inv[@i].id = _itemId
				_inv[@i].amt = _itemAmt

                // all the items have been able to be added
				return _itemAmt
			}
		}
	}

    // return how many items actually were able to be added to the inventory
	return itemsAdded
}


// remove the item in the given index of the given inventory
function fnInvRemoveIndex(_inv, _invIndex) {
	// remove item at that index
	// essentially setting it back to an empty item slot
	_inv[@_invIndex] = {
        id: -1,
        amt: 0,
    }
}

// remove the given amount of a given item from the given inventory
function fnInvRemove(_inv, _itemId, _itemAmt = 1) {
    // this function must be written independently as part of the item system, not the inventory system
	var isStackable = fnIsItemStackable(_itemId)

    // continue to remove the given item from the inventory until the amount has been satisfied
    // or we no longer have the item
    while (_itemAmt > 0 or !fnInvQuery(_inv, _itemId, 1)) {
        var thisIndex = fnInvFindIndex(_inv, _itemId)
        var thisItem = _inv[thisIndex]

        // determine how many items to remove from this slot and remove them
        var itemsToRemove = min(thisItem.amt, _itemAmt)
        thisItem.amt -= itemsToRemove
        _itemAmt -= itemsToRemove

        // if we have removed all the amount of the item in this slot then the item needs to be removed
		if (_inv[index].amt <= 0) {
			fnInvRemoveIndex(_inv, index)
		}
    }
}

// removes all items in the given inventory
function fnInvClear(_inv) {
	 for (var i = 0; i < array_length(_inv); i++) {
	 	fnInvRemoveIndex(_inv, i)
	 }
}


// takes an inv, creates a sorted inv and then assigns the inv to the newly sorted inv using the Bubble Sort method
// sorts by item tiers and then by item id
function fnInvSort(_inv) {
	var sorted = false

	while (!sorted) {
		sorted = true
		for (var i = 1; i < array_length(_inv); i++) {
			var first = _inv[i - 1, 0]
			var second = _inv.id
			
			// get the tier of both items
			var firstTier = fnGetItemTier(first)
			var secondTier = fnGetItemTier(second)
			
			// check if both items are the same tier
			var isSameTier = firstTier == secondTier
			
			// if both items are same tier use their item ids to compare them instead
			var firstValue = isSameTier ? first : firstTier
			var secondValue = isSameTier ? second : secondTier
			
			// sort zeros to the end (empty spaces)
			
			// if items are the same and stackable, add them together in the same stack
			var edgeCase1 = (first != 0 && first == second) && fnIsItemStackable(first)
			
			// always swap if the first is a 0 and second is a non-zero
			var edgeCase2 = first == 0 && second > 0
			
			// always swap if first is greater than a non-zero
			var normalCase = second != 0 && firstValue > secondValue

			// combine these two items into one stack in the slot of the first
			if (edgeCase1) {
				_inv[@i - 1].amt += _inv.amt
				_inv[@i].id = 0
				_inv[@i].amt = 0
				sorted = false
				break
			}
			
			// swap items between the two slots
			if (edgeCase2 || normalCase) {
				var temp = {}
				temp.id = _inv.id
				temp.amt = _inv.amt

				_inv[@i].id = _inv[i - 1].id
				_inv[@i].amt = _inv[i - 1].amt
				_inv[@i - 1].id = temp.id
				_inv[@i - 1].amt = temp.amt

				sorted = false
			}
		}
	}
}

#endregion