This project is the humble beginnings of a market analysis/algo trading pipeline.

The code in this repo is written in Verilog for testing on a DE-10 Lite FPGA dev board. A Raspberry pi will be used to send data to the fpga for signal processing then the results will be sent bac to rpi or pc for visualization.

Testing on 5/15/26:
  Uart packet send/receive verified by serial debug. FPGA is performing math operations and displaying on LED Outputs.


Next Steps: 
  Iterate on current pipeline for accuracy
  Further develop trading analysis tools for integration into pipeline and testing.
