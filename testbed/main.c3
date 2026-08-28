module testbed;
import std::io;
import utic3::mem;

fn int main() {
	utic3::mem::Allocator std_allocator = mem::plat_get_allocator();
	int* i = std_allocator.alloc(int);
	defer (std_allocator.free(i));
	if (!i) {
		return -1;
	}
	*i = 2;
	io::printfn("Allocated successfully: %d", *i);

    io::printfn("Allocating array...");
    int[] array = std_allocator.alloc_array(int, 10);
    defer(std_allocator.free_array(array));
    io::printfn("Array allocated");
    String name = $Typeof(array)::name;
    usz size = $Typeof(array[0])::size;
    io::printfn("Array len: %d | Name: %s | Size: %d", array.len, name, size);
	return 0;
}
