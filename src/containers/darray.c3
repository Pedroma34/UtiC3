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

<*
    @param [&inout] self : "darray must not be null"
    @ensure self.buffer.len >= self.size
*>
fn void DArray.push_value(DArray* self, Type value) {
   if(self.size == self.buffer.len) {
       resize(self);
   }
   self.buffer[self.size] = value;
   self.size++;
}

fn void resize(DArray* darray) @local {
    usz new_capacity = darray.buffer.len * 2;
    Type[] new_array = darray.backing_allocator.alloc_array(Type, new_capacity);
    for(usz i = 0; i < darray.size; i++) {
        new_array[i] = darray.buffer[i];
    }
    darray.backing_allocator.free_array(darray.buffer);
    darray.buffer = new_array;
}
