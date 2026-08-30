// cla64_hier.v
// BONUS -- open-ended. No detailed scaffold is provided; this is meant to
// be a genuine design exercise. Not required for lab submission.
//
// You will likely need to modify cla4.v (or add signals alongside it) so
// that block-generate/block-propagate summaries of its own Gi, Pi signals
// are exposed as outputs, since the second-level lookahead unit below
// needs them. As with every module in this lab from Task 2 onward, every
// gate/assign you add should carry an explicit delay.
//
// Starting point (from Tutorial 3, Q4(d)):
//   - Reuse 16 four-bit CLA blocks (your cla4.v) -- their internal logic
//     doesn't change.
//   - For each block k, define:
//       Gblk_k = "this block produces a carry regardless of its incoming
//                 carry" -- a Boolean function of that block's own 4
//                 bit-level Gi, Pi signals.
//       Pblk_k = "an incoming carry sails straight through this whole
//                 block" -- likewise a function of its own Gi, Pi.
//   - Build a second-level lookahead unit -- structurally identical to
//     cla4.v, just one level up -- that computes each block's carry-in
//     directly from Gblk_0..Gblk_15, Pblk_0..Pblk_15, and cin, instead of
//     rippling block to block.
//
// To test this, wire it into dut.v as a fourth option (copy the pattern
// used for the other three) and run it through the same tb.v. Compare
// your final delay to cla64_blocked.v from Task 4.

module cla64_hier(
    input  [63:0] a,
    input  [63:0] b,
    input         cin,
    output [63:0] sum,
    output        cout
);

    // 16 blocks, each block contains 4 bits
    wire [15:0] P;
    wire [15:0] G;

    // Carry into each 4-bit block
    wire [16:0] C;

    // Internal carries inside each 4-bit block
    wire [63:0] c;

    assign C[0] = cin;

    // ---------------------------------------------------------
    // Block propagate P and block generate G
    // ---------------------------------------------------------

    genvar i;

    generate
        for (i = 0; i < 16; i = i + 1) begin : BLOCK_PG

            wire p0, p1, p2, p3;
            wire g0, g1, g2, g3;

            xor #(2) (p0, a[4*i],   b[4*i]);
            xor #(2) (p1, a[4*i+1], b[4*i+1]);
            xor #(2) (p2, a[4*i+2], b[4*i+2]);
            xor #(2) (p3, a[4*i+3], b[4*i+3]);

            and #(2) (g0, a[4*i],   b[4*i]);
            and #(2) (g1, a[4*i+1], b[4*i+1]);
            and #(2) (g2, a[4*i+2], b[4*i+2]);
            and #(2) (g3, a[4*i+3], b[4*i+3]);

            // Block propagate:
            // P = p3.p2.p1.p0
            and #(2) (P[i], p3, p2, p1, p0);

            // Block generate:
            // G = g3 + p3.g2 + p3.p2.g1
            //     + p3.p2.p1.g0
            wire t0, t1, t2;

            and #(2) (t0, p3, g2);
            and #(2) (t1, p3, p2, g1);
            and #(2) (t2, p3, p2, p1, g0);

            or #(2) (G[i], g3, t0, t1, t2);

        end
    endgenerate


    // ---------------------------------------------------------
    // Second-level lookahead
    //
    // C[i+1] = G[i]
    //        + P[i].G[i-1]
    //        + P[i].P[i-1].G[i-2]
    //        + ...
    //        + P[i]...P[0].cin
    //
    // These equations compute the carry into each 4-bit block
    // directly rather than rippling block-to-block.
    // ---------------------------------------------------------

    assign #(2) C[1] =
        G[0] |
        (P[0] & C[0]);

    assign #(2) C[2] =
        G[1] |
        (P[1] & G[0]) |
        (P[1] & P[0] & C[0]);

    assign #(2) C[3] =
        G[2] |
        (P[2] & G[1]) |
        (P[2] & P[1] & G[0]) |
        (P[2] & P[1] & P[0] & C[0]);

    assign #(2) C[4] =
        G[3] |
        (P[3] & G[2]) |
        (P[3] & P[2] & G[1]) |
        (P[3] & P[2] & P[1] & G[0]) |
        (P[3] & P[2] & P[1] & P[0] & C[0]);

    assign #(2) C[5] =
        G[4] |
        (P[4] & G[3]) |
        (P[4] & P[3] & G[2]) |
        (P[4] & P[3] & P[2] & G[1]) |
        (P[4] & P[3] & P[2] & P[1] & G[0]) |
        (P[4] & P[3] & P[2] & P[1] & P[0] & C[0]);

    assign #(2) C[6] =
        G[5] |
        (P[5] & G[4]) |
        (P[5] & P[4] & G[3]) |
        (P[5] & P[4] & P[3] & G[2]) |
        (P[5] & P[4] & P[3] & P[2] & G[1]) |
        (P[5] & P[4] & P[3] & P[2] & P[1] & G[0]) |
        (P[5] & P[4] & P[3] & P[2] & P[1] & P[0] & C[0]);

    assign #(2) C[7] =
        G[6] |
        (P[6] & G[5]) |
        (P[6] & P[5] & G[4]) |
        (P[6] & P[5] & P[4] & G[3]) |
        (P[6] & P[5] & P[4] & P[3] & G[2]) |
        (P[6] & P[5] & P[4] & P[3] & P[2] & G[1]) |
        (P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & G[0]) |
        (P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & P[0] & C[0]);

    assign #(2) C[8] =
        G[7] |
        (P[7] & G[6]) |
        (P[7] & P[6] & G[5]) |
        (P[7] & P[6] & P[5] & G[4]) |
        (P[7] & P[6] & P[5] & P[4] & G[3]) |
        (P[7] & P[6] & P[5] & P[4] & P[3] & G[2]) |
        (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & G[1]) |
        (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & G[0]) |
        (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & P[0] & C[0]);

    // ---------------------------------------------------------
    // Remaining block carries
    // ---------------------------------------------------------
    assign #(2) C[9]  = G[8]  | (P[8]  & C[8]);
    assign #(2) C[10] = G[9]  | (P[9]  & C[9]);
    assign #(2) C[11] = G[10] | (P[10] & C[10]);
    assign #(2) C[12] = G[11] | (P[11] & C[11]);
    assign #(2) C[13] = G[12] | (P[12] & C[12]);
    assign #(2) C[14] = G[13] | (P[13] & C[13]);
    assign #(2) C[15] = G[14] | (P[14] & C[14]);
    assign #(2) C[16] = G[15] | (P[15] & C[15]);

    // ---------------------------------------------------------
    // Four-bit CLA blocks
    // ---------------------------------------------------------

    generate
        for (i = 0; i < 16; i = i + 1) begin : CLA_BLOCKS

            cla4 CLA (
                .a(a[4*i +: 4]),
                .b(b[4*i +: 4]),
                .cin(C[i]),
                .sum(sum[4*i +: 4]),
                .cout()
            );

        end
    endgenerate

    assign cout = C[16];

endmodule