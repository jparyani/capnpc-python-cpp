from capnp.includes.capnp_cpp cimport (
    Maybe, ReaderOptions, DynamicStruct, Request, Response, PyPromise, VoidPromise, PyPromiseArray,
    RemotePromise, DynamicCapability, InterfaceSchema, EnumSchema, StructSchema, DynamicValue,
    Capability, RpcSystem, MessageBuilder, MessageReader, TwoPartyVatNetwork, AnyPointer,
    DynamicStruct_Builder, WaitScope, AsyncIoContext, StringPtr, TaskSet, Timer, AsyncIoStreamReadHelper,
)

from capnp.includes.schema_cpp cimport ByteArray

from non_circular cimport reraise_kj_exception

from cpython.ref cimport PyObject

from libcpp cimport bool

cdef extern from "capnp/helpers/fixMaybe.h":
    EnumSchema.Enumerant fixMaybe(Maybe[EnumSchema.Enumerant]) except +reraise_kj_exception
    StructSchema.Field fixMaybe(Maybe[StructSchema.Field]) except +reraise_kj_exception

cdef extern from "capnp/helpers/capabilityHelper.h":
    # PyPromise evalLater(EventLoop &, PyObject * func)
    # PyPromise there(EventLoop & loop, PyPromise & promise, PyObject * func, PyObject * error_func)
    PyPromise then(PyPromise & promise, PyObject * func, PyObject * error_func)
    PyPromise then(RemotePromise & promise, PyObject * func, PyObject * error_func)
    PyPromise then(VoidPromise & promise, PyObject * func, PyObject * error_func)
    PyPromise then(PyPromiseArray & promise)
    DynamicCapability.Client new_client(InterfaceSchema&, PyObject *)
    DynamicValue.Reader new_server(InterfaceSchema&, PyObject *)
    Capability.Client server_to_client(InterfaceSchema&, PyObject *)
    PyPromise convert_to_pypromise(RemotePromise&)
    PyPromise convert_to_pypromise(VoidPromise&)
    VoidPromise convert_to_voidpromise(PyPromise&)
    void init_capnp_api()

cdef extern from "capnp/helpers/rpcHelper.h":
    Capability.Client bootstrapHelper(RpcSystem&)
    Capability.Client bootstrapHelperServer(RpcSystem&)
    PyPromise connectServer(TaskSet &, Capability.Client, AsyncIoContext *, StringPtr, ReaderOptions &)

cdef extern from "capnp/helpers/serialize.h":
    ByteArray messageToPackedBytes(MessageBuilder &, size_t wordCount)

cdef extern from "capnp/helpers/asyncHelper.h":
    void waitNeverDone(WaitScope&)
    void pollWaitScope(WaitScope&)
    Response * waitRemote(RemotePromise *, WaitScope&)
    bool pollRemote(RemotePromise *, WaitScope&)
    PyObject * waitPyPromise(PyPromise *, WaitScope&)
    void waitVoidPromise(VoidPromise *, WaitScope&)
    Timer * getTimer(AsyncIoContext *) except +reraise_kj_exception
