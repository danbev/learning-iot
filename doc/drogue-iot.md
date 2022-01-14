### Drogue Device

### Actor trait
An Actor has a Message type that it can handle which is specified using an 
associated type in the trait:
```rust
pub trait Actor: Sized {
    type Message<'m>: Sized
    where
        Self: 'm,                                                                  
    = ();                                                                          
```
Now, my understanding of this is that this is declaring a type named `Message`
which has a lifetime, `'m`. This type has a bound (a constraint) that it must
be of type Sized. And it also has a lifetime bound "Self: 'm" which specifies
that any reference to `Self` will live at least as long as 'm (which notice is
on the type Message and not on Self. Also is type is given a default value of
the unit type `()`. 

An Actor will also define a Future type that is returned from its `on_mount`
function:
```rust
    type OnMountFuture<'m, M>: Future<Output = ()>
    where
        Self: 'm,
        M: 'm;

    fn on_mount<'m, M>(&'m mut self, _: Address<Self>, _: &'m mut M) -> Self::OnMountFuture<'m, M>
    where
        M: Inbox<Self> + 'm;
}
```

### ActorContext


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
The `cortex_m::asm::sev()` function will call the assembly instruction sev:
```rust
pub fn sev() {
    call_asm!(__sev())
}
```
After the executor has been created, `embassy_stm32::init` is called which takes
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
    executor.run(|spawner|
                     { spawner.must_spawn(__embassy_main(spawner, p)); })

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
`init` is passed a new instance of Spawner using `self.inner.spawner`:
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
is then passed to `Executor::init`. Below I'm showing the call to run in
addition to the call to init so that we can see the values more clearly:
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
templated with anything that implements `core::future::Future` and does not
contain any non-static references:
```rust
pub struct SpawnToken<F> {
    raw_task: Option<NonNull<raw::TaskHeader>>,
    phantom: PhantomData<*mut F>,
}
```
Next, we have the definition of a function named `task` that is async, so
actually executing this function would return a Future (which we will see
shortly). But also notice that we are creating a closure
`move || task(spawner, p)` and it is this closure that is being passed into the
`spawn_pool` function.

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
The above call to `critical_section::with`  will execute the closure passed to
it but it will first aquire a critical section token, which is a section where
the code will not be preemted), then execute the closure, and afterwards
release the critical section token.

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
          let led_address = self
              .led
              .mount(spawner, actors::led::Led::new(components.led));

          let app = self.app.mount(spawner, BlinkyApp::new(led_address));
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
The first thing that happens is that the ActorContext's `mount` function for the
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
Notice that `on_mount` returns a future and that this future will be passed
to `spawner.span` later in `ActorSpawner'. So when this OnMountFuture is run
later it will call inbox.next().await until there is a message available in this
Actors inbox. This value will be matched against on of the LedMessage enum
values and stored in `new_state`. This will then be compared with the current
state and if they are different depending on the value the led will be turned
on or off. And notice that this is in a loop so it will again callx
 `inbox.next().await` and yield.

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


### STM32F072 Discovery Board
To understand drogue-device better I wanted to add a board specific package
(BSP) for the board I'm using at the moment.

I started out by adding an example that uses the LEDs and the user button on the
board which was very easy,
[blinky-example](https://github.com/danbev/drogue-device/blob/stm32f072-discovery-board/examples/stm32f0/stm32f072b-disco/blinky/src/main.rs).

But when I wanted to add an example that uses USART1, [uart-example](https://github.com/danbev/drogue-device/blob/stm32f072-discovery-board/examples/stm32f0/stm32f072b-disco/uart/src/main.rs), I ran into an issue. What I wanted
to do is to pass in a configuration object to the Board so that a user can
specify which UART1 Port/Pins combinations available on this board. So a user
can either use `PA9` and `PA10` or `PB6` and `PB7` when using USART1 on this
boardand this was something that I thought would be useful to be able to
configure. 

Now, Embassy does have a configuration attribute that can configure the chip
and this can be specified:
```rust
#[embassy::main(config = "config()")]
```
But as far as I understand this is only to configure Embassy and not something
that is available to a Board implementation. After trying out different things I
came up with the suggestion to add an associated type to
[Board trait](https://github.com/danbev/drogue-device/blob/stm32f072-discovery-board/device/src/bsp/mod.rs#L8):
```rust
/// A board capable of creating itself using peripherals.
pub trait Board: Sized {
    type Peripherals;
    type Config;

    fn new(peripherals: Self::Peripherals, config: Option<Self::Config>) -> Self;
}
```
The `Config` type is new here and indended to allows a Board implementation to
optionally have a Configuration of a type specifically for that board, for
example 
[Stm32f072bDisco](https://github.com/danbev/drogue-device/blob/stm32f072-discovery-board/device/src/bsp/boards/stm32f0/stm32f072b_disco.rs#L53-L57):
```rust
impl Board for Stm32f072bDisco<'_> {
    type Peripherals = embassy_stm32::Peripherals;
    type Config = Stm32f072bDiscoConfig;

    fn new(p: Self::Peripherals, config: Option<Self::Config>) -> Self {
        let usart1 = match config {
            None => None,
            Some(board_config) => match board_config.uart_config {
                UartConfig::Uart1PortA => Some(Uart::new(
                    p.USART1,
                    p.PA10,
                    p.PA9,
                    NoDma,
                    NoDma,
                    Config::default(),
                )),
                UartConfig::Uart1PortB => Some(Uart::new(
                    p.USART1,
                    p.PB7,
                    p.PB6,
                    NoDma,
                    NoDma,
                    Config::default(),
                )),
            },
        };
        ...
```

This configuration can then be used by an application like this:
```rust
#[embassy::main(config = "config()")]
async fn main(_spawner: embassy::executor::Spawner, p: Peripherals) {
    let board_config = BoardConfig { uart_config: Uart1PortB};
    let mut usart1 = BSP::new(p, Some(board_config)).0.usart1.unwrap();

    usart1.bwrite_all(b"STM32F072B Discovery Board UART Example\r\n").unwrap();
    usart1.bwrite_all(Stm32f072bDisco::uart_description(&board_config.uart_config)).unwrap();
}
```

To run the uart example first start minicom in a terminal:
```console
$ minicom --baudrate 115200 --device /dev/ttyUSB0
```

Next run the uart example:
```console
$ cd drogue-device/examples/stm32f0/stm32f072b-disco/uart
$ cargo run
    Finished dev [optimized + debuginfo] target(s) in 0.12s
     Running `probe-run --chip STM32F072R8Tx /home/danielbevenius/work/drougue/drogue-device/examples/stm32f0/stm32f072b-disco/target/thumbv6m-none-eabi/debug/stm32f072b-disco-uart`
(HOST) INFO  flashing program (24 pages / 24.00 KiB)
(HOST) INFO  success!
────────────────────────────────────────────────────────────────────────────────
```

And in the minicom terminal the following output should be displayed:
```console
Welcome to minicom 2.7.1

OPTIONS: I18n 
Compiled on Jan 26 2021, 00:00:00.
Port /dev/ttyUSB0, 05:36:23

Press CTRL-A Z for help on special keys

STM32F072B Discovery Board UART Example
UART1 Tx: PB6, Rx: PB7 
```

