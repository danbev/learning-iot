### Drogue Device

The following example code is from device/examples/std/hello:
```rust
pub struct MyDevice {
    counter: AtomicU32,
    a: ActorContext<'static, MyActor>,
    b: ActorContext<'static, MyActor>,
    p: MyPack,
}

static DEVICE: DeviceContext<MyDevice> = DeviceContext::new();
```
So in this case we are creating a new instance of DeviceContext with a specific
type of MyDevice.

```rust
pub struct DeviceContext<D: 'static> {
    device: Forever<D>,
    state: AtomicU8,
```
`Forever` is a struct from Embassy and has a static lifetime and can only be
written to once so it is good for initialization of things.
```rust
pub struct Forever<T> {
    used: AtomicBool,
    t: UnsafeCell<MaybeUninit<T>>,
}
```
We can `configure`, `mount`, and `drop` a DeviceContext. When we configure a
device are giving the Forever instace (the device) a value:
```rust
    DEVICE.configure(MyDevice {
        counter: AtomicU32::new(0),
        a: ActorContext::new(MyActor::new("a")),
        b: ActorContext::new(MyActor::new("b")),
        p: MyPack::new(),
    });
```
This is done by calling `put` which gives the `Forever` a value:
```rust
    pub fn configure(&'static self, device: D) {
        match self.state.fetch_add(1, Ordering::Relaxed) {
            NEW => {
                self.device.put(device);
            }
            _ => {
                panic!("Context already configured");
            }
        }
    }
```
Note that `self` is an instance of `DeviceContext<hello::MyDevice>`:
```console
(lldb) expr self
(drogue_device::kernel::device::DeviceContext<hello::MyDevice> *) $5 = 0x00005555558a90c0
```
And we can see that `state` is of type `AtomicU8` which means that it can be
safely shared between threads. We can see that we have multiple threads:
```console
(lldb) thread list
Process 775026 stopped
* thread #1: tid = 775026, 0x00005555555b0308 hello`hello::mypack::MyPack::new::h37a13cbcb2b29e39 at mypack.rs:14:9, name = 'hello', stop reason = breakpoint 1.1
  thread #2: tid = 775029, 0x00007ffff7c8ca8a libpthread.so.0`__futex_abstimed_wait_common64 + 202, name = 'hello'
```

`fetch_add` adds to the current value (the state field) of this atomic integer
and returns the previous state.

This is in a match statement so if the previous/current state state is NEW, we
will call `put` on the Forever giving it a value. And remember that it will also
increment the value so it will now be 1 which is `CONFIGURED`. And if this has
already happend the a panic will be raised.

Next we have:
```rust
let (a_addr, b_addr, c_addr) = DEVICE                                          
        .mount(|device| async move {                                               
            let a_addr = device.a.mount(&device.counter, spawner);              
            let b_addr = device.b.mount(&device.counter, spawner);              
            let c_addr = device.p.mount((), spawner);                              
            (a_addr, b_addr, c_addr)                                               
        })                                                                         
        .await;         
```
Notice that we are calling `mount` on our DeviceContext instance which is
typed over MyDevice.

```rust
pub async fn mount<FUT: Future<Output = R>, F: FnOnce(&'static D) -> FUT, R>(  
        &'static self,                                                             
        f: F,                                                                   
    ) -> R {                                                                    
        match self.state.fetch_add(1, Ordering::Relaxed) {                         
            CONFIGURED => {                                                        
                let device = unsafe { self.device.steal() };                       
                let r = f(device).await;                                           
                                                                                   
                r                                                                  
            }                                                                      
            NEW => {                                                               
                panic!("Context must be configured before mounted");               
            }                                                                   
            MOUNTED => {                                                        
                panic!("Context already mounted");                              
            }                                                                   
            val => {                                                            
                panic!("Unexpected state: {}", val);                            
            }                                                                   
        }                                                                       
    }                         
```
Notice that this method takes a closure. Remember that we incremented the state
previously so it is currently CONFIGURED, and we now increment it again using
`fetch_add` which as before will return the current value so we will enter
the CONFIGURED branch of the match statement: 
```console
(lldb) expr self->state.v.value
(unsigned char) $11 = '\x01'
```
We then get the value of the device and pass that to the closer (so we will
be back in main.rs in the closure:
```console
  38  	    let (a_addr, b_addr, c_addr) = DEVICE
   39  	        .mount(|device| async move {
-> 40  	            let a_addr = device.a.mount(&device.counter, spawner);
   41  	            let b_addr = device.b.mount(&device.counter, spawner);
   42  	            let c_addr = device.p.mount((), spawner);
   43  	            (a_addr, b_addr, c_addr)
   44  	        })
   45  	        .await;
```
Next we will call each of the MyDevice struct members `mount` methods.


### drogue-tls logging
Logging can be enabled using
```console
$ RUST_LOG=info cargo test --verbose --  --nocapture
```

### Embassy
Embedded Async is an executor of tasks and also a Hardware Access Layer (HAL). 
The HAL provides an API to access peripherals like USART, I2C, SPI, CAN etc.


#### embassy::main
This macro can be used in an embassy application and expands to something like:
```console
$ cargo rustc --profile=check -- -Zunpretty=expanded
```

### defmt logging
Deferred formatter logging can be enabled using the `DEFMT_LOG` environment
variable:
```console
   Compiling defmt-macros v0.3.1
   Compiling defmt v0.3.0
   Compiling embassy v0.1.0 (https://github.com/embassy-rs/embassy.git?rev=c8f3ec3fba47899b123d0a146e8f9b3808ea4601#c8f3ec3f)
   Compiling panic-probe v0.3.0
   Compiling defmt-rtt v0.3.1
   Compiling embassy-hal-common v0.1.0 (https://github.com/embassy-rs/embassy.git?rev=c8f3ec3fba47899b123d0a146e8f9b3808ea4601#c8f3ec3f)
   Compiling embassy-stm32 v0.1.0 (https://github.com/embassy-rs/embassy.git?rev=c8f3ec3fba47899b123d0a146e8f9b3808ea4601#c8f3ec3f)
   Compiling drogue-device v0.1.0 (/home/danielbevenius/work/drougue/drogue-device/device)
   Compiling bsp-blinky-app v0.1.0 (/home/danielbevenius/work/drougue/drogue-device/examples/apps/blinky)
   Compiling stm32f072b-disco-blinky v0.1.0 (/home/danielbevenius/work/drougue/drogue-device/examples/stm32f0/stm32f072b-disco/blinky)
    Finished dev [optimized + debuginfo] target(s) in 6.16s
     Running `probe-run --chip STM32F072R8Tx target/thumbv6m-none-eabi/debug/stm32f072b-disco-blinky`
(HOST) INFO  flashing program (30 pages / 30.00 KiB)
(HOST) INFO  success!
────────────────────────────────────────────────────────────────────────────────
DEBUG In stm32f072b-disco main...
└─ stm32f072b_disco_blinky::__embassy_main::task::{generator#0} @ blinky/src/main.rs:35
```
