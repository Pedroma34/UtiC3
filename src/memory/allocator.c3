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
    @ensure return != null
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
    @require count > 0
*>
macro Allocator.alloc_array(&self, $Type, usz count) {
    $Type* buffer = ($Type*)self.alloc_raw($Type::size * count, $Type::alignment);
    return buffer[:count];
}

<*
    @param [&in] self : "allocator cannot be null"
    @require $defined(*block) : "block must be a typed pointer bro"
*>
macro Allocator.free(&self, block) {
    var $Type = $Typeof(*block);
    self.free_raw((void*)block, $Type::size, $Type::alignment);
}

<*
    @param [&in] self
    @require @kindof(array) == TypeKind.SLICE : "must be a slice"
    @require array.len > 0 : "slice cannot be empty"
*>
macro Allocator.free_array(&self, array) {
    self.free_raw((void*)array.ptr, $Typeof(array[0])::size * array.len, $Typeof(array[0])::alignment);
}

fn bool power_of_two(usz value) {
    return value != 0 && (value & (value - 1)) == 0;
}
