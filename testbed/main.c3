module testbed;
import std::io;
import utic3::mem;
import utic3::containers::darray;

struct MemCounter {
    usz live_bytes;
    mem::Allocator backing_allocator;
}

fn void* mem_counter_alloc(usz size, usz alignment, void* user) {
    MemCounter* counter = (MemCounter*)user;
    void* buffer = counter.backing_allocator.alloc_raw(size, alignment);
    counter.live_bytes += size;
    io::printfn("Mem allocated: [%d] | live bytes [%d]", size, counter.live_bytes);
    return buffer;
}

fn void mem_counter_free(void* block, usz size, usz alignment, void* user) {
    MemCounter* counter = (MemCounter*)user;
    counter.backing_allocator.free_raw(block, size, alignment);
    counter.live_bytes -= size;
    io::printfn("Mem freed: [%d] | live bytes [%d]", size, counter.live_bytes);
}

fn mem::Allocator MemCounter.get_allocator(MemCounter* self) {
    return (mem::Allocator) {
        .user = self,
        .callback_alloc = &mem_counter_alloc,
        .callback_free  = &mem_counter_free
    };
}

fn int main() {
    
    // >>>> Testing allocator and container stuff <<<< //

    MemCounter mem_counter = (MemCounter) {
        .live_bytes = 0, // I know C3 default initializes everything to 0 but I want to do this ok leave me alone
        .backing_allocator = mem::plat_get_allocator()
    };
    mem::Allocator default_allocator = mem_counter.get_allocator();

    var $Type = int;
    io::printfn("Allocating [%s]", $Type::name);
	$Type* i = default_allocator.alloc($Type);
	defer (default_allocator.free(i));
	*i = 2;

    io::printfn("Allocating an array of [%s]", $Type::name);
    $Type[] array = default_allocator.alloc_array($Type, 3);
    defer(default_allocator.free_array(array));
    io::printfn("Array len: %d | Name: %s | Size: %d", array.len, $Typeof(array)::name, $Typeof(array[0])::size);

    io::printfn("Creating dynamic array...");
    darray::DArray{int} d_array = darray::create(default_allocator, 5);
    defer(d_array.destroy());
    
    io::printfn("Pushing elements to darray..");
    for(usz index = 0; index < 6; index++) {
        d_array.push_value(((int)index + 1) * 2);
        io::printfn("Element pushed.");
    }

    io::printfn("Printing each element...");
    for(usz index = 0; index < d_array.size; index++) {
        io::printfn("Value: %d", d_array.buffer[index]);
    }

    // >>>> End of testing allocator and container stuff <<<< //

	return 0;
}

