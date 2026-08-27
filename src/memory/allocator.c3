module utic3::mem;

alias AllocFn = fn void*(usz size, usz alignment, void* user);
alias FreeFn  = fn void(void* block, usz size, usz alignment, void* user);

struct Allocator {
    AllocFn callback_alloc;
    FreeFn  callback_free;
    void* user;
}

<*
    @require alloc_callback != null : "allocation callback must not be null"
    @require free_callback  != null : "free callback must not be null"
*>
fn Allocator allocator_init(AllocFn alloc_callback, FreeFn free_callback, void* user = null) {
    return (Allocator) {
        .callback_alloc = alloc_callback,
        .callback_free  = free_callback,
        .user           = user
    };
}

<*
    @param [&in] self : "allocator cannot be null"
    @require self.callback_alloc != null : "allocator has no allocation callback"
    @require size > 0, alignment > 0
    @require power_of_two(alignment) : "alignment must be power of two"
*>
fn void* Allocator.alloc_raw(Allocator* self, usz size, usz alignment) {
   return self.callback_alloc(size, alignment, self.user); 
}

<*
    @param [&in] self : "allocator cannot be null"
    @require self.callback_free != null : "allocator has no free callback"
    @require block != null : "block to be freed must not be null"
    @require size > 0, alignment > 0
*>
fn void Allocator.free_raw(Allocator* self, void* block, usz size, usz alignment) {
    return self.callback_free(block, size, alignment, self.user);
}

<*
    @param [&in] self : "allocator cannot be null"
*>
macro Allocator.alloc(&self, $Type) {
    return ($Type*)self.alloc_raw($Type::size, $Type::alignment);
}

<*
    @param [&in] self : "allocator cannot be null"
*>
macro Allocator.free(&self, $Type, void* block) {
    self.free_raw(block, $Type::size, $Type::alignment);
}

fn bool power_of_two(usz value) @private {
    return value != 0 && (value & (value - 1)) == 0;
}
