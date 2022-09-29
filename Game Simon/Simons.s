.data
sequence:  .byte 0,0,0,0
count:     .word 4
green:    .word 0x00FF00
orange:   .word 0xFFA500
blue:     .word 0x0000FF
pink:     .word 0xFFB6C1
black:     .word 0x000000
red:     .word 0xff0000
yellow:     .word 0xFFFF00

promptA: .string "Do you want to play again, type 1 to continue or 0 to terminate the game?"

.globl main
.text


main:
    # TODO: Before we deal with the LEDs, we need to generate a random
    # sequence of numbers that we will use to indicate the button/LED
    # to light up. For example, we can have 0 for UP, 1 for DOWN, 2 for
    # LEFT, and 3 for RIGHT. Store the sequence in memory. We provided 
    # a declaration above that you can use if you want.
    # HINT: Use the rand function provided to generate each number
    li s0 4  #size of the sequence 
    li s1 0  #loop counter (bytes)
    la s2 sequence  # the base address of the sequence
    mv s3 s2  # the current address  

for: 
    beq s1, s0 stop
    li s4 4
    mv a0 s4
    jal rand
    sb a0, 0(s3) #store byte in#   
    #li a7, 1 # print out the return of the func
    #ecall
    addi s1, s1, 1
    add s3, s2, s1
    j for
stop: 
    mv s11 sp
    addi sp, sp, -1
    #li a7, 1 #
    lb t4, 0(s2)
    mv a0 t4 #
    #ecall #
    sb t4, 0(sp)

    addi sp, sp, -1
    #li a7, 1 #
    lb t4, 1(s2)
    mv a0 t4 #
    #ecall #
    sb t4, 0(sp)
    
    addi sp, sp, -1
    #li a7, 1 #
    lb t4, 2(s2)
    mv a0 t4 #
    #ecall #
    sb t4, 0(sp)

    
    addi sp, sp, -1
    #li a7, 1 #
    lb t4, 3(s2)
    mv a0 t4 #
    #ecall #
    sb t4, 0(sp)
    

    # TODO: Now read the sequence and replay it on the LEDs. You will
    # need to use the delay function to ensure that the LEDs light up 
    # slowly. In general, for each number in the sequence you should:
          
    # 1. Figure out the corresponding LED location and colour
    # 2. Light up the appropriate LED (with the colour)
    # 2. Wait for a short delay (e.g. 500 ms)
    # 3. Turn off the LED (i.e. set it to black)
    # 4. Wait for a short delay (e.g. 1000 ms) before repeating
    jal lightUp
   
    # TODO: Read through the sequence again and check for user input
    # using pollDpad. For each number in the sequence, check the d-pad
    # input and compare it against the sequence. If the input does not
    # match, display some indication of error on the LEDs and exit. 
    # Otherwise, keep checking the rest of the sequence and display 
    # some indication of success once you reach the end.
    
    jal check

    # TODO: Ask if the user wishes to play again and either loop back to
    # start a new round or terminate, based on their input.
    
playAgain:    
      li a7, 4
	  la a0, promptA
	  ecall

      call readInt
      mv s7 a0
    
      # store 0 and 1
      li t5 0
      li t6 1

    if3:
       beq s7, t5 exit
       beq s7, t6 again
    again:
       
       # put the new element on to stack
       addi sp, sp, -1
       # call rand
       li s4 4
       mv a0 s4
       jal rand    
       sb a0, 0(sp)
       #light up
       addi s0, s0, 1 # add 1 to 4
       jal lightUp
       jal check
       
       j playAgain
 
exit:
    li a7, 10
    ecall
    
    
# --- HELPER FUNCTIONS ---
# Feel free to use (or modify) them however you see fit
     
# Takes in the number of milliseconds to wait (in a0) before returning
delay:
    mv t0, a0
    li a7, 30
    ecall
    mv t1, a0
delayLoop:
    ecall
    sub t2, a0, t1
    bgez t2, delayIfEnd
    addi t2, t2, -1
