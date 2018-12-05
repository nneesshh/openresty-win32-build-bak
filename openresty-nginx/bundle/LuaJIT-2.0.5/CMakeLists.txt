cmake_minimum_required(VERSION 3.4)

project(luajit)

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/src/host/)
include_directories(src/ src/host/ ${CMAKE_CURRENT_BINARY_DIR}/src/ ${CMAKE_CURRENT_BINARY_DIR}/src/host/)
add_definitions(-D_CRT_SECURE_NO_DEPRECATE "-D_CRT_STDIO_INLINE=__declspec(dllexport)__inline")

set(LIBLJ_SRC src/lj_alloc.c      src/lj_clib.c      src/lj_lex.c         src/lj_opt_split.c
	src/lj_api.c        src/lj_cparse.c    src/lj_lib.c         src/lj_parse.c
	src/lj_asm.c        src/lj_crecord.c   src/lj_load.c        src/lj_record.c
	src/lj_bc.c         src/lj_ctype.c     src/lj_mcode.c       src/lj_snap.c
	src/lj_bcread.c     src/lj_debug.c     src/lj_meta.c        src/lj_state.c
	src/lj_bcwrite.c    src/lj_dispatch.c  src/lj_obj.c         src/lj_str.c
	src/lj_carith.c     src/lj_err.c       src/lj_opt_dce.c     src/lj_strscan.c
	src/lj_ccall.c      src/lj_ffrecord.c  src/lj_opt_fold.c    src/lj_tab.c
	src/lj_ccallback.c  src/lj_func.c      src/lj_opt_loop.c    src/lj_trace.c
	src/lj_cconv.c      src/lj_gc.c        src/lj_opt_mem.c     src/lj_udata.c
	src/lj_cdata.c      src/lj_gdbjit.c    src/lj_opt_narrow.c  src/lj_vmevent.c
	src/lj_char.c       src/lj_ir.c        src/lj_opt_sink.c    src/lj_vmmath.c)
set(LIBLJ_GEN_HEADERS src/lj_bcdef.h src/lj_ffdef.h  src/lj_libdef.h
	src/lj_recdef.h	src/lj_folddef.h)
set(LIBLJ_HEADERS src/lj_alloc.h      src/lj_clib.h       src/lj_frame.h   src/lj_snap.h
	src/lj_arch.h       src/lj_cparse.h     src/lj_func.h    src/lj_state.h
	src/lj_asm.h        src/lj_crecord.h    src/lj_gc.h      src/lj_str.h
	src/lj_asm_arm.h    src/lj_ctype.h      src/lj_gdbjit.h  src/lj_strscan.h
	src/lj_asm_mips.h   src/lj_debug.h      src/lj_ir.h      src/lj_tab.h
	src/lj_asm_ppc.h    src/lj_def.h        src/lj_ircall.h  src/lj_target.h
	src/lj_asm_x86.h    src/lj_dispatch.h   src/lj_iropt.h   src/lj_target_arm.h
	src/lj_bc.h         src/lj_emit_arm.h   src/lj_jit.h     src/lj_target_mips.h
	src/lj_bcdump.h     src/lj_emit_mips.h  src/lj_lex.h     src/lj_target_ppc.h
	src/lj_carith.h     src/lj_emit_ppc.h   src/lj_lib.h     src/lj_target_x86.h
	src/lj_ccall.h      src/lj_emit_x86.h   src/lj_mcode.h   src/lj_trace.h
	src/lj_ccallback.h  src/lj_err.h        src/lj_meta.h    src/lj_traceerr.h
	src/lj_cconv.h      src/lj_errmsg.h     src/lj_obj.h     src/lj_udata.h
	src/lj_cdata.h      src/lj_ff.h         src/lj_parse.h   src/lj_vm.h
	src/lj_char.h       src/lj_ffrecord.h   src/lj_record.h  src/lj_vmevent.h
	${LIBLJ_GEN_HEADERS})

set(LIBLUA_SRC src/lib_base.c src/lib_math.c src/lib_bit.c src/lib_string.c
	 src/lib_table.c src/lib_io.c src/lib_os.c src/lib_package.c src/lib_debug.c
	 src/lib_jit.c src/lib_ffi.c src/lib_init.c  src/lib_aux.c )

set(MINILUA_SRC src/host/minilua.c)
set(MINILUA_FLAGS -D WIN -D JIT -D FFI -D P64)
#set(MINILUA_FLAGS "-D WIN -D JIT -D FFI") #x86

set(BUILDVM_SRC src/host/buildvm.c src/host/buildvm_fold.c src/host/buildvm_peobj.c 
	src/host/buildvm_asm.c  src/host/buildvm_lib.c)
set(BUILDVM_HEADER ${CMAKE_CURRENT_BINARY_DIR}/src/host/buildvm_arch.h)

# First generator
add_executable(minilua ${MINILUA_SRC})
add_custom_command(
    OUTPUT  ${BUILDVM_HEADER}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMAND ${CMAKE_CURRENT_BINARY_DIR}/minilua dynasm/dynasm.lua -LN ${MINILUA_FLAGS} -o ${BUILDVM_HEADER} src/vm_x86.dasc
    DEPENDS minilua ${MINILUA_SRC} dynasm/dynasm.lua src/vm_x86.dasc
)

# Second generator
add_executable(buildvm ${BUILDVM_SRC} ${BUILDVM_HEADER})
function(buildvm_call MPARAM OPARAM)
	add_custom_command(
	    OUTPUT  ${CMAKE_CURRENT_BINARY_DIR}/${OPARAM}
	    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
	    COMMAND ${CMAKE_CURRENT_BINARY_DIR}/buildvm -m ${MPARAM} -o ${CMAKE_CURRENT_BINARY_DIR}/${OPARAM} ${ARGN}
	    DEPENDS buildvm ${ARGN}
	)
endfunction()
buildvm_call(peobj lj_vm.obj)
buildvm_call(bcdef src/lj_bcdef.h ${LIBLUA_SRC})
buildvm_call(ffdef src/lj_ffdef.h  ${LIBLUA_SRC})
buildvm_call(libdef src/lj_libdef.h ${LIBLUA_SRC})
buildvm_call(recdef src/lj_recdef.h ${LIBLUA_SRC})
buildvm_call(vmdef src/jit/vmdef.lua ${LIBLUA_SRC})
buildvm_call(folddef src/lj_folddef.h src/lj_opt_fold.c)

#BUILDMODE= static/dynamic/mixed
add_library(luajit SHARED lj_vm.obj ${LIBLJ_SRC} ${LIBLJ_HEADERS} ${LIBLUA_SRC})
target_compile_definitions(luajit PRIVATE LUA_BUILD_AS_DLL)

add_executable(luajit-bin src/luajit.c)
target_link_libraries(luajit-bin luajit)

# Some unsupported flags from POSIX makefile
#XCFLAGS+= -DLUAJIT_DISABLE_FFI
#XCFLAGS+= -DLUAJIT_ENABLE_LUA52COMPAT
#XCFLAGS+= -DLUAJIT_DISABLE_JIT
#XCFLAGS+= -DLUAJIT_NUMMODE=1
#XCFLAGS+= -DLUAJIT_NUMMODE=2
