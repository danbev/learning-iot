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

I'm working on a example for drogue-device to add a board for stm32f072b-disco.

```rust
  static DEVICE: DeviceContext<BlinkyDevice<BSP>> = DeviceContext::new();

  #[embassy::main]
  async fn main(spawner: embassy::executor::Spawner, p: Peripherals) {
      defmt::debug!("In stm32f072b-disco main...");
      let board = BSP::new(p);

      let config = BlinkyConfiguration {
          led: board.0.led_blue,
          control_button: board.0.user_button,
      };
      DEVICE
          .configure(BlinkyDevice::new())
          .mount(spawner, config)
          .await;
  }
```
Now, expaning this will make it easier to understand what is happening in the
debugger:
```rust
static DEVICE: DeviceContext<BlinkyDevice<BSP>> = DeviceContext::new();

fn __embassy_main(spawner: embassy::executor::Spawner, p: Peripherals)
 -> ::embassy::executor::SpawnToken<impl ::core::future::Future + 'static> {
    use ::embassy::executor::raw::TaskStorage;
    async fn task(spawner: embassy::executor::Spawner, p: Peripherals) {
        {
            match () { _ => { } };
            let board = BSP::new(p);
            let config =
                BlinkyConfiguration{led: board.0.led_blue,
                                    control_button: board.0.user_button,};
            DEVICE.configure(BlinkyDevice::new()).mount(spawner,
                                                        config).await;
        }
    }
    type F = impl ::core::future::Future + 'static;
    #[allow(clippy :: declare_interior_mutable_const)]
    const NEW_TASK: TaskStorage<F> = TaskStorage::new();
    static POOL: [TaskStorage<F>; 1usize] = [NEW_TASK; 1usize];
    unsafe { TaskStorage::spawn_pool(&POOL, move || task(spawner, p)) }
}

#[doc(hidden)]
#[export_name = "main"]
pub unsafe extern "C" fn __cortex_m_rt_main_trampoline() {
    __cortex_m_rt_main()
}

fn __cortex_m_rt_main() -> ! {
    unsafe fn make_static<T>(t: &mut T) -> &'static mut T {
        ::core::mem::transmute(t)
    }
    let mut executor = ::embassy::executor::Executor::new();
    let executor = unsafe { make_static(&mut executor) };
    let p = ::embassy_stm32::init(Default::default());
    executor.run(|spawner|
                     { spawner.must_spawn(__embassy_main(spawner, p)); })
}
```

```console
$ arm-none-eabi-gdb ../target/thumbv6m-none-eabi/debug/stm32f072b-disco-blinky
(gdb) br main
Breakpoint 1 at 0x8001534: file blinky/src/main.rs, line 32.
```
Line 32 in the source code is `#embassy::main` which we can see the expended
version of above.

