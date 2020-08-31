#![no_std]
#![feature(start)]
#![feature(asm)]

use t210;
use t210::RegIO;
use libtegra;
use register::register_bitfields;

#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
  unsafe {
    t210::PMC.write(t210::pmc::SCRATCH0, 0x02);
    t210::PMC.write(0x00, 0x10);
  }
  loop {}
}

#[repr(C)]
struct USBGadget {
  is_usb3: u8,
  init_hw_done: u8,
  init_proto_done: u8,
  unk0: u8,
  usb_device_init: extern "C" fn() -> i32,
  usb_init_proto: extern "C" fn(tempBuffer: &mut u8) -> i32, // Mutable? I dunno
  usb_device_read_ep1_out: extern "C" fn(buf: *mut u8, len :u32) -> i32,
  usb_device_read_ep1_out_sync: extern "C" fn(outNumBytes: *mut u32, dummy: *const u32, tempBuffer: *mut u32) -> i32,
  usb_device_write_ep1_in: extern "C" fn(buf: *const u8, len: u32) -> i32,
  usb_device_ep1_get_bytes_writing: extern "C" fn(outNumBytes: *mut u32, dummy: *const u32, tempBuffer: *mut u32) -> i32,
  usb_device_write_ep1_in_sync: extern "C" fn(buf: *const u8, len: u32, outTransferred: *mut u32) -> i32,
  usb_device_reset_ep1: extern "C" fn() -> i32,
}

// TODO: Multithread unsafe. Need to be locked

register_bitfields! {u32,
  pub APBDEV_PMC_SCRATCH0_0 [
    MODE_RCM OFFSET(1) NUMBITS(1) [],
    MODE_BOOTLOADER OFFSET(30) NUMBITS(1) [],
    MODE_RECOVERY OFFSET(31) NUMBITS(1) []
  ]
}

#[start]
fn main(_argc: isize, _argv: *const *const u8) -> isize {
  unsafe {
    //(*libtegra::pmc::REGISTERS).APBDEV_PMC_SCRATCH0_0.set(0x02);
    (*libtegra::pmc::REGISTERS).APBDEV_PMC_RST_STATUS_0.set(0x00);
    (*libtegra::pmc::REGISTERS).APBDEV_PMC_SCRATCH0_0.set(0x00);
    (*libtegra::pmc::REGISTERS).APBDEV_PMC_CNTRL_0.set(0x10);
    loop{}
    let rcm_usb: *const USBGadget = 0x40003114 as *const USBGadget;
    let mut foo: u32 = 0;
    let msg: &str = "Hello, world!";
    ((*rcm_usb).usb_device_write_ep1_in_sync)(msg.as_bytes().as_ptr(), 13, &mut foo);
    for _x in 0..1000 {
      asm!("nop");
    }
    //((*rcm_usb).usb_device_reset_ep1)();

    for _x in 0..100000 {
      asm!("nop");
      // Do nothing
    }
    // GO DIE!
    // SYSTEM RESET!!
    t210::PMC.write(t210::pmc::SCRATCH0, 0x02);
    t210::PMC.write(0x00, 0x10);
    //t210::CLOCK.write(t210::clock::, 0x04);
    loop {}
  }
}

#[no_mangle]
static __IRQ_HANDLER: extern "C" fn() = irq_handler;

extern "C" fn irq_handler() {}
