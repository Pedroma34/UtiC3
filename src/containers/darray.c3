module utic3::containers::darray <Type>;
import utic3::mem;

struct DArray {
    Type[] buffer;
    usz size; 
    mem::Allocator backing_allocator;
}

<* 
    @require backing_allocator.callback_alloc != null : "alloc callback must not be null"
    @require initial_capacity  > 0
*>
fn DArray create(mem::Allocator backing_allocator, usz initial_capacity = 1) {
    return (DArray) {
        .buffer = backing_allocator.alloc_array(Type, initial_capacity),
        .size = 0,
        .backing_allocator = backing_allocator
    };
}

<*
    @require self.backing_allocator.callback_free != null : "free callback must not be null"
*>
fn void DArray.destroy(DArray* self) {
    self.backing_allocator.free_array(self.buffer);
    self.buffer = {};
    self.size = 0;
}
