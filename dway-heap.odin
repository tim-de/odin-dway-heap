package dway_heap

import "core:fmt"

dwayHeap :: struct(T: typeid) {
	branch_factor: int,
	compare: proc(parent, child: T) -> (swap: bool),
	count: int,
	store: []T,
	heap_allocated: bool,
}

dwayHeap_from_array :: proc($T: typeid, $branch_factor: int, compare: proc(parent, child: T) -> (swap: bool), arr: []T) -> (heap: ^dwayHeap(T)) {
	heap = new(dwayHeap(T))
	heap.branch_factor = branch_factor
	heap.compare = compare
	heap.count = len(arr)
	heap.store = arr
	heap.heap_allocated = false
	heapify(heap)
	return
}

create_dwayHeap :: proc($T: typeid, $branch_factor: int, compare: proc(parent, child: T) -> (swap: bool), capacity: int) -> (heap: ^dwayHeap(T), ok: bool) {
	store := make([]T, capacity)
	heap = new(dwayHeap(T))
	ok = (store != nil) & (heap != nil)
	heap.branch_factor = branch_factor
	heap.compare = compare
	heap.count = 0
	heap.store = store
	heap.heap_allocated = true
	return
}

free_dwayHeap :: proc(heap: ^dwayHeap($T)) {
	if heap.heap_allocated do delete(heap.store)
	free(heap)
}

heapify :: proc(heap: ^dwayHeap($T)) -> (ok: bool) {
	for ix: int = heap.count / heap.branch_factor; ix >= 0; ix -= 1 {
		if !sink_down(heap, ix) do return false
	}
	return true
}

pop :: proc(heap: ^dwayHeap($T)) -> (ret:T, ok: bool) {
	if heap.count == 0 {
		ok = false
		return
	}
	else do ok = true
	ret = heap.store[0]
	heap.store[0] = heap.store[heap.count-1]
	heap.count -= 1
	defer sink_down(heap, 0)
	return
}

push :: proc(heap: ^dwayHeap($T), value: T) -> (ok: bool) {
	if heap.count == len(heap.store) do return false
	heap.store[heap.count] = value
	heap.count += 1
	float_up(heap, heap.count - 1)
	return true
}

peek :: proc(heap: ^dwayHeap($T)) -> (value: T, ok: bool) {
	if heap.count == 0 {
		ok = false
		return
	}
	value = heap.store[0]
	ok = true
	return
}

push_pop :: proc(heap: ^dwayHeap($T), item: T) -> (ret: T) {
	if heap.count == 0 do return item
	if !heap.compare(item, heap.store[0]) do return item
	ret = heap.store[0]
	heap.store[0] = item
	sink_down(heap, 0)
	return
}

replace :: proc(heap: ^dwayHeap($T), item: T) -> (ret: T, ok: bool) {
	if heap.count == 0 {
		ok = false
		return
	}
	ret = heap.store[0]
	heap.store[0] = item
	sink_down(heap, 0)
	ok = true
	return
}
			
@(private)
get_max_child_index :: proc(heap: ^dwayHeap($T), root_index: int) -> int {
	first_child_index := (root_index * heap.branch_factor) + 1
	max_child_offset: int = 0
	for child_offset in 1..<(heap.branch_factor) {
		if first_child_index + child_offset >= heap.count do break
		if heap.compare(heap.store[first_child_index + max_child_offset], heap.store[first_child_index + child_offset]) {
			max_child_offset = child_offset
		}
	}
	return first_child_index + max_child_offset
}

@(private)
get_parent_index :: proc(heap: ^dwayHeap($T), index: int) -> int {
	return index / heap.branch_factor
}

@(private)
float_up :: proc(heap: ^dwayHeap($T), index: int) -> (ok: bool) {
	if index >= heap.count do return false
	if index == 0 do return true
	ok = true
	parent_index := get_parent_index(heap, index)
	if heap.compare(heap.store[parent_index], heap.store[index]) {
		tmp := heap.store[parent_index]
		heap.store[parent_index] = heap.store[index]
		heap.store[index] = tmp
		ok = float_up(heap, parent_index)
	}
	return
}

@(private)
sink_down :: proc(heap: ^dwayHeap($T), index: int) -> (ok: bool) {
	if index >= heap.count do return false
	ok = true
	if (index * heap.branch_factor + 1) >= heap.count do return
	max_child_index := get_max_child_index(heap, index)
	if heap.compare(heap.store[index], heap.store[max_child_index]) {
		tmp := heap.store[max_child_index]
		heap.store[max_child_index] = heap.store[index]
		heap.store[index] = tmp
		ok = sink_down(heap, max_child_index)
	}
	return
}
