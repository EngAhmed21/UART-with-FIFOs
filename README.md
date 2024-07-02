# UART-with-FIFOs

This is the implemetation of a system that consists of 2 FIFOs and a UART interface. The implementation is done using SystenVerilog, and the test is done in two methods: SystemVerilog tesbench and a UVM environment. The simulation is done using QuestaSim.

UART means Universal Asynchronous Receiver Transmitter Protocol. UART is used for serial communication from the name itself we can understand the functions of UART, where U stands for Universal which means this protocol can be applied to any transmitter and receiver, and A is for Asynchronous which means one cannot use clock signal for communication of data and R and T refers to Receiver and Transmitter. 

In asynchronous communication, data is transmitted without a synchronized clock signal. Each device in the communication line must agree on a specific baud rate (bits per second) beforehand to ensure proper timing for data transmission and reception. Devices can communicate without needing to share a common clock, which simplifies the wiring and reduces the cost. However, both devices must precisely match their baud rates.

The baud rate is the speed at which data is transmitted, measured in bits per second (bps). Common baud rates include 9600, 19200, 38400, 57600, and 115200 bps. Both the transmitter and receiver must operate at the same baud rate to correctly interpret the data being sent.

UART supports full duplex communication, meaning it can send and receive data simultaneously. This is achieved using separate lines for transmission (TX) and reception (RX). Full duplex allows for efficient communication, as data can flow in both directions without waiting.

