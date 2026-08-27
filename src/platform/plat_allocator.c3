module utic3::mem;

fn Allocator plat_get_allocator() {
    return plat_get_allocator_impl();
}