delayIfEnd:
    bltu t2, t0, delayLoop
    jr ra

# Takes in a number in a0, and returns a (sort of) random number from 0 to
# this number (exclusive)
rand:
    mv t0, a0
    li a7, 30 # what does the 30 means?
    ecall
    remu a0, a0, t0
    jr ra
    
# Takes in an RGB color in a0, an x-coordinate in a1, and a y-coordinate
# in a2. Then it sets the led at (x, y) to the given color.
setLED:
    li t1, LED_MATRIX_0_WIDTH
    mul t0, a2, t1
    add t0, t0, a1
    li t1, 4
    mul t0, t0, t1
    li t1, LED_MATRIX_0_BASE
    add t0, t1, t0
    sw a0, (0)t0
    jr ra
    
# Polls the d-pad input until a button is pressed, then returns a number
# representing the button that was pressed in a0.
# The possible return values are:
# 0: UP
# 1: DOWN
# 2: LEFT
# 3: RIGHT
pollDpad:
    mv a0, zero
    li t1, 4
pollLoop:
    bge a0, t1, pollLoopEnd
    li t2, D_PAD_0_BASE
    slli t3, a0, 2
    add t2, t2, t3
    lw t3, (0)t2
    bnez t3, pollRelease
    addi a0, a0, 1
    j pollLoop
pollLoopEnd:
    j pollDpad
pollRelease:
    lw t3, (0)t2
    bnez t3, pollRelease
pollExit:
    jr ra
    
lightUp:
    mv s10 ra
    li s1 0  #loop counter
    mv s3 s11  # the current address 
    addi s3, s3, -1 
for1:
    beq s1, s0 stop1
    lb s4, 0(s3)
    #addi s3, s3, -1
    
    #li a7, 1 # print out the return of the func
    mv a0 s4
    #ecall
    
    li t5 0
    li t6 1
    li s5 2
    li s6 3
    if:
       beq s4, t5 c0
       beq s4, t6 c1
       beq s4, s5 c2
       beq s4, s6 c3
       
x: 
   addi s3, s3, -1
   addi s1, s1, 1
   j for1  
    
# branch 0   
    c0:
      #light up (1, 0)
      lw a0 green
      li a1 1
      li a2 0
      jal setLED
      #light up (2, 0)
      lw a0 green
      li a1 2
      li a2 0
      jal setLED
      
      #delay
      li a0 500
      jal delay
      
      #turn off 
      lw a0 black
      li a1 1
      li a2 0
      jal setLED
      lw a0 black
      li a1 2
      li a2 0
      jal setLED
      
      #delay
      li a0 500
      jal delay
      
      j x

# branch 1
    c1:
      #light up (1, 2)
      lw a0 orange
      li a1 1
      li a2 2
      jal setLED
      #light up (0, 2)
      lw a0 orange
      li a1 0
      li a2 2
      jal setLED
      
      #delay
      li a0 500
      jal delay
      
      #turn off 
      lw a0 black
      li a1 1
      li a2 2
      jal setLED
      lw a0 black
      li a1 0
      li a2 2
      jal setLED
      
      #delay
      li a0 500
      jal delay
      
      j x
    
# branch 2
    c2:  
      #light up (0, 1)
      lw a0 blue
      li a1 0
      li a2 1
      jal setLED
      #light up (0, 0)
      lw a0 blue
      li a1 0
      li a2 0
      jal setLED
      
      #delay
      li a0 500
      jal delay
      
      #turn off 
      lw a0 black
      li a1 0
      li a2 1
      jal setLED
      lw a0 black
      li a1 0
      li a2 0
      jal setLED
      #delay
      li a0 500
      jal delay
      
      j x
      