```console
$ arm-none-eabi-readelf -h  ../target/thumbv6m-none-eabi/debug/stm32f072b-disco-blinky
ELF Header:
  Magic:   7f 45 4c 46 01 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF32
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              EXEC (Executable file)
  Machine:                           ARM
  Version:                           0x1
  Entry point address:               0x80000c1
  Start of program headers:          52 (bytes into file)
  Start of section headers:          4272792 (bytes into file)
  Flags:                             0x5000200, Version5 EABI, soft-float ABI
  Size of this header:               52 (bytes)
  Size of program headers:           32 (bytes)
  Number of program headers:         6
  Size of section headers:           40 (bytes)
  Number of section headers:         26
  Section header string table index: 24
```
Notice the entry point is 0x80000c1, which is the Reset handler which is set
by the link.x linker script:
```assembly
ENTRY(Reset);
```
We can check the this using:
```console
$ arm-none-eabi-readelf -s  ../target/thumbv6m-none-eabi/debug/stm32f072b-disco-blinky | grep Reset
   433: 080000c1    48 FUNC    GLOBAL DEFAULT    2 Reset

$ arm-none-eabi-objdump -C --disassemble=Reset  ../target/thumbv6m-none-eabi/debug/stm32f072b-disco-blinky

../target/thumbv6m-none-eabi/debug/stm32f072b-disco-blinky:     file format elf32-littlearm


Disassembly of section .text:

080000c0 <Reset>:
 80000c0:	4c0b      	ldr	r4, [pc, #44]	; (80000f0 <Reset+0x30>)
 80000c2:	46a6      	mov	lr, r4
 80000c4:	f001 fa4c 	bl	8001560 <DefaultPreInit>
 80000c8:	46a6      	mov	lr, r4
 80000ca:	480a      	ldr	r0, [pc, #40]	; (80000f4 <Reset+0x34>)
 80000cc:	490a      	ldr	r1, [pc, #40]	; (80000f8 <Reset+0x38>)
 80000ce:	2200      	movs	r2, #0
 80000d0:	4281      	cmp	r1, r0
 80000d2:	d001      	beq.n	80000d8 <Reset+0x18>
 80000d4:	c004      	stmia	r0!, {r2}
 80000d6:	e7fb      	b.n	80000d0 <Reset+0x10>
 80000d8:	4808      	ldr	r0, [pc, #32]	; (80000fc <Reset+0x3c>)
 80000da:	4909      	ldr	r1, [pc, #36]	; (8000100 <Reset+0x40>)
 80000dc:	4a09      	ldr	r2, [pc, #36]	; (8000104 <Reset+0x44>)
 80000de:	4281      	cmp	r1, r0
 80000e0:	d002      	beq.n	80000e8 <Reset+0x28>
 80000e2:	ca08      	ldmia	r2!, {r3}
 80000e4:	c008      	stmia	r0!, {r3}
 80000e6:	e7fa      	b.n	80000de <Reset+0x1e>
 80000e8:	b500      	push	{lr}
 80000ea:	f001 fa21 	bl	8001530 <main>
 80000ee:	de00      	udf	#0


$ arm-none-eabi-objdump -C --disassemble=main  ../target/thumbv6m-none-eabi/debug/stm32f072b-disco-blinky

../target/thumbv6m-none-eabi/debug/stm32f072b-disco-blinky:     file format elf32-littlearm


Disassembly of section .text:

08001530 <main>:
 8001530:	b580      	push	{r7, lr}
 8001532:	af00      	add	r7, sp, #0
 8001534:	f000 f801 	bl	800153a <stm32f072b_disco_blinky::__cortex_m_rt_main>
 8001538:	defe      	udf	#254	; 0xfe

```
```console
$ arm-none-eabi-gdb ../target/thumbv6m-none-eabi/debug/stm32f072b-disco-blinky
(gdb) br main
Breakpoint 1 at 0x8001534: file blinky/src/main.rs, line 32.
(gdb) target remote localhost:3333
(gdb) c

(gdb) disassemble
Dump of assembler code for function main:
   0x08001530 <+0>:	push	{r7, lr}
   0x08001532 <+2>:	add	r7, sp, #0
=> 0x08001534 <+4>:	bl	0x800153a <_ZN23stm32f072b_disco_blinky18__cortex_m_rt_main17h2f36cf1eaaa9743eE>
   0x08001538 <+8>:	udf	#254	; 0xfe
End of assembler dump.
```
Notice that this will break in the main function generated by embassy.k
Now in this case we are only interested in the code we have written and we
therefor to debug this function:
```rust
fn __cortex_m_rt_main() -> ! {
    unsafe fn make_static<T>(t: &mut T) -> &'static mut T {
        ::core::mem::transmute(t)
    }
    let mut executor = ::embassy::executor::Executor::new();
    let executor = unsafe { make_static(&mut executor) };
    let p = ::embassy_stm32::init(Default::default());
    executor.run(|spawner|
                     { spawner.must_spawn(__embassy_main(spawner, p)); })
}
```
Notice that a new Executor is created for us:
```rust
pub struct Executor {
    inner: raw::Executor,
    not_send: PhantomData<*mut ()>,
}

impl Executor {

    pub fn new() -> Self {
        Self {
            inner: raw::Executor::new(|_| cortex_m::asm::sev(), ptr::null_mut()),
            not_send: PhantomData,
        }
    }
```
The `cortex_m::asm::sev()` function will call the assembly instruction sev:
```rust
pub fn sev() {
    call_asm!(__sev())
}
```
Note that `raw::Executor::new` takes two arguments and the `not_send` is a field
of the "outer" Executor.
```rust
impl Executor {
    /// Create a new executor.
    ///
    /// When the executor has work to do, it will call `signal_fn` with
    /// `signal_ctx` as argument.
    ///
    /// See [`Executor`] docs for details on `signal_fn`.
    pub fn new(signal_fn: fn(*mut ()), signal_ctx: *mut ()) -> Self {
        #[cfg(feature = "time")]
        let alarm = unsafe { unwrap!(driver::allocate_alarm()) };
        #[cfg(feature = "time")]
        driver::set_alarm_callback(alarm, signal_fn, signal_ctx);

        Self {
            run_queue: RunQueue::new(),
            signal_fn,
            signal_ctx,

            #[cfg(feature = "time")]
            timer_queue: timer_queue::TimerQueue::new(),
            #[cfg(feature = "time")]
            alarm,
        }
    }
```
After the executor has been created, embassy_stm32::init is called which takes
a Config parameter:
```rust
pub fn init(config: Config) -> Peripherals {
    let p = Peripherals::take();

    unsafe {
        if config.enable_debug_during_sleep {
            crate::pac::DBGMCU.cr().modify(|cr| {
                crate::pac::dbgmcu! {
                    (cr, $fn_name:ident) => {
                        cr.$fn_name(true);
                    };
                }
            });
        }

        gpio::init();
        dma::init();
        #[cfg(exti)]
        exti::init();

        rcc::init(config.rcc);

        // must be after rcc init
        #[cfg(feature = "_time-driver")]
        time_driver::init();
    }

    p
}
```
After this `executor.run` will be called which takes a closure as its single
argument:
```rust
impl Executor {
    ...
    pub fn run(&'static mut self, init: impl FnOnce(Spawner)) -> ! {
        init(self.inner.spawner());

        loop {
            unsafe { self.inner.poll() };
            cortex_m::asm::wfe();
        }
    }
}
```
`init` is passed a new instance of Spawner:
```rust
pub fn spawner(&'static self) -> super::Spawner {
    super::Spawner::new(self)
}

(from src/executor/spawner):
pub struct Spawner {
    executor: &'static raw::Executor,
    not_send: PhantomData<*mut ()>,
}

impl Spawner {
    pub(crate) fn new(executor: &'static raw::Executor) -> Self {
        Self {
            executor,
            not_send: PhantomData,
        }
    }
```
So a Spawner has pointer to the inner/raw Executor. This new Spawner instance
is then passed to Executor::init. Below I'm showing the call to run in addition
to the call to init so that we can see the values more clearly:
```rust
    executor.run(|spawner|
                     { spawner.must_spawn(__embassy_main(spawner, p)); })

    pub fn run(&'static mut self, init: impl FnOnce(Spawner)) -> ! {
        init(self.inner.spawner());

        loop {
            unsafe { self.inner.poll() };
            cortex_m::asm::wfe();
        }
    }
```
Notice that `init` is the closure passed into `executor.run`. And this closure
takes one argument named `spawner`. And this closure is then called by
Executor::run above, and then passed in spawner is the one created by the call
to `self.inner.spawner`. So the following line will now be executed:
```rust
    spawner.must_spawn(__embassy_main(spawner, p));
```
`__embassy_main(spawner, p)` where p is the Peripheral instance that was created
above.

