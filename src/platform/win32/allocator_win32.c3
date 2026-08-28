module utic3::mem @feat(WIN32);
import std::os::win32;

extern fn Win32_HANDLE getProcessHeap() @cname("GetProcessHeap");
extern fn Win32_LPVOID heapAlloc(Win32_HANDLE hHeap, Win32_DWORD dwFlags, Win32_SIZE_T dwBytes) @cname("HeapAlloc");
extern fn Win32_BOOL heapFree(Win32_HANDLE handle, Win32_DWORD flags, Win32_LPVOID mem) @cname("HeapFree");

struct Win32AllocatorHeader @private {
    void* base;
    usz total_size;
}

fn uptr align_forward(uptr value, usz alignment) @private {
    return (value + alignment - 1) & ~(uptr)(alignment - 1);
}

fn void* win32_alloc(usz size, usz alignment, void* user @unused) @private {
    if (alignment == 0) {
        alignment = void*::alignment;
	}
        //     base             header             returned block
        //       |                 |                     |
        //       v                 v                     v
        //     [ unused padding ][ Win32AllocatorHeader ][ user bytes ]
	usz padding  = alignment - 1;
    usz overhead = Win32AllocatorHeader::size + padding;
	if (padding > (usz)-1 - Win32AllocatorHeader::size) {
    	return null;
	}
    if (size > (usz)-1 - overhead) {
    	return null;
	}
    usz total_size = size + overhead;
    void* base = heapAlloc(getProcessHeap(), 0, total_size);
    if (!base) {
    	return null;
	}
	uptr raw = (uptr)base;
    uptr aligned = align_forward(raw + Win32AllocatorHeader::size, alignment);
    Win32AllocatorHeader* header = (Win32AllocatorHeader*)(aligned - Win32AllocatorHeader::size);
    header.base = base;
    header.total_size = total_size;
	return (void*)aligned;
}

fn void win32_free(void* block, usz size @unused, usz alignment @unused, void* user @unused) @private {
	uptr aligned = (uptr)block;
    Win32AllocatorHeader* header = (Win32AllocatorHeader*)(aligned - Win32AllocatorHeader::size);
    heapFree(getProcessHeap(), 0, header.base);
}

fn Allocator plat_get_allocator_impl() @private {
    return (Allocator) {
        .callback_alloc = &win32_alloc,
        .callback_free  = &win32_free,
        .user           = null
    };
}