# branch 3  
    c3: 
      #light up (2, 1)
      lw a0 pink
      li a1 2
      li a2 1
      jal setLED
      #light up (2, 2)
      lw a0 pink
      li a1 2
      li a2 2
      jal setLED
      
      #delay
      li a0 500
      jal delay
      
      #turn off 
      lw a0 black
      li a1 2
      li a2 1
      jal setLED
      lw a0 black
      li a1 2
      li a2 2
      jal setLED
      
      #delay
      li a0 500
      jal delay
      
      j x
stop1:    
      mv ra s10
      jr ra
      
# click flash          
flash:
      mv s9 ra
      mv s8 a0
      #li s8 0
      #add s8 s8 a0
      
      li t5 0
      li t6 1
      li s5 2
      li s6 3
      
      beq s8, t5 b0
      beq s8, t6 b1
      beq s8, s5 b2
      beq s8, s6 b3
       
# branch 0   
    b0:
      #light up (1, 0)
      lw a0 green
      li a1 1
      li a2 0
      jal setLED
      #light up (2, 0)
      lw a0 green
      li a1 2
      li a2 0
      jal setLED
      
      #delay
      li a0 500
      jal delay
      
      #turn off 
      lw a0 black
      li a1 1
      li a2 0
      jal setLED
      lw a0 black
      li a1 2
      li a2 0
      jal setLED

      
      
      mv a0 s8
      mv ra s9
      jr ra     

# branch 1
    b1:
      #light up (1, 2)
      lw a0 orange
      li a1 1
      li a2 2
      jal setLED
      #light up (0, 2)
      lw a0 orange
      li a1 0
      li a2 2
      jal setLED
      
      #delay
      li a0 500
      jal delay
      
      #turn off 
      lw a0 black
      li a1 1
      li a2 2
      jal setLED
      lw a0 black
      li a1 0
      li a2 2
      jal setLED
      
      
      mv a0 s8
      mv ra s9
      jr ra     
          
# branch 2
    b2:  
      #light up (0, 1)
      lw a0 blue
      li a1 0
      li a2 1
      jal setLED
      #light up (0, 0)
      lw a0 blue
      li a1 0
      li a2 0
      jal setLED
      
      #delay
      li a0 500
      jal delay
      
      #turn off 
      lw a0 black
      li a1 0
      li a2 1
      jal setLED
      lw a0 black
      li a1 0
      li a2 0
      jal setLED

      mv a0 s8
      mv ra s9
      jr ra
        
# branch 3  
    b3: 
      #light up (2, 1)
      lw a0 pink
      li a1 2
      li a2 1
      jal setLED
      #light up (2, 2)
      lw a0 pink
      li a1 2
      li a2 2
      jal setLED
      
      #delay
      li a0 500
      jal delay
      
      #turn off 
      lw a0 black
      li a1 2
      li a2 1
      jal setLED
      lw a0 black
      li a1 2
      li a2 2
      jal setLED
      
      mv a0 s8
      mv ra s9
      jr ra
      

check:
    mv s10 ra
    li s1 0  #loop counter
    mv s3 s11  # the current address s11
    addi s3, s3, -1 
    
