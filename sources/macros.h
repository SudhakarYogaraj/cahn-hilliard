// Quote cpp variable
#define xstr(s) str(s)
#define str(s) #s

// Methods for solution
#define E1 1
#define E1MOD 2
#define OD1 3
#define OD2 4
#define OD2MOD 5
#define LM1 6
#define LM2 7

// Types of boundary condition
#define MANUAL 0 // Default
#define LINEAR 1
#define CUBIC 2
#define MODIFIED 3

// Loop
#define LOOP_1_1(BODY)
#define LOOP_1_2(BODY) BODY(1)
#define LOOP_1_3(BODY) LOOP_1_2(BODY) BODY(2)
#define LOOP_1_4(BODY) LOOP_1_3(BODY) BODY(3)
#define LOOP_1_5(BODY) LOOP_1_4(BODY) BODY(4)
#define LOOP_1_6(BODY) LOOP_1_5(BODY) BODY(5)
#define LOOP_1_6(BODY) LOOP_1_5(BODY) BODY(5)
#define LOOP_1_7(BODY) LOOP_1_6(BODY) BODY(6)
#define LOOP_1_8(BODY) LOOP_1_7(BODY) BODY(7)
#define LOOP_1_9(BODY) LOOP_1_8(BODY) BODY(8)
#define LOOP_1_10(BODY) LOOP_1_9(BODY) BODY(9)
#define LOOP_1_11(BODY) LOOP_1_10(BODY) BODY(10)
#define LOOP_1_12(BODY) LOOP_1_11(BODY) BODY(11)
#define LOOP_1_13(BODY) LOOP_1_12(BODY) BODY(12)
#define LOOP_1_14(BODY) LOOP_1_13(BODY) BODY(13)
#define LOOP_1_15(BODY) LOOP_1_14(BODY) BODY(14)
#define LOOP_1_16(BODY) LOOP_1_15(BODY) BODY(15)
#define LOOP_1_17(BODY) LOOP_1_16(BODY) BODY(16)
#define LOOP_1_18(BODY) LOOP_1_17(BODY) BODY(17)
#define LOOP_1_19(BODY) LOOP_1_18(BODY) BODY(18)
#define LOOP_1_20(BODY) LOOP_1_19(BODY) BODY(19)
#define LOOP_1_21(BODY) LOOP_1_20(BODY) BODY(20)
#define LOOP_1_22(BODY) LOOP_1_21(BODY) BODY(21)
#define LOOP_1_23(BODY) LOOP_1_22(BODY) BODY(22)
#define LOOP_1_24(BODY) LOOP_1_23(BODY) BODY(23)
#define LOOP_1_25(BODY) LOOP_1_24(BODY) BODY(24)
#define LOOP_1_26(BODY) LOOP_1_25(BODY) BODY(25)
#define LOOP_1_27(BODY) LOOP_1_26(BODY) BODY(26)
#define LOOP_1_28(BODY) LOOP_1_27(BODY) BODY(27)
#define LOOP_1_29(BODY) LOOP_1_28(BODY) BODY(28)
#define LOOP_1_30(BODY) LOOP_1_29(BODY) BODY(29)

#define LOOP_1(b,BODY) LOOP_1_##b(BODY)
#define LOOP_0(b,BODY) BODY(0) LOOP_1(b,BODY)
#define LOOP(a,b,BODY) LOOP_##a(b,BODY)