```rust
fn __embassy_main(spawner: embassy::executor::Spawner, p: Peripherals)
 -> ::embassy::executor::SpawnToken<impl ::core::future::Future + 'static> {

    use ::embassy::executor::raw::TaskStorage;

    async fn task(spawner: embassy::executor::Spawner, p: Peripherals) {
        {
            match () { _ => { } };
            let board = BSP::new(p);
            let config = BlinkyConfiguration{led: board.0.led_blue, control_button: board.0.user_button,};
            DEVICE.configure(BlinkyDevice::new()).mount(spawner, config).await;
        }
    }

    type F = impl ::core::future::Future + 'static;

    #[allow(clippy :: declare_interior_mutable_const)]
    const NEW_TASK: TaskStorage<F> = TaskStorage::new();

    static POOL: [TaskStorage<F>; 1usize] = [NEW_TASK; 1usize];
    unsafe {
        TaskStorage::spawn_pool(&POOL, move || task(spawner, p))
    }
}
```
First thing to note is that this function returns a SpawnToken and it is
templated with anything that implements core::future::Future and does not contain
any non-static references:
```rust
pub struct SpawnToken<F> {
    raw_task: Option<NonNull<raw::TaskHeader>>,
    phantom: PhantomData<*mut F>,
}
```
Next, we have the definition of a function named task that is async, so actually
executing this function would return a Future (which we will see shortly). But
also notice that we are creating a closure `move || task(spawner, p)` and it is
this closure that is being passed into the `spawn_pool` function.

