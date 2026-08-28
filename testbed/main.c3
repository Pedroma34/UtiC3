module testbed;
import std::io;
import utic3::mem;
import utic3::containers::darray;

fn int main() {
	utic3::mem::Allocator std_allocator = mem::plat_get_allocator();
	int* i = std_allocator.alloc(int);
	defer (std_allocator.free(i));
	*i = 2;
	io::printfn("Allocated successfully: %d", *i);

    io::printfn("Allocating array...");
    int[] array = std_allocator.alloc_array(int, 10);
    defer(std_allocator.free_array(array));
    io::printfn("Array allocated");
    String name = $Typeof(array)::name;
    usz size = $Typeof(array[0])::size;
    io::printfn("Array len: %d | Name: %s | Size: %d", array.len, name, size);

    io::printfn("Testing dynamic array...");
    darray::DArray{int} d_array = darray::create(mem::plat_get_allocator(), 10);
    defer(d_array.destroy());
	return 0;
}
