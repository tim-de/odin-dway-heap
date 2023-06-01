package dway_heap

import "core:fmt"
import "core:testing"

compare :: proc(parent, child: int) -> (swap: bool) {
	return child < parent
}

@(test)
heap_from_initial_array :: proc(t: ^testing.T) {
	arr: []int = {12, 13, 4, 9, 6, 7, 18, 42}
	heap := dwayHeap_from_array(int, 3, compare, arr)
	defer free_dwayHeap(heap)
	last, ok := pop(heap)
	next: int
	for {
		next, ok = pop(heap)
		if !ok do break
		testing.expect(t, next > last)
		last = next
	}
}

@(test)
push_values_to_heap :: proc(t: ^testing.T) {
	heap, ok := create_dwayHeap(int, 2, compare, 32)
	defer free_dwayHeap(heap)
	push(heap, 12)
	testing.expect_value(t, heap.store[0], 12)
	push(heap, 8)
	testing.expect_value(t, heap.store[0], 8)
	push(heap, 9)
	testing.expect_value(t, heap.store[0], 8)
}

@(test)
peek_at_top_value :: proc(t: ^testing.T) {
	heap, alloc_ok := create_dwayHeap(int, 3, compare, 32)
	defer free_dwayHeap(heap)
	push(heap, 12)
	for _ in 0..<2 {
		value, ok := peek(heap)
		testing.expect_value(t, ok, true)
		testing.expect_value(t, value, 12)
	}
}

@(test)
push_pop_on_heap :: proc(t: ^testing.T) {
	arr: []int = {12, 42, 19, 8, 11}
	heap := dwayHeap_from_array(int, 2, compare, arr)
	defer free_dwayHeap(heap)
	testing.expect_value(t, heap.store[0], 8)
	testing.expect_value(t, push_pop(heap, 6), 6)
	testing.expect_value(t, heap.store[0], 8)
	testing.expect_value(t, push_pop(heap, 17), 8)
	testing.expect_value(t, heap.store[0], 11)
}

@(test)
replace_on_heap :: proc(t: ^testing.T) {
	arr: []int = {12, 42, 19, 8, 11}
	heap := dwayHeap_from_array(int, 2, compare, arr)
	defer free_dwayHeap(heap)
	replace(heap, 16)
	testing.expect_value(t, 11, heap.store[0])
}