for2:
    beq s1, s0 stop2
    lb s4, 0(s3)
    
    jal pollDpad
    jal flash
    
    if2:
       beq a0, s4 eql
       bne a0, s4 neq
       
    eql:
       addi s1, s1, 1
       addi s3, s3, -1 
       j for2   
    neq:
       #delay
       li a0 500
       jal delay
       #light up (0, 0)
       lw a0 red
       li a1 0
       li a2 0
       jal setLED  
       #light up (1, 0)
       lw a0 red
       li a1 1
       li a2 0
       jal setLED
       #light up (2, 0)
       lw a0 red
       li a1 2
       li a2 0
       jal setLED     
       #light up (0, 1)
       lw a0 red
       li a1 0
       li a2 1
       jal setLED
       #light up (1, 1)
       lw a0 red
       li a1 1
       li a2 1
       jal setLED 
       #light up (2, 1)
       lw a0 red
       li a1 2
       li a2 1
       jal setLED 
       #light up (0, 2)
       lw a0 red
       li a1 0
       li a2 2
       jal setLED
       #light up (1, 2)
       lw a0 red
       li a1 1
       li a2 2
       jal setLED 
       #light up (2, 2)
       lw a0 red
       li a1 2
       li a2 2
       jal setLED 
       
       #delay
       li a0 500
       jal delay
       
       #light up (0, 0)
       lw a0 black
       li a1 0
       li a2 0
       jal setLED  
       #light up (1, 0)
       lw a0 black
       li a1 1
       li a2 0
       jal setLED
       #light up (2, 0)
       lw a0 black
       li a1 2
       li a2 0
       jal setLED     
       #light up (0, 1)
       lw a0 black
       li a1 0
       li a2 1
       jal setLED
       #light up (1, 1)
       lw a0 black
       li a1 1
       li a2 1
       jal setLED 
       #light up (2, 1)
       lw a0 black
       li a1 2
       li a2 1
       jal setLED 
       #light up (0, 2)
       lw a0 black
       li a1 0
       li a2 2
       jal setLED
       #light up (1, 2)
       lw a0 black
       li a1 1
       li a2 2
       jal setLED 
       #light up (2, 2)
       lw a0 black
       li a1 2
       li a2 2
       jal setLED
       
       jal exit

stop2:
       #delay
       li a0 500
       jal delay
       #light up (0, 0)
       lw a0 yellow
       li a1 0
       li a2 0
       jal setLED  
       #light up (1, 0)
       lw a0 yellow
       li a1 1
       li a2 0
       jal setLED
       #light up (2, 0)
       lw a0 yellow
       li a1 2
       li a2 0
       jal setLED     
       #light up (0, 1)
       lw a0 yellow
       li a1 0
       li a2 1
       jal setLED
       #light up (1, 1)
       lw a0 yellow
       li a1 1
       li a2 1
       jal setLED 
       #light up (2, 1)
       lw a0 yellow
       li a1 2
       li a2 1
       jal setLED 
       #light up (0, 2)
       lw a0 yellow
       li a1 0
       li a2 2
       jal setLED
       #light up (1, 2)
       lw a0 yellow
       li a1 1
       li a2 2
       jal setLED 
       #light up (2, 2)
       lw a0 yellow
       li a1 2
       li a2 2
       jal setLED 
       
       #delay
       li a0 500
       jal delay
      
       #light up (0, 0)
       lw a0 black
       li a1 0
       li a2 0
       jal setLED  
       #light up (1, 0)
       lw a0 black
       li a1 1
       li a2 0
       jal setLED
       #light up (2, 0)
       lw a0 black
       li a1 2
       li a2 0
       jal setLED     
       #light up (0, 1)
       lw a0 black
       li a1 0
       li a2 1
       jal setLED
       #light up (1, 1)
       lw a0 black
       li a1 1
       li a2 1
       jal setLED 
       #light up (2, 1)
       lw a0 black
       li a1 2
       li a2 1
       jal setLED 
       #light up (0, 2)
       lw a0 black
       li a1 0
       li a2 2
       jal setLED
       #light up (1, 2)
       lw a0 black
       li a1 1
       li a2 2
       jal setLED 
       #light up (2, 2)
       lw a0 black
       li a1 2
       li a2 2
       jal setLED
       
       mv ra s10
       jr ra
       
    
readInt:
    addi sp, sp, -12
    li a0, 0
    mv a1, sp
    li a2, 12
    li a7, 63
    ecall
    li a1, 1
    add a2, sp, a0
    addi a2, a2, -3
    mv a0, zero
parse:
    blt a2, sp, parseEnd
    lb a7, 0(a2)
    addi a7, a7, -48
    li a3, 9
    bltu a3, a7, error
    mul a7, a7, a1
    add a0, a0, a7
    li a3, 10
    mul a1, a1, a3
    addi a2, a2, -1
    j parse
parseEnd:
    addi sp, sp, 12
    ret

error:
    li a7, 93
    li a0, 1
    ecall