Next, we have the creation of a `TaskStorage` instance.
```rust
pub struct TaskStorage<F: Future + 'static> {
    raw: TaskHeader,
    future: UninitCell<F>, // Valid if STATE_SPAWNED
}
```
After this an array is allocated for the newly created TaskStorage which is only
on arch specific usize. Next, in the unsafe block `TaskStorage::spawn_pool` is
called:
```rust
pub fn spawn_pool(pool: &'static [Self], future: impl FnOnce() -> F) -> SpawnToken<F> {
        for task in pool {
            if task.spawn_allocate() {
                return unsafe {
                     task.spawn_initialize(future)
                };
            }
        }

        SpawnToken::new_failed()
    }
```
The first thing that happens is that a check is performed, spawn_allocate, using
TaskHeader and if that passes `task.spawn_initialized` will be called with our
closure passed in which returns a Future which contains the block of code that
we actually wrote:
```rust
    unsafe fn spawn_initialize(&'static self, future: impl FnOnce() -> F) -> SpawnToken<F> {
        // Initialize the task
        self.raw.poll_fn.write(Self::poll);
        self.future.write(future());

        SpawnToken::new(NonNull::new_unchecked(&self.raw as *const TaskHeader as _))
    }
```
First the `self.raw_poll_fn` is written to as it starts out uninitialized. Next
the future is written to by calling the closure passed in which as we mentioned
above returns a Future. Finally this function returns a new SpawnToken
containing the TaskHeader. And SpawnToken will be returned by the calling
function as well, and so will `__embassy_main` and we will be back in
`__cortex_m_rt_main`:
```
fn __cortex_m_rt_main() -> ! {
    unsafe fn make_static<T>(t: &mut T) -> &'static mut T {
        ::core::mem::transmute(t)
    }
    let mut executor = ::embassy::executor::Executor::new();
    let executor = unsafe { make_static(&mut executor) };
    let p = ::embassy_stm32::init(Default::default());
    executor.run(|spawner|
                     { spawner.must_spawn(__embassy_main(spawner, p)); })
}
```
So that SpawnToken returned will be passed to `spawner.must_spawn`:
```rust
pub fn must_spawn<F>(&self, token: SpawnToken<F>) {
        unwrap!(self.spawn(token));
}

pub fn spawn<F>(&self, token: SpawnToken<F>) -> Result<(), SpawnError> {
        let task = token.raw_task;
        mem::forget(token);

        match task {
            Some(task) => {
                unsafe { self.executor.spawn(task) };
                Ok(())
            }
            None => Err(SpawnError::Busy),
        }
    }
```
So we will be calling Executor::spawn (in src/executor/raw/mod.rs):
```rust
   pub(super) unsafe fn spawn(&'static self, task: NonNull<TaskHeader>) {
        let task = task.as_ref();
        task.executor.set(self);

        critical_section::with(|cs| {
            self.enqueue(cs, task as *const _ as _);
        })
    }

    unsafe fn enqueue(&self, cs: CriticalSection, task: *mut TaskHeader) {
        if self.run_queue.enqueue(cs, task) {
            (self.signal_fn)(self.signal_ctx)
        }
    }
```
If the task was enqueued then the signal_fn function will be called with the
signal_ctx passed into it. This will then wake up any core that issued a wait
for a signal.
The `executor.run` function will never return and looks like this:
```rust
    loop {
       unsafe { self.inner.poll() };
       cortex_m::asm::wfe();
    }
```
So it will try polling and then suspend execution until an interrupt occurs
or the `sev` instruction. And we say the usage of this instruction previously
where a task was enqueued.

