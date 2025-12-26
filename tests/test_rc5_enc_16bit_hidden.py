import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer
from cocotb.binary import BinaryValue
import random

@cocotb.test()
async def test_rc5_encryption_basic(dut):
    """Test basic RC5 encryption functionality"""
    # Create clock
    clock = Clock(dut.clock, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.reset.value = 0
    await RisingEdge(dut.clock)
    dut.reset.value = 1
    await RisingEdge(dut.clock)
    
    # Wait for initialization
    await Timer(20, units="ns")
    
    # Set plaintext and start encryption
    dut.p.value = 0xFFFF
    dut.enc_start.value = 1
    await RisingEdge(dut.clock)
    dut.enc_start.value = 0
    
    # Wait for encryption to complete (multiple cycles for key generation and rounds)
    # Key generation: 6 cycles
    # Init: 1 cycle
    # Round 1: 1 cycle
    # Round 2: 1 cycle
    # Total: ~9 cycles minimum
    for _ in range(20):
        await RisingEdge(dut.clock)
        if dut.enc_done.value == 1:
            break
    
    # Check that encryption is done
    assert dut.enc_done.value == 1, "Encryption should be complete"
    
    # Check that ciphertext is not equal to plaintext (basic encryption check)
    assert dut.c.value != 0xFFFF, "Ciphertext should differ from plaintext"

@cocotb.test()
async def test_rc5_encryption_multiple_inputs(dut):
    """Test RC5 encryption with multiple input values"""
    clock = Clock(dut.clock, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.reset.value = 0
    await RisingEdge(dut.clock)
    dut.reset.value = 1
    await RisingEdge(dut.clock)
    await Timer(20, units="ns")
    
    # Test multiple plaintext values
    test_cases = [0x0000, 0x1234, 0xABCD, 0xFFFF]
    
    for plaintext in test_cases:
        dut.p.value = plaintext
        dut.enc_start.value = 1
        await RisingEdge(dut.clock)
        dut.enc_start.value = 0
        
        # Wait for encryption
        for _ in range(20):
            await RisingEdge(dut.clock)
            if dut.enc_done.value == 1:
                break
        
        assert dut.enc_done.value == 1, f"Encryption should complete for input {hex(plaintext)}"
        assert dut.c.value != plaintext, f"Ciphertext should differ from plaintext for {hex(plaintext)}"

@cocotb.test()
async def test_reset_functionality(dut):
    """Test reset functionality"""
    clock = Clock(dut.clock, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Initial reset
    dut.reset.value = 0
    await RisingEdge(dut.clock)
    dut.reset.value = 1
    await RisingEdge(dut.clock)
    
    # Check initial state
    assert dut.enc_done.value == 0, "enc_done should be 0 after reset"
    
    # Start encryption
    dut.p.value = 0x1234
    dut.enc_start.value = 1
    await RisingEdge(dut.clock)
    dut.enc_start.value = 0
    
    # Reset during encryption
    await Timer(50, units="ns")
    dut.reset.value = 0
    await RisingEdge(dut.clock)
    dut.reset.value = 1
    await RisingEdge(dut.clock)
    
    # Check reset state
    assert dut.enc_done.value == 0, "enc_done should be 0 after reset"

# REQUIRED: Pytest wrapper function
def test_rc5_enc_16bit_hidden_runner():
    import os
    from pathlib import Path
    from cocotb_tools.runner import get_runner
    
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    
    sources = [
        proj_path / "sources/rc5_enc_16bit.sv",
        proj_path / "sources/CA_8bit.sv",
    ]
    
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="rc5_enc_16bit",
        always=True,
    )
    
    runner.test(hdl_toplevel="rc5_enc_16bit", test_module="test_rc5_enc_16bit_hidden")

