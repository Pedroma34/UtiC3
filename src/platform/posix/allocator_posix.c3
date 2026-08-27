module utic3::mem @feat(POSIX);
import std::core::mem;

struct PosixAllocatorHeader @private {
    void* base;   
}

<* @pure *>
fn bool posix_power_of_two(usz value) @private {
    return value != 0 && (value & (value - 1)) == 0;
}

<*
    @require size > 0
    @require alignment == 0 || posix_power_of_two(alignment) : "alignment must be zero or a power of two"
*>
fn void* posix_alloc(usz size, usz alignment, void* user @unused) @private {
    if (alignment == 0) {
        alignment = void*::alignment;
    }
    usz padding = alignment - 1;
    if (padding > (usz)-1 - PosixAllocatorHeader::size) {
        return null;
    }
    usz overhead = PosixAllocatorHeader::size + padding;
    if (size > (usz)-1 - overhead) {
        return null;
    }
    char* base = (char*)std::core::mem::malloc((sz)size + (sz)overhead);
    if (!base) {
        return null;
    }
    char* unaligned = base + PosixAllocatorHeader::size;
    usz adjustment = (usz)(-(uptr)unaligned & (uptr)padding);
    char* block = unaligned + adjustment;
    PosixAllocatorHeader* header = (PosixAllocatorHeader*)(block - PosixAllocatorHeader::size);
    header.base = base;
    return block;
}

<*
    @require block != null
*>
fn void posix_free(void* block, usz size @unused, usz alignment @unused, void* user @unused) @private {
    char* aligned = block;
    PosixAllocatorHeader* header = (PosixAllocatorHeader*)(aligned - PosixAllocatorHeader::size);
    free(header.base);
}

fn Allocator plat_get_allocator_impl() @private {
    return (Allocator) {
        .callback_alloc = &posix_alloc,
        .callback_free  = &posix_free,
        .user           = null
    };
}