```console
(gdb) br stm32f072b_disco_blinky::__embassy_main
```

------------------
(work in progress)
```rust
  DEVICE.configure(BlinkyDevice::new())
        .mount(spawner, config).await;
```
The above call to `mount` will land in function below:
```rust
impl<B: BlinkyBoard> BlinkyDevice<B> {
      /// The `Device` is exactly the typical drogue-device Device.
      pub fn new() -> Self {
          BlinkyDevice {
              app: ActorContext::new(),
              led: ActorContext::new(),
              button: ActorContext::new(),
          }
      }

      /// This is exactly the same operation performed during normal mount cycles
      /// in a non-BSP example.
      pub async fn mount(&'static self, spawner: Spawner, components: BlinkyConfiguration<B>) {
          defmt::info!("BlinkyDevice mount...");
          let led = self
              .led
              .mount(spawner, actors::led::Led::new(components.led));
          let app = self.app.mount(spawner, BlinkyApp::new(led));
          self.button.mount(
              spawner,
              actors::button::Button::new(components.control_button, app.into()),
          );
      }
  }

  pub struct BlinkyConfiguration<B: BlinkyBoard> {
      pub led: B::Led,
      pub control_button: B::ControlButton,
  }
```
The first thing that happens is that the ActorContext's mount function for the
`led` field will be called, passing in the spawner.
```rust
pub fn mount<S: ActorSpawner>(&'static self, spawner: S, actor: A) -> Address<A> {
        // Setup message channel
        self.channel.initialize();

        // Setup signal handlers
        self.signals.initialize();

        let actor = self.actor.put(actor);
        let inbox = self.channel.inbox();
        let address = Address::new(self);
        let future = actor.on_mount(address, inbox);
        let task = &self.task;
        // TODO: Map to error?
        spawner.spawn(task, future).unwrap();
        address
    }
```
Looking at `actor.on_mount` the Actor passed in is of type `actors::led::Led` in
(drogue-device/device/src/actors/led/mod.rs):
```rust
    fn on_mount<'m, M>(
        &'m mut self,
        _: Address<Self>,
        inbox: &'m mut M,
    ) -> Self::OnMountFuture<'m, M>
    where
        M: Inbox<Self> + 'm,
    {
        async move {
            loop {
                if let Some(mut m) = inbox.next().await {
                    let new_state = match *m.message() {
                        LedMessage::On => true,
                        LedMessage::Off => false,
                        LedMessage::State(state) => state,
                        LedMessage::Toggle => !self.state,
                    };
                    if self.state != new_state {
                        match match new_state {
                            true => self.led.on(),
                            false => self.led.off(),
                        } {
                            Ok(_) => {
                                self.state = new_state;
                            }
                            Err(_) => {}
                        }
                    }
                }
            }
        }
    }
```
So when this OnMountFuture is run later it will call inbox.next().await until
there is a message available in this Actors inbox. This value will be matched
against on of the LedMessage enum values and stored in `new_state`. This will
then be compared with the current state and if they are different depending on
the value the led will be turned on or off. And notice that this is in a loop
so it will again call `inbox.next().await` and yield.

So note that this function returns a Future which will then be passed to
`spawner.spawn(task, future)` where spawner is of type ActorSpawner:
```rust
impl ActorSpawner for Spawner {
    fn spawn<F: Future<Output = ()> + 'static>(
        &self,
        task: &'static Task<F>,
        future: F,
    ) -> Result<(), SpawnError> {
        Spawner::spawn(self, Task::spawn(task, move || future))
    }
}
```

Notice also that `mount` returns an address.