![UART2-660x403](https://github.com/EngAhmed21/UART-with-FIFOs/assets/90782588/af0449d9-670f-4df6-a112-92da997d5757)

To calculate the baud rate for a UART communication:                                                                                                                                                                                                                                                                                                                
1- For a 'normal' UART, baud == bit rate, so 115200 baud = 115200 bit rate = 11.520 kBps (assuming 8N1 which means 8 bits data + 1 start bit + 1 stop bit.                                                                                                                                                                                                                                                                 
2- The main formula to calculate the baud rate is: Baud rate = Bit rate / Number of bits in a baud.                                                                                                                                                                                                                                                     
3- The actual Baud Rate is given by BR = FP / (16 * (UxBRG + 1)), where UxBRG is the UART Baud Rate Generator register value.                                                                                                                                                                                                                                               
4- For example, if the Baud Rate is 9600 and PCLK is 60MHz, the calculation would be: U0DLL = 60000000 / (16 * 9600) = 390.625 (~390).

Data is transmitted with a start bit, data bits, an optional parity bit, and stop bits:                                                                                                                                                         
- The start bit is a signal that indicates the beginning of a new data frame. It is a single bit with a value of 0 (low voltage) that informs the receiver that data transmission is about to begin. The start bit allows the receiver to synchronize with the incoming data stream and prepare to read the data bits.
- Data bits are the actual bits of data being transmitted. UART can be configured to send 5 to 9 data bits in each frame, with 8 bits being the most common configuration. The number of data bits can be adjusted based on the requirements of the application, providing flexibility in data transmission.
- The parity bit is an optional error-checking mechanism that can be added to each data frame. It can be configured as even, odd, or none. Even parity means the total number of 1s in the data bits and the parity bit is even. Odd parity means the total number is odd. Parity bits help detect single-bit errors in data transmission, improving communication reliability.
- Stop bits signal the end of a data frame. They are used to indicate the completion of data transmission and allow the receiver to identify the end of the data packet. Common configurations are 1 or 2 stop bits. Stop bits provide a brief pause between data frames, allowing the receiver time to process the received data and prepare for the next frame.

![UARTdataformat-660x170](https://github.com/EngAhmed21/UART-with-FIFOs/assets/90782588/6e8312c1-761b-4f5b-8f5e-4479442b04b2)
           
How UART Works:                                                                                                                                                                                                                                                                                                                
1- Transmission >> The UART transmitter converts parallel data from a microcontroller or computer into serial form. The data frame starts with a start bit, followed by the configured number of data bits, an optional parity bit, and one or more stop bits. The data is transmitted at the pre-configured baud rate.                                                                                                                                                                                                                                                                                                                
2- Reception >> The UART receiver then converts the serial data back into parallel form for use by the microcontroller or computer. It detects the start bit and begins reading the incoming data bits at the configured baud rate. After reading the data bits, it checks the parity bit (if used) and looks for the stop bits to confirm the end of the frame.  It may also flag any errors detected during the process, such as parity errors or framing errors (missing or incorrect stop bits).

UART System Implementation:                                                                                                                                                                                                                                                             
In this system, I have used RX and TX FIFOs to represent the transmitter and the receiver which is reasonable, as in real systems the UART is very slow according to the computer so a buffer must be used. So the system contains: 2 FIFOs, UART Transmitter logic, UART Receiver logic, and the Baud-rate generator (which is a timer).                                                                                                                                                                                                                                                      
1- UART Receiver logic:

![Screenshot (887)](https://github.com/EngAhmed21/UART-with-FIFOs/assets/90782588/aef55e99-8988-47b2-a5e1-e213e4f6f6d2)

2- UART Transmitter logic:

![Screenshot (888)](https://github.com/EngAhmed21/UART-with-FIFOs/assets/90782588/9f0ced6b-a607-42cd-9793-945d1a53188e)

3- Full System:

![Screenshot (886)](https://github.com/EngAhmed21/UART-with-FIFOs/assets/90782588/3962ed48-e10f-4b83-ad44-c97c7fb0e3cc)

The design is tested in two methods:                                                                                                                                                                                                                                                       
1- A SystemVerilog testbench that uses many features of SystemVerilog as: Constraint Randomization, Assertions, and Functional Coverage.                                                                                                                                                                                                                                       
2- A UVM environment that uses the same features of the SV testbench in addition to the advantages of UVM as: Standardization, Reusability, Scalability, and Automation.  

Test Methodology:                                                                                                                                                                                                                                              
- Each design has assertions defined between ifdef and endif preprocessor directives that tests the internal signals and ensures that every thing is correct.                                                                                                                                                       
- Each components has its testbench (or UVM environment) that generates stimulus and tests the functionality of the component with respect to a defined reference model.                                                                                                                                                         
- Covergroups are used to gather the functional coverage informations.                                                                                                                                                                                          
- Constraint randomization is used to automate the stimulus generation.                                                                                                                                                                                          
- In the UVM environment, I use the environments of the components in the environment of the UART System to use the scoreboards and coverage collectors of the components to ease finding the source of errors.                                                                                                                                                                                          

Simulation Results:                                                                                                                                                                                                                                              
 - Waveform
   
  ![Waveform](https://github.com/EngAhmed21/UART-with-FIFOs/assets/90782588/951b029f-a765-42ad-98c8-32e7424fdcee)
  ![2](https://github.com/EngAhmed21/UART-with-FIFOs/assets/90782588/598759b2-c508-460a-86ae-39ea296cef18)
  ![3](https://github.com/EngAhmed21/UART-with-FIFOs/assets/90782588/f8ee8d50-6cbe-4767-862f-0857dc302a1c)
  ![4](https://github.com/EngAhmed21/UART-with-FIFOs/assets/90782588/f9f601d2-c15c-4e25-bb13-39429651cafd)

 - Transcript
   
   ![T1](https://github.com/EngAhmed21/UART-with-FIFOs/assets/90782588/1b274b80-56fd-40b3-aab6-c3073d4f5c14)
   ![T2](https://github.com/EngAhmed21/UART-with-FIFOs/assets/90782588/fafae0d6-55c7-4b00-946e-b18e941c2321)

 - Functional Coverage
   
![coverage](https://github.com/EngAhmed21/UART-with-FIFOs/assets/90782588/75e62b1b-ffe8-4156-9997-121ae11cf4c1)

 - Assertions

![Assertions](https://github.com/EngAhmed21/UART-with-FIFOs/assets/90782588/706b2d6c-c086-4c37-b8bb-2f232b043845)
![Assertions2](https://github.com/EngAhmed21/UART-with-FIFOs/assets/90782588/74a57ef2-edf2-475b-bfdf-de520f87c855)


 - Coverage Directives

   ![Cover_directives](https://github.com/EngAhmed21/UART-with-FIFOs/assets/90782588/020a6ee5-38d2-44db-9cf4-9cd2e00bcd12)
