module testbed;
import std::io;
import utic3::mem;

fn int main() {
    utic3::mem::Allocator std_allocator = mem::plat_get_allocator();
    int* i = std_allocator.alloc(int);
    if(!i) {
        return -1;
    }
    *i = 2;
    io::printfn("Allocated successfully: %d", *i);
    defer(std_allocator.free(int, i));
    return 0;
}
