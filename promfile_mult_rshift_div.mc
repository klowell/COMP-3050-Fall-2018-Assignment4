0:mar := pc; rd; 				{ main loop  }
1:pc := 1 + pc; rd; 				{ increment pc }
2:ir := mbr; if n then goto 28; 		{ save, decode mbr }
3:tir := lshift(ir + ir); if n then goto 19;
4:tir := lshift(tir); if n then goto 11; 	{ 000x or 001x? }
5:alu := tir; if n then goto 9; 		{ 0000 or 0001? }
6:mar := ir; rd; 				{ 0000 = LODD }
7:rd;
8:ac := mbr; goto 0;
9:mar := ir; mbr := ac; wr; 			{ 0001 = STOD }
10:wr; goto 0;
11:alu := tir; if n then goto 15; 		{ 0010 or 0011? }
12:mar := ir; rd; 				{ 0010 = ADDD }
13:rd;
14:ac := ac + mbr; goto 0;
15:mar := ir; rd; 				{ 0011 = SUBD }
16:ac := 1 + ac; rd; 				{ Note: x - y = x + 1 + not y }
17:a := inv(mbr);
18:ac := a + ac; goto 0;
19:tir := lshift(tir); if n then goto 25; 	{ 010x or 011x? }
20:alu := tir; if n then goto 23; 		{ 0100 or 0101? }
21:alu := ac; if n then goto 0; 		{ 0100 = JPOS }
22:pc := band(ir, amask); goto 0; 		{ perform the jump }
23:alu := ac; if z then goto 22; 		{ 0101 = JZER }
24:goto 0;					{ jump failed }
25:alu := tir; if n then goto 27; 		{ 0110 or 0111? }
26:pc := band(ir, amask); goto 0; 		{ 0110 = JUMP }
27:ac := band(ir, amask); goto 0; 		{ 0111 = LOCO }
28:tir := lshift(ir + ir); if n then goto 40; 	{ 10xx or 11xx? }
29:tir := lshift(tir); if n then goto 35; 	{ 100x or 101x? }
30:alu := tir; if n then goto 33; 		{ 1000 or 1001? }
31:a := sp + ir; 				{ 1000 = LODL }
32:mar := a; rd; goto 7;
33:a := sp + ir; 				{ 1001 = STOL }
34:mar := a; mbr := ac; wr; goto 10;
35:alu := tir; if n then goto 38; 		{ 1010 or 1011? }
36:a := sp + ir; 				{ 1010 = ADDL }
37:mar := a; rd; goto 13;
38:a := sp + ir; 				{ 1011 = SUBL }
39:mar := a; rd; goto 16;
40:tir := lshift(tir); if n then goto 46; 	{ 110x or 111x? }
41:alu := tir; if n then goto 44; 		{ 1100 or 1101? }
42:alu := ac; if n then goto 22; 		{ 1100 = JNEG }
43:goto 0;
44:alu := ac; if z then goto 0; 		{ 1101 = JNZE }
45:pc := band(ir, amask); goto 0;
46:tir := lshift(tir); if n then goto 50;
47:sp := sp + (-1); 				{ 1110 = CALL }
48:mar := sp; mbr := pc; wr;
49:pc := band(ir, amask); wr; goto 0;
50:tir := lshift(tir); if n then goto 65;	{ 1111, examine addr }
51:tir := lshift(tir); if n then goto 59;
52:alu := tir; if n then goto 56;
53:mar := ac; rd;				{ 1111 000 0 = PSHI }
54:sp := sp + (-1); rd;
55:mar := sp; wr; goto 10;
56:mar := sp; sp := sp + 1; rd; 		{ 1111 001 0 = POPI }
57:rd;
58:mar := ac; wr; goto 10;
59:alu := tir; if n then goto 62;
60:sp := sp + (-1); 				{ 1111 010 0 = PUSH }
61:mar := sp; mbr := ac; wr; goto 10;
62:mar := sp; sp := sp + 1; rd; 		{ 1111 011 0 = POP }
63:rd;
64:ac := mbr; goto 0;
65:tir := lshift(tir); if n then goto 73;
66:alu := tir; if n then goto 70;
67:mar := sp; sp := sp + 1; rd; 		{ 1111 100 0 = RETN }
68:rd;
69:pc := mbr; goto 0;
70:a := ac; 					{ 1111 101 0 = SWAP }
71:ac := sp;
72:sp := a; goto 0;
73:tir := lshift(tir); if n then goto 76;
74:a := band(ir, smask); 			{ 1111 110 0 = INSP }
75:sp := sp + a; goto 0;
76:tir := lshift(tir); if n then goto 80;
77:a := band(ir, smask); 			{ 1111 111 0 = DESP }
78:a := inv(a);
79:a := a + 1; goto 75;
80:tir := lshift(tir); if n then goto 111;	{ 1111 1111 0x or 1111 1111 1x? }
81:tir := lshift(tir); if n then goto 104;	{ 1111 1111 01 = RSHIFT }
82:a := lshift(1);				{ 1111 1111 00 = MULT }
83:a := lshift(a + 1);
84:a := lshift(a + 1);
85:a := lshift(a + 1);
86:a := lshift(a + 1);
87:a := a + 1;					{ a = 0000 0000 0011 1111 }
88:b := band(ir, a); if z then goto 102;	{ b = 0000 0000 00mm mmmm, if zero, ac = 0; top of stack = 0 }
89:mar := sp; rd;
90:rd;
91:ac := mbr; if z then goto 101;		{ ac = top of stack, if zero top of stack = 0, leaving ac at 0 }
92:a := ac; if n then goto 96;			{ a = |ac| = |top of stack| }
93:b := b + (-1); if z then goto 99;		{ while b >= 0, ac = ac + a, b = b - 1 }
94:ac := ac + a; if n then goto 103;		{ In case of over flow, ac = -1, and leave instruction }
95:goto 93;				
96:b := b + (-1); if z then goto 99;		{ When top is stack is negative, overflow happens when no longer negative }
97:ac := ac + a; if n then goto 96;
98:goto 103;
99:mbr := ac;					{ When finished multiplication, top of stack = product, ac = 0 }
100:ac := 0; 
101:mar := sp; wr; goto 10;
102:ac := 0; goto 99;
103:ac := (-1); goto 0;
104:a := lshift(1);				{ 1111 1111 01 = RSHIFT }
105:a := lshift(a + 1);
106:a := lshift(a + 1);
107:a := a + 1;					{ a = 0000 0000 0000 1111 }
108:b := band(ir, a);				{ b = 0000 0000 00xx ssss }
109:b := b + (-1); if n then goto 0;		{ while b > 0, ac = rshift(ac), b = b - 1)
110:ac := rshift(ac); goto 109;
111:tir := lshift(tir); if n then goto 145;	{ 1111 1111 11 = HALT }
112:mar := sp; sp := sp + 1; rd;		{ 1111 1111 10 = DIV }
113:rd;
114:ac := mbr;					{ ac = dividend }
115:mar := sp; sp := sp + (-1); rd;
116:rd;
117:sp := sp + (-1);
118:a := mbr; if z then goto 140;		{ a = divisor }
119:b := ac; if n then goto 126;		{ b = |dividend| }
120:c := a; if n then goto 123;			{ c = -|divisor| }
121:c := inv(c);
122:c := c + 1;
123:d := 0;
124:b := b + c; if n then goto 128;		{ b = |dividend| - (quotient + 1)|divisor| }
125:d := d + 1; goto 124;			{ If still positive, increment quotient }
126:b := inv(b);				{ Turn -b into b }
127:b := b + 1; goto 120;
128:c := inv(c);				{ c = |divisor| }
129:c := c + 1;
130:b := b + c;					{ Since it overshoots, add one more divisor back to b to get remainder }				
131:mar := sp; mbr := b; wr;			{ remander = b }
132:wr;
133:sp := sp + (-1);
134:a := a; if n then goto 137; 		{ If divisor is negative, check for negative dividend }
135:ac := 0;
136:mar := sp; mbr := d; wr; goto 10;
137:ac := ac; if n then goto 135;		{ If dividend is negative, keep quotient positive }
138:d := inv(d);
139:d := d + 1; goto 135;			{ If divident is positive, turn quotient negative }
140:ac := (-1);					{ If divisor = 0; AC = -1, remainder = -1, quotient = 0 }
141:mar := sp; mbr := (-1); wr;
142:wr;
143:sp := sp + (-1);
144:mar := sp; mbr := 0; wr; goto 10;
145:rd; wr; 					{ 1111 1111 11 = HALT